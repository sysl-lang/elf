// The 32-bit little-endian ARM executable: code in flash, initialised data loaded after it and
// placed in RAM (so its load and run addresses differ), and zeroed data with no bytes in the file.

int counter = 42;
int table[64];

int bump(int by) {
    counter += by;
    return counter + table[by & 63];
}

void _start(void) {
    bump(1);
    for (;;) {
    }
}
