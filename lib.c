void _shift(char *s, int len) {
  int i;
  for (i = len; i >= 0; i--) {
    s[i + 1] = s[i];
  }
}

int _base_itoa(char *dest, int v, int base) {
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

void mysprintf(char *dest, const char *string, ...) {
  int *vargs = (int *)(&dest + 2);

  int i = 0;
  while (*string) {
    int base;
    int len = 1;
    int str_inc = 1;

    if (string[0] == '%' && (base = _getbase(string[1]))) {
      len = _base_itoa(dest, vargs[i++], base);
      str_inc = 2;
    } else {
      *dest = *string;
    }
    dest += len;
    string += str_inc;
  }
  *dest = '\0';
}
