void api_putchar(int c);
void api_end(void);

void Main(void) {
  for (;;) {
    api_putchar('a');
  }
}
