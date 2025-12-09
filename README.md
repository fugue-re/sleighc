# ghidra

Ghidra's SLEIGH specification compiler and decompiler as a library.

## Requirements

- Bison (>= 3.8)
- Flex (>= 2.6)
- zlib (>= 1.2.12)

## Configuration

- `BUILD_COMPILER`: Build the sleigh compiler (default: `ON`)
- `BUILD_DECOMPILER`: Build the decompiler static library (default: `ON`)

## Building

```
rm -rf build && mkdir build
cmake -B build
cmake --build build --parallel
cmake --install build
```
