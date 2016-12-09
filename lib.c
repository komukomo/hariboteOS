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
    v /= base;
    if (v <= 0) break;
    _shift(dest, len);
  }
  dest[len] = '\0';
  return len;
}

int myitoa(char *dest, int v) { return _base_itoa(dest, v, 10); }

void mysprintf(char *dest, const char *string, ...) {
  int *vargs = (int *)(&dest + 2);

  int i = 0;
  while (*string) {
    int len = 1;
    int str_inc = 1;

    // only '%d' format
    if (string[0] == '%' && string[1] == 'd') {
      len = myitoa(dest, vargs[i++]);
      str_inc = 2;
    } else {
      *dest = *string;
    }
    dest += len;
    string += str_inc;
  }
  *dest = '\0';
}
