# ADR-0001: Select PicoRV32

Status: Accepted.

Use upstream YosysHQ PicoRV32, pinned by commit in `docs/pin.txt`. It has a permissive ISC license, a Verilator-capable RTL, and an RVFI interface when built with `RISCV_FORMAL`. Keep upstream RTL unmodified; the local adapter and test assets are separate. OpenROAD is not a project requirement here.
