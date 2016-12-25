#include "bootpack.h"

int chk_486_or_newer(void);
void ctl_cache(char flg);
unsigned int memtest_sub(unsigned int start, unsigned int end);

#define EFLAGS_AC_BIT 0x00040000
#define CR0_CACHE_DISABLE 0x60000000

#define DISABLE_CACHE 0
#define ENABLE_CACHE 1
unsigned int memtest(unsigned int start, unsigned int end) {
  unsigned int mem;
  int is486 = chk_486_or_newer();

  if (is486) {
    ctl_cache(DISABLE_CACHE);
  }
  mem = memtest_sub(start, end);
  if (is486) {
    ctl_cache(ENABLE_CACHE);
  }
  return mem;
}

#define CR0_CACHE_DISABLE 0x60000000
void ctl_cache(char flg) {
  int cr0 = load_cr0();
  switch (flg) {
    case DISABLE_CACHE:
      cr0 |= CR0_CACHE_DISABLE;
      break;
    case ENABLE_CACHE:
      cr0 &= ~CR0_CACHE_DISABLE;
      break;
  }
  store_cr0(cr0);
}

#define EFLAGS_AC_BIT 0x00040000
int chk_486_or_newer(void) {
  unsigned int eflg;
  int result = 0;

  eflg = io_load_eflags();
  eflg |= EFLAGS_AC_BIT;  // AC-bit = 1
  io_store_eflags(eflg);
  eflg = io_load_eflags();
  if ((eflg & EFLAGS_AC_BIT) != 0) {
    // 386ではAC=1にしても自動で0に戻ってしまう
    result = 1;
  }
  eflg &= ~EFLAGS_AC_BIT;  // AC-bit = 0
  io_store_eflags(eflg);
  return result;
}

unsigned int memtest_sub(unsigned int start, unsigned int end) {
  unsigned int i, *p, old, pat0 = 0xaa55aa55, pat1 = 0x55aa55aa;
  for (i = start; i <= end; i += 0x1000) {
    p = (unsigned int *)(i + 0xffc);
    old = *p;          // いじる前の値を覚えておく
    *p = pat0;         // ためしに書いてみる
    *p ^= 0xffffffff;  // そしてそれを反転してみる
    if (*p != pat1) {  // 反転結果になったか？
    not_memory:
      *p = old;
      break;
    }
    *p ^= 0xffffffff;  // もう一度反転してみる
    if (*p != pat0) {  // 元に戻ったか？
      goto not_memory;
    }
    *p = old;  // いじった値を元に戻す
  }
  return i;
}

void memman_init(struct MEMMAN *man) {
  man->frees = 0;     // あき情報の個数
  man->maxfrees = 0;  // 状況観察用：freesの最大値
  man->lostsize = 0;  // 解放に失敗した合計サイズ
  man->losts = 0;     // 解放に失敗した回数
  return;
}

unsigned int memman_total(struct MEMMAN *man) {
  unsigned int i, t = 0;
  for (i = 0; i < man->frees; i++) {
    t += man->free[i].size;
  }
  return t;
}

unsigned int memman_alloc(struct MEMMAN *man, unsigned int size) {
  unsigned int i, a;
  for (i = 0; i < man->frees; i++) {
    if (man->free[i].size >= size) {
      // 十分な広さのあきを発見
      a = man->free[i].addr;
      man->free[i].addr += size;
      man->free[i].size -= size;
      if (man->free[i].size == 0) {
        // free[i]がなくなったので前へつめる
        man->frees--;
        for (; i < man->frees; i++) {
          man->free[i] = man->free[i + 1];  // 構造体の代入
        }
      }
      return a;
    }
  }
  return 0;  // あきがない
}

int memman_free(struct MEMMAN *man, unsigned int addr, unsigned int size) {
  int i, j;
  // まとめやすさを考えると、free[]がaddr順に並んでいるほうがいい
  // だからまず、どこに入れるべきかを決める
  for (i = 0; i < man->frees; i++) {
    if (man->free[i].addr > addr) {
      break;
    }
  }
  // free[i - 1].addr < addr < free[i].addr
  if (i > 0) {
    // 前がある
    if (man->free[i - 1].addr + man->free[i - 1].size == addr) {
      // 前のあき領域にまとめられる
      man->free[i - 1].size += size;
      if (i < man->frees) {
        // 後ろもある
        if (addr + size == man->free[i].addr) {
          // なんと後ろともまとめられる
          man->free[i - 1].size += man->free[i].size;
          // man->free[i]の削除
          // free[i]がなくなったので前へつめる
          man->frees--;
          for (; i < man->frees; i++) {
            man->free[i] = man->free[i + 1];  // 構造体の代入
          }
        }
      }
      return 0;  // 成功終了
    }
  }
  // 前とはまとめられなかった
  if (i < man->frees) {
    // 後ろがある
    if (addr + size == man->free[i].addr) {
      // 後ろとはまとめられる
      man->free[i].addr = addr;
      man->free[i].size += size;
      return 0;  // 成功終了
    }
  }
  // 前にも後ろにもまとめられない
  if (man->frees < MEMMAN_FREES) {
    // free[i]より後ろを、後ろへずらして、すきまを作る
    for (j = man->frees; j > i; j--) {
      man->free[j] = man->free[j - 1];
    }
    man->frees++;
    if (man->maxfrees < man->frees) {
      man->maxfrees = man->frees;  // 最大値を更新
    }
    man->free[i].addr = addr;
    man->free[i].size = size;
    return 0;  // 成功終了
  }
  // 後ろにずらせなかった
  man->losts++;
  man->lostsize += size;
  return -1;  // 失敗終了
}

unsigned int memman_alloc_4k(struct MEMMAN *man, unsigned int size) {
  unsigned int a;
  size = (size + 0xfff) & 0xfffff000;
  a = memman_alloc(man, size);
  return a;
}

int memman_free_4k(struct MEMMAN *man, unsigned int addr, unsigned int size) {
  int i;
  size = (size + 0xfff) & 0xfffff000;
  i = memman_free(man, addr, size);
  return i;
}
