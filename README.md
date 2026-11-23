# MutantCore — Mutation-Aware RV32 Verification

[![CI](https://github.com/katepallewarprathmesh-sketch/MutantCore/actions/workflows/ci.yml/badge.svg)](https://github.com/katepallewarprathmesh-sketch/MutantCore/actions/workflows/ci.yml)

A reproducible verification harness for the PicoRV32 core. The retirement adapter records instruction-level RVFI data so the testbench can compare architectural effects in order rather than relying only on final register state.

## Verified results

| Check | Result | Evidence |
|---|---|---|
| Verilator RV32I smoke | PASS: eight retirements and memory effects checked | `results/trace_compare.txt`, `results/dut_trace_baseline.csv` |
| Icarus RV32I smoke | PASS against the same directed trace | `results/dut_trace_icarus.csv` |
| Manually seeded fault tests | 3/3 detected across ALU, decode and branch logic | `results/seed_mutations.txt`, `results/mutation_progress.csv` |
| Continuous integration | Verilator and Icarus workflow | CI badge above |

The 3/3 hand-seeded result is scoped to the fixed directed fault set; the planned MCY campaign will broaden it to generated mutants and survivor classification. The checked program exercises ADDI, ADD, BNE, SW, LW, JAL and EBREAK, and the trace checker validates register writes, next-PC behavior and load/store effects.

## Run the checks

Requirements: Verilator, Icarus Verilog, `riscv64-unknown-elf-gcc`, binutils and Python 3. PicoRV32 source and its upstream ISC license are in `third_party/picorv32/`.

```sh
make test        # lint, Verilator smoke and Icarus smoke
make mutations   # add the three targeted fault-detection runs
make results     # run mutations and display evidence locations
make clean
```

## Verification roadmap

The next measurement stages are a Spike instruction-trace comparison, riscv-dv generated RV32I programs, and an MCY campaign over ALU/decode/branch logic with survivor classification. Together these extend the current instruction-level smoke and targeted fault tests into broad reference-model and mutation-based verification.

## Licenses

Project collateral is Apache-2.0. PicoRV32 retains its upstream ISC license in `third_party/picorv32/COPYING`.
