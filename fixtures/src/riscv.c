// The 64-bit little-endian RISC-V executable, static and with no C library.

int level = 3;

int deeper(int by) {
    return level + by;
}

void _start(void) {
    deeper(2);
    for (;;) {
    }
}
