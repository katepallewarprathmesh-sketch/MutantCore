#!/usr/bin/env python3
"""Run three deliberately seeded PicoRV32 ALU/decode/branch fault variants.

These are manually injected RTL substitutions, not MCY-generated mutants.
They validate that the directed regression detects representative faults;
results are not the blueprint's full mutation score.
"""
import csv
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "third_party/picorv32/picorv32.v"
BUILD = ROOT / "build"
RESULTS = ROOT / "results"
RESULTS.mkdir(exist_ok=True)
original = SRC.read_text()
baseline_trace = RESULTS / "dut_trace.csv"
if not baseline_trace.exists():
    raise FileNotFoundError("run make smoke before seeded mutations")
shutil.copy2(baseline_trace, RESULTS / "dut_trace_baseline.csv")
mutations = {
    "alu_add_to_sub": (
        "end else begin\n\t\talways @* begin\n\t\t\talu_add_sub = instr_sub ? reg_op1 - reg_op2 : reg_op1 + reg_op2;",
        "end else begin\n\t\talways @* begin\n\t\t\talu_add_sub = instr_sub ? reg_op1 - reg_op2 : reg_op1 - reg_op2;",
    ),
    "decode_addi_funct3": (
        "instr_addi  <= is_alu_reg_imm && mem_rdata_q[14:12] == 3'b000;",
        "instr_addi  <= is_alu_reg_imm && mem_rdata_q[14:12] == 3'b001;",
    ),
    "branch_bne_inverted": (
        "instr_bne:\n\t\t\t\talu_out_0 = !alu_eq;",
        "instr_bne:\n\t\t\t\talu_out_0 = alu_eq;",
    ),
}
rows = []
for name, (before, after) in mutations.items():
    assert original.count(before) == 1, f"mutation anchor not unique: {name}"
    variant = BUILD / name
    variant.mkdir(parents=True, exist_ok=True)
    mutant_src = variant / "picorv32_mutant.v"
    mutant_src.write_text(original.replace(before, after, 1))
    obj = variant / "obj"
    build = subprocess.run([
        "verilator", "--binary", "--timing", "--top-module", "trace_tb",
        "-DRISCV_FORMAL", "-Wno-fatal", "--Mdir", str(obj),
        str(mutant_src), str(ROOT / "sim/trace_tb.sv")
    ], cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if build.returncode:
        raise RuntimeError(f"mutant build failed ({name}):\n{build.stdout[-4000:]}")
    sim = subprocess.run([str(obj / "Vtrace_tb")], cwd=ROOT, text=True,
                         stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if sim.returncode:
        rows.append((name, "KILLED", f"simulation failed: {sim.returncode}"))
        continue
    shutil.copy2(RESULTS / "dut_trace.csv", RESULTS / f"dut_trace_{name}.csv")
    check = subprocess.run(["python3", "scripts/check_trace.py"], cwd=ROOT,
                           text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if check.returncode:
        rows.append((name, "KILLED", "golden trace mismatch"))
    else:
        rows.append((name, "SURVIVED", "current directed smoke did not distinguish mutant"))

shutil.copy2(RESULTS / "dut_trace_baseline.csv", baseline_trace)

with open(RESULTS / "seed_mutations.txt", "w") as f:
    f.write("Manually seeded fault-detection experiment (not MCY-generated):\n")
    for name, status, why in rows:
        f.write(f"{name}: {status} ({why})\n")
    f.write("Equivalent mutants: not classified; this experiment is a fixed seed set, not a mutation campaign.\n")
killed = sum(status == "KILLED" for _, status, _ in rows)
survived = len(rows) - killed
with open(RESULTS / "mutation_progress.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["stage", "total_seeded", "killed", "survived", "equivalent", "seed_kill_rate_pct", "scope"])
    w.writerow(["directed_smoke_manual_seeds", len(rows), killed, survived, "not_classified",
                f"{100*killed/len(rows):.1f}", "manual ALU, decode, branch substitutions; not MCY mutation score"])
print((RESULTS / "seed_mutations.txt").read_text())
if survived:
    raise SystemExit(f"{survived} seeded mutants survived")
