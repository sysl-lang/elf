# elf

ELF files read and loaded for sysl. It handles ELF-32 and ELF-64, either byte order, and every
machine and file type: the file header, segments, sections by name, the static and dynamic symbol
tables, and a loader that places an executable's segments in memory the caller owns.

It reads from bytes the caller already has and copies nothing: names and contents are views of those
bytes. It opens no files, so the same code serves a host tool, an emulator, an operating system's
`exec` and a bootloader on a bare board.

## Using it

```hocon
dependencies {
  elf { git = "github.com/sysl-lang/elf", version = "0.1.1" }
}
```

The module is `sh.sysl.elf`.

```sysl
import sh.sysl.elf.*
import sysl.fs.read_bytes

main()
    val bytes = read_bytes("firmware.elf").unwrap()
    val e = read(bytes).unwrap()

    print(e.header.machine == EM_ARM, e.header.entry)

    for s in e.segments().view()
        if s.kind == PT_LOAD then print(s.paddr, s.filesz, s.memsz)

    e.symbol_named("main").unwrap() match
        Some(m) -> print(m.value, m.size)
        None -> ()

    var flash = [0u8; 65536]
    val regions: []Region = [Region(0x10000000, flash[..])]

    load(e, regions).unwrap()
```

| call | answers |
|---|---|
| `read(bytes)` | the file, once its header and both header tables are known to lie within `bytes` |
| `e.header` | every field of the file header, widened to 64 bits where ELF-32 has 32 |
| `e.segment(i)`, `e.segments()` | program headers |
| `e.segment_bytes(s)` | a segment's bytes in the file |
| `e.section(i)`, `e.sections()`, `e.section_named(".text")` | section headers, with their names |
| `e.section_bytes(s)` | a section's contents (none for `.bss`) |
| `e.symbols()`, `e.dynamic_symbols()`, `e.symbol_named("x")` | `.symtab` and `.dynsym` entries, names looked up, the info byte split into `bind` and `kind` |
| `load(e, regions)` | every loadable segment placed and zero-filled; the entry point |

**`load` checks every segment before it writes one.** A segment that lies outside every region, or
across two, is `ElfError.Unplaced`, and memory is left as it was. **Contents are checked when they
are asked for**: a damaged section is an error from `section_bytes`, not from `read`, so the rest of
the file is still readable.

Not covered yet: applying relocations, the dynamic section, notes and DWARF.

## Configuring it

A consumer that knows what it will be given sets options in its dependency entry. What is turned off
is left out of the build, and a file in that format is refused as `ElfError.Unsupported`:

```hocon
dependencies {
  elf {
    git = "github.com/sysl-lang/elf", version = "0.1.1"
    options = { elf64 = false, big_endian = false, place_by = "virtual" }
  }
}
```

| option | default | says |
|---|---|---|
| `elf32` | `true` | read ELF-32 files |
| `elf64` | `true` | read ELF-64 files |
| `little_endian` | `true` | read little-endian files |
| `big_endian` | `true` | read big-endian files |
| `place_by` | `"physical"` | where `load` puts a segment: its load address (`"physical"`, as a debugger or flash programmer does; a program running from flash copies `.data` to RAM itself) or its run address (`"virtual"`, as an operating system's loader does) |

At least one class and one byte order stay on. A build with neither is refused:
`assertion failed: the elf package reads no class: turn on elf32 or elf64`.

## Testing

```
sysl test .
sysl test . --option elf32=false
sysl test . --option elf64=false
sysl test . --option little_endian=false
sysl test . --option big_endian=false
sysl test . --option place_by=virtual
sysl test . --option elf32=false --option elf64=false
```

The first six must pass. The last must be refused with the assertion above.

The suite reads five files from `fixtures/`, one for each shape that reads differently:

- a 32-bit little-endian ARM executable, whose data is loaded after its code but runs in RAM;
- a 64-bit AArch64 executable;
- a 64-bit RISC-V executable;
- an x86-64 shared library, with both symbol tables;
- a big-endian ARM relocatable object.

Every value the tests assert was read from the file with `llvm-readelf`, not from this package.
`fixtures/build.sh` rebuilds them with `arm-none-eabi-gcc` and Homebrew's LLVM. The files are
committed, so running the tests needs neither.

## Licence

ISC.
