// A 32-bit big-endian ARM relocatable object: every multi-byte field reads the other way round.

int big_value = 0x01020304;

int read_big(void) {
    return big_value;
}
