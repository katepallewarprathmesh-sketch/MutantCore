PROJECT := MutantCore
RTL := third_party/picorv32/picorv32.v
TB := sim/trace_tb.sv
.PHONY: test smoke lint iverilog-test results mutations clean pin mcy-fetch mcy-init mcy-status

test: smoke
	$(MAKE) iverilog-test

smoke: lint
	./scripts/build_firmware.sh
	rm -f results/dut_trace.csv
	verilator --binary --timing --top-module trace_tb -DRISCV_FORMAL -Wno-fatal --Mdir build/obj $(RTL) $(TB)
	./build/obj/Vtrace_tb
	python3 scripts/check_trace.py

lint:
	verilator --lint-only --timing --top-module trace_tb -DRISCV_FORMAL -Wno-fatal $(RTL) $(TB)

iverilog-test:
	./scripts/build_firmware.sh
	iverilog -g2012 -DRISCV_FORMAL -s trace_tb -o build/iverilog.vvp $(RTL) $(TB)
	vvp build/iverilog.vvp
	cp results/dut_trace.csv results/dut_trace_icarus.csv
	python3 scripts/check_trace.py results/dut_trace_icarus.csv

mutations: smoke
	python3 scripts/run_seed_mutations.py

results: mutations
	@echo 'See results/trace_compare.txt and results/mutation_progress.csv'

pin:
	cat docs/pin.txt

mcy-fetch:
	./scripts/fetch_tools.sh mcy

mcy-init: mcy-fetch
	cd flow/mcy && python3 ../../tools/mcy/mcy.py init

mcy-status: mcy-fetch
	cd flow/mcy && python3 ../../tools/mcy/mcy.py status

clean:
	rm -rf build obj_dir
	rm -f firmware/smoke.elf firmware/smoke.bin firmware/smoke.hex
