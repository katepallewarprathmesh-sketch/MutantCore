#!/usr/bin/env python3
"""Compare PicoRV32 RVFI smoke trace against a tiny golden execution trace.

This is a smoke-level oracle for the hand-written assembly only. It is not
Spike or a general ISA reference model; that integration is still pending.
"""
import csv
import sys
from pathlib import Path

trace_path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("results/dut_trace.csv")
rows = list(csv.DictReader(open(trace_path, newline="")))
expected = [
    (0x00, 0x00500093, 1, 5, 0x04),
    (0x04, 0x00700113, 2, 7, 0x08),
    (0x08, 0x002081B3, 3, 12, 0x0C),
    (0x0C, 0x10302023, 0, 0, 0x10),
    (0x10, 0x10002203, 4, 12, 0x14),
    (0x14, 0x00419663, 0, 0, 0x18),
    (0x18, 0x00100293, 5, 1, 0x1C),
    (0x1C, 0x0080006F, 0, 0, 0x24),
]
assert len(rows) == len(expected), f"retired rows {len(rows)} != expected {len(expected)}"
for i, (row, exp) in enumerate(zip(rows, expected)):
    pc, insn, rd, rd_data, pc_next = exp
    got = (int(row["pc"], 16), int(row["insn"], 16), int(row["rd"]),
           int(row["rd_data"], 16), int(row["pc_next"], 16))
    assert got == exp, f"retirement {i}: got {got}, expected {exp}"
assert int(rows[3]["mem_addr"], 16) == 0x100
assert int(rows[3]["mem_wmask"], 16) == 0xF
assert int(rows[3]["mem_wdata"], 16) == 12
assert int(rows[4]["mem_addr"], 16) == 0x100
assert int(rows[4]["mem_rmask"], 16) == 0xF
assert int(rows[4]["mem_rdata"], 16) == 12
Path("results/trace_compare.txt").write_text(
    "PASS: 8 RVFI retirement records match directed golden trace; "
    "ADD/branch/store/load effects verified. This is not a Spike comparison.\n")
print("Trace smoke PASS (8 retirements; memory store/load verified)")
