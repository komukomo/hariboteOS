void api_putstr0(char *s);
void api_end(void);

void Main(void) {
  api_putstr0("hello, world\n");
  api_end();
}
