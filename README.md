# sleighc

Wrapper around Ghidra's SLEIGH specification compiler.

## Requirements

- Bison (>= 3.8)
- Flex (>= 2.6)
- zlib (>= 1.2.12)

## Building

```
rm -rf build && mkdir build
cmake -B build
cmake --build build --parallel
cmake --install build
```
