# Toolchain and pins

| Component | Pin/version | Status |
|---|---|---|
| PicoRV32 | `ef203c2b0a3fb793280f5114941416c425c5b461` | vendored source, unmodified; ISC license |
| Verilator | 5.032 | smoke/lint executed |
| RISC-V GCC | `riscv64-unknown-elf-gcc` 14.2.0 | firmware assembly executed |
| GNU binutils | 2.44 | objcopy executed |
| MCY | `5a2cad0cbefceb7f23051c08348bd23128fd1046` | fetched on demand; 12-candidate import evidence recorded; classification not run |
| Spike / riscv-isa-sim | `982f078e65ab52d5d9a91248c2178f5399df7783` | fetchable on demand; build not completed, `spike` executable unavailable |
| riscv-dv | `f557b89ed6881a20515481a2585e9d004cd9642b` | pin recorded; generator not cloned/run |
| Yosys | 0.52 | installed; no MCY project run yet |
| Icarus Verilog | 12.0 | directed RVFI smoke also passes (same trace comparator) |
| Python | 3.13.18 | scripts executed |

The smoke command needs Verilator, the RISC-V bare-metal GCC/binutils, Python 3, and the pinned PicoRV32 source. MCY/Spike/riscv-dv are documented as not yet integrated; do not list them as completed experience based on this repository.
