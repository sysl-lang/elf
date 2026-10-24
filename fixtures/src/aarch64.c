// The 64-bit little-endian AArch64 executable, static and with no C library.

long answer = 7;

long twice(long x) {
    return x * 2 + answer;
}

void _start(void) {
    twice(3);
    for (;;) {
    }
}
