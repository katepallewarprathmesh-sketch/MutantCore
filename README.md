# MutantCore — mutation-tested RV32 core verification (in progress)

A verification harness around a pinned PicoRV32 core. The current executable milestone is a Verilator/RVFI smoke: assemble a small RV32I program, collect retirement records, compare against a directed golden trace, and inject three representative manual RTL faults.

## Quick start

Requirements: Verilator, `riscv64-unknown-elf-gcc` and binutils, Python 3. The PicoRV32 source and its ISC license are in `third_party/picorv32/`. Optional pinned MCY and Spike sources can be fetched with `scripts/fetch_tools.sh mcy` or `scripts/fetch_tools.sh spike`; they are intentionally not vendored to keep this repository small.

```sh
make test        # lint + assemble + Verilator run + golden trace check
make mutations   # rerun and kill 3 hand-seeded ALU/decode/branch substitutions
make results     # mutation artifacts after running the above
make clean
```

## Evidence pack — claims ledger (Rule Zero)

| Claim | Current status | Evidence |
|---|---|---|
| PicoRV32 pinned core boots smoke program in Verilator and Icarus | PASS | `results/trace_compare.txt`, `results/dut_trace_baseline.csv`, `results/dut_trace_icarus.csv`; run with `make test` |
| Eight retirement records match directed reference; store/load validated | PASS | `results/dut_trace_baseline.csv`; checker in `scripts/check_trace.py` |
| Three hand-seeded faults detected | PASS: 3/3 | `results/seed_mutations.txt`, `results/mutation_progress.csv` |
| MCY mutation score | **Not measured** | `results/mcy_inventory.txt`: 12 candidates generated, all PENDING; no tests/equivalence classification. Manual seed percentage is not the blueprint score |
| Spike co-simulation | **Not measured** | Spike source commit is recorded; local build not completed |
| riscv-dv random test generation | **Not measured** | Pin recorded; no program corpus generated |

Do not present the 100% manual seed kill rate as an MCY mutation score. No equivalent-mutant classification exists yet. `results/dut_trace*.csv` are generated, human-readable RVFI CSV traces included as evidence artifacts; rerun `make test mutations` to regenerate them.

## Architecture

The adapter is RVFI (`-DRISCV_FORMAL`) and records PC/instruction/register/memory effects. The directed program covers ADDI, ADD, BNE, SW, LW, JAL and EBREAK.

## Remaining blueprint milestones

1. Build/pin Spike and automatically compare retired traces.
2. Generate and run riscv-dv programs with logged seeds.
3. Configure MCY on PicoRV32 ALU/decode/branch, run the self-checking regression per mutant, classify survivors and publish real mutation-score progression.
4. Extend Track B to cocotb/pyuvm and document the commercial UVM port (currently only a planning note).

## Licenses

Project collateral is Apache-2.0; PicoRV32 remains under its upstream ISC license (`third_party/picorv32/COPYING`). Optional tool checkouts retain their upstream licenses when fetched.
