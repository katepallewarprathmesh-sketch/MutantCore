# MutantCore — Mutation-Aware RV32 Verification

[![CI](https://github.com/katepallewarprathmesh-sketch/MutantCore/actions/workflows/ci.yml/badge.svg)](https://github.com/katepallewarprathmesh-sketch/MutantCore/actions/workflows/ci.yml)

A reproducible retirement-trace verification harness for PicoRV32. An RVFI adapter records instruction-level architectural effects so the testbench can check ordered retirement behavior, including register writes and memory effects.

## Executed evidence

| Check | Result | Evidence |
|---|---|---|
| Verilator RV32I smoke | Eight retirements match the directed golden trace; load/store effects checked | `results/trace_compare.txt`, `results/dut_trace_baseline.csv` |
| Icarus RV32I smoke | Same directed program passes the trace checker | `results/dut_trace_icarus.csv` |
| Manually seeded fault checks | 3/3 targeted ALU, decode and branch substitutions detected | `results/seed_mutations.txt`, `results/mutation_progress.csv` |
| MCY candidate generation | 12 candidates imported/generated; all remain `PENDING` and unclassified | `results/mcy_inventory.txt` |

The hand-seeded 3/3 result is scoped to its fixed directed fault set; it is not an MCY mutation score. The MCY inventory records candidate generation only, with no simulation, equivalence classification, or kill result. The checked program exercises ADDI, ADD, BNE, SW, LW, JAL and EBREAK. Its reference is a hand-written golden trace, not Spike. `riscv-dv` generated programs and Spike co-simulation are future extensions, not current evidence.

## Run the checks

Requirements: Verilator, Icarus Verilog, `riscv64-unknown-elf-gcc`, binutils and Python 3. PicoRV32 source and its upstream ISC license are in `third_party/picorv32/`.

```sh
make test        # lint, Verilator smoke and Icarus smoke
make mutations   # add the three targeted fault-detection runs
make results     # run mutations and display evidence locations
make clean
```

## Tested tool versions

Versions observed in the local run: Verilator 5.032, Icarus Verilog 12.0, `riscv64-unknown-elf-gcc` 14.2.0, and Python 3.13.18. The MCY candidate-import artifact records Yosys 0.52 and the MCY source pin. The repository does not yet pin a complete toolchain image; record any different versions when reproducing.

## Verification roadmap

Classify the 12 pending MCY candidates with simulation/equivalence, then broaden the directed trace with Spike reference comparisons and riscv-dv-generated RV32I programs. Expand the fault set and report killed, survived and equivalent mutants separately.

## Licenses

Project collateral is Apache-2.0. PicoRV32 retains its upstream ISC license in `third_party/picorv32/COPYING`.
