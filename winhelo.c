
char buf[150 * 50];

void Main(void) {
  int win;
  win = api_openwin(buf, 150, 50, -1, "hello");
  api_end();
}
