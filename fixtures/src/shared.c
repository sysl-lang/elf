// The x86-64 shared library: a position-independent file (ET_DYN) whose exported symbols are in
// the dynamic symbol table as well as the static one.

int shared_count = 5;

int shared_add(int x) {
    return x + shared_count;
}
