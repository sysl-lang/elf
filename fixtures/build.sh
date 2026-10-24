#!/bin/zsh
# Rebuilds the fixtures the tests read. They are committed, so the tests need none of these tools;
# what the tests assert about each file was read from it with readelf, not from this package.
set -e
cd ${0:A:h}
llvm=/opt/homebrew/opt/llvm/bin

arm-none-eabi-gcc -mcpu=cortex-m0plus -mthumb -O1 -ffreestanding -nostdlib \
    -Wl,--no-warn-rwx-segments -T src/arm.ld src/arm.c -o arm.elf

$llvm/clang --target=aarch64-linux-gnu -O1 -ffreestanding -nostdlib -static -fuse-ld=lld \
    -Wl,--build-id=none src/aarch64.c -o aarch64.elf

$llvm/clang --target=armebv7-none-eabi -O1 -ffreestanding -c src/big.c -o big.o

$llvm/clang --target=riscv64-unknown-elf -march=rv64gc -O1 -ffreestanding -nostdlib -static \
    -fuse-ld=lld -Wl,--build-id=none src/riscv.c -o riscv.elf

$llvm/clang --target=x86_64-linux-gnu -O1 -fPIC -shared -nostdlib -fuse-ld=lld \
    -Wl,--build-id=none src/shared.c -o shared.so
