# Verification plan

| Stage | Planned/implemented test | Output | Status |
|---|---|---|---|
| Baseline smoke | Hand-written RV32I assembly with arithmetic, branch, store/load, JAL, EBREAK; Verilator and Icarus | RVFI-to-CSV and golden check | Implemented; both PASS |
| Reference model | Spike commit log matched by retired PC/instruction/reg/memory effects | First-divergence report | Pending; current checker is handwritten directed golden |
| Random programs | riscv-dv generated RV32I programs, seed recorded | Program/trace corpus and opcode mix | Pending |
| Manual seed faults | ADDI/add/sub/branch substitutions, rerun smoke | `seed_mutations.txt` | Implemented; 3/3 killed |
| MCY candidate import | Yosys/MCY database, 12 initial candidates | candidate inventory | Initialized; all tagged PENDING, no kill/equivalence tests run |
| MCY campaign | MCY selected ALU/decode/branch mutants | killed/survived/equivalent inventory and score | Pending; do not interpret manual seed kill rate as MCY score |
| Survivors | Triage each MCY survivor: equivalent, unreachable, unobservable | Triage CSV with rationale/evidence | Pending |
| Regression interface | Verilator now; cocotb/pyuvm and Icarus portability | CI smoke | Pending |

Checks in current directed golden comparator: exact 8-instruction retirement stream, PC and instruction at each row, expected x1/x2/x3/x4/x5 writes, branch next PC, full-word store at 0x100, and full-word load value 12. The test intentionally exits on EBREAK trap and treats that terminal instruction as not part of the recorded eight retirement rows in this RTL configuration.
