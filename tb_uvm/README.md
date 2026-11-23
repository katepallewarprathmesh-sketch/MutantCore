# Track A UVM port plan (not executed)

No commercial simulator/UVM testbench is present. Planned environment: one RVFI trace monitor, instruction-stream sequence/agent, scoreboard comparing each retirement against Spike, and mutation-aware regression that emits killed/survived/equivalent tags. Functional coverage should include opcode/funct3, branch direction/taken status, register dependency/hazard, aligned memory mask, exception/trap and directed-vs-random source. Current executable flow is a direct Verilator SystemVerilog wrapper; do not claim UVM completion.
