extern void io_hlt(void);
extern void io_cli(void);
extern int io_in8(int port);
extern void io_out8(int port, int data);

extern int io_load_eflags(void);
extern void io_store_eflags(int eflags);
