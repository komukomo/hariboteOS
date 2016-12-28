void _shift(char *s, int len) {
  int i;
  for (i = len; i >= 0; i--) {
    s[i + 1] = s[i];
  }
}

int _base_itoa(char *dest, unsigned int v, int base) {
  // negative value unsupported
  int len = 0;
  int offset = 48;  // char code 48 -> '0'
  while (1) {
    len++;
    dest[0] = (v % base) + offset;
    if (dest[0] > 9 + offset) {
      dest[0] += 7;  // 10 -> A, 11 -> B, ...
    }
    v /= base;
    if (v <= 0) break;
    _shift(dest, len);
  }
  dest[len] = '\0';
  return len;
}

int myitoa(char *dest, int v) { return _base_itoa(dest, v, 10); }

int _getbase(char c) {
  switch (c) {
    case 'd':
      return 10;
    case 'X':
      return 16;
    case 'x':
      return 16;
    default:
      return 0;
  }
}

int is_digit(char s) {
  if ('0' <= s && s <= '9') return 1;
  return 0;
}

int power(int x, int y) {
  // x ** y
  int i;
  int ans = 1;
  for (i = 0; i < y; i++) {
    ans *= x;
  }
  return ans;
}

int myatoi(const char *str) {
  int i;
  for (i = 0; str[i]; i++)
    ;

  int len = i, ans = 0;
  for (i = 0; i < len; i++) {
    ans += power(10, len - i - 1) * (str[i] - 48);
  }
  return ans;
}

int read_digit(int *ans, const char *str) {
  char buf[32];
  int i = 0;
  for (; is_digit(str[i]); i++) {
    buf[i] = str[i];
  }
  buf[i] = 0;
  *ans = myatoi(buf);
  return i;
}

char *strcpy(char *dest, const char *src) {
  char *s = dest;
  while ((*s++ = *src++) != 0)
    ;
  return dest;
}

void mysprintf(char *dest, const char *tmpl, ...) {
  int *vargs = (int *)(&dest + 2);
  int i = 0, j;

  while (*tmpl) {
    int base;
    int len = 1;
    int str_inc = 1;
    char tmpdest[32];

    int num;
    if (tmpl[0] == '%') {
      char padding = tmpl[1] == '0' ? '0' : ' ';
      int digit_len = read_digit(&num, &(tmpl[1]));
      base = _getbase(tmpl[digit_len + 1]);
      if (base != 0) {
        len = _base_itoa(tmpdest, vargs[i++], base);
        for (j = 0; j < num - len; j++) {
          *dest = padding;
          dest++;
        }
        strcpy(dest, tmpdest);

        // '2' means length of '%' and format discriptor (d, x, ,etc.)
        str_inc = digit_len + 2;
      } else {
        *dest = *tmpl;
      }
    } else {
      *dest = *tmpl;
    }
    dest += len;
    tmpl += str_inc;
  }
  *dest = '\0';
}

int mystrcmp(const char *s1, const char *s2) {
  for (; *s1 == *s2; s1++, s2++) {
    if (*s1 == '\0') return 0;
  }
  return *s1 > *s2 ? 1 : -1;
}

int mystrncmp(const char *s1, const char *s2, unsigned int size) {
  int i = 1;
  for (; *s1 == *s2; s1++, s2++, i++) {
    if (*s1 == '\0' || i == size) return 0;
  }
  return *s1 > *s2 ? 1 : -1;
}
