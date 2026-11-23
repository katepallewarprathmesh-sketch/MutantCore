# MutantCore specification (implementation status: in progress)

## Goal
Quantify whether a RISC-V verification suite detects realistic implementation faults, not merely whether it executes instructions. The chosen core is upstream YosysHQ PicoRV32, pinned at `ef203c2b0a3fb793280f5114941416c425c5b461` (details in `pin.txt`). Project target is RV32I. Upstream source is unmodified; local testbench and scripts live outside the core.

## Trace adapter
The `RISCV_FORMAL` conditional interface is used as the retirement adapter. `results/dut_trace.csv` records order, retired PC/instruction, source register values, destination write, memory address/masks/data, next PC, and trap. CSR state is intentionally not compared in the current smoke. The memory model is unified, 4 KiB, combinational read/one-cycle write acceptance, with one-cycle ready.

```text
firmware (RV32I ELF) -> hex image -> Verilator + PicoRV32 + simple RAM
                                            | RVFI retirement records
                                            v
                                  CSV trace adapter -> comparator
                                            ^
                                  Spike commit log (planned)
```

## Current smoke program
`firmware/smoke.S` exercises ADDI, ADD, BNE (not-taken), SW, LW, JAL, and EBREAK. A directed checker validates the eight expected retired instructions, PCs, register writes, branch path, and memory effects. This initial golden trace is hand-specified, **not Spike**.

## Mutation criteria
Blueprint target: MCY-generated mutations across ALU, decode, and branch, each regression classified as killed, surviving, or proven equivalent. Mutation score is `killed / (total - proven_equivalent)`. Current preliminary evidence instead uses three manually seeded substitutions (ALU add-to-sub, ADDI decode funct3, BNE inversion) and reports a seed kill rate only; it is not the target MCY mutation score. Every future survivor must be classified as equivalent, unreachable, or unobservable.

## Current limits / next milestones
- PicoRV32 Verilator smoke and RVFI CSV adapter: implemented and passing.
- Manual seed mutation test: implemented; currently 3/3 killed.
- Spike ISS co-simulation: not implemented; Spike source pin exists but local build was not completed.
- riscv-dv generation/integration: not implemented (commit pinned in `riscv_dv_pin.txt`).
- MCY candidate generation: initial 12-candidate database created in `flow/mcy`; all candidates remain tagged `PENDING` because no tests/equivalence classification are configured. No MCY score is claimed. The small initial candidate set is for bring-up only, not a complete ALU/decode/branch campaign.
- Cocotb/pyuvm adaptation and commercial UVM flow: not implemented.
