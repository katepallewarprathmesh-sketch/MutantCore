`timescale 1ns/1ps
module trace_tb;
    logic clk = 0;
    logic resetn = 0;
    always #5 clk = ~clk;

    logic trap, mem_valid, mem_instr, mem_ready;
    logic [31:0] mem_addr, mem_wdata, mem_rdata;
    logic [3:0] mem_wstrb;
    logic mem_la_read, mem_la_write;
    logic [31:0] mem_la_addr, mem_la_wdata;
    logic [3:0] mem_la_wstrb;
    logic pcpi_wr, pcpi_wait, pcpi_ready;
    logic [31:0] pcpi_rd;
    logic [31:0] eoi;
    logic trace_valid;
    logic [35:0] trace_data;

    logic rvfi_valid, rvfi_trap, rvfi_halt, rvfi_intr;
    logic [63:0] rvfi_order;
    logic [31:0] rvfi_insn, rvfi_rs1_rdata, rvfi_rs2_rdata, rvfi_rd_wdata;
    logic [4:0] rvfi_rs1_addr, rvfi_rs2_addr, rvfi_rd_addr;
    logic [31:0] rvfi_pc_rdata, rvfi_pc_wdata, rvfi_mem_addr;
    logic [3:0] rvfi_mem_rmask, rvfi_mem_wmask;
    logic [31:0] rvfi_mem_rdata, rvfi_mem_wdata;
    logic [1:0] rvfi_mode, rvfi_ixl;
    logic [63:0] rvfi_csr_mcycle_rmask, rvfi_csr_mcycle_wmask;
    logic [63:0] rvfi_csr_mcycle_rdata, rvfi_csr_mcycle_wdata;
    logic [63:0] rvfi_csr_minstret_rmask, rvfi_csr_minstret_wmask;
    logic [63:0] rvfi_csr_minstret_rdata, rvfi_csr_minstret_wdata;

    logic [31:0] memory [0:1023];
    integer fd, cycles = 0;
    initial begin
        $readmemh("firmware/smoke.hex", memory);
        fd = $fopen("results/dut_trace.csv", "w");
        $fdisplay(fd, "order,pc,insn,rs1,rs1_data,rs2,rs2_data,rd,rd_data,mem_addr,mem_rmask,mem_wmask,mem_rdata,mem_wdata,pc_next,trap");
        repeat (5) @(posedge clk);
        resetn = 1;
    end

    assign mem_ready = mem_valid;
    always_comb mem_rdata = memory[mem_addr[11:2]];
    always_comb begin
        pcpi_wr = 0; pcpi_rd = 0; pcpi_wait = 0; pcpi_ready = 0;
    end
    always_ff @(posedge clk) begin
        if (resetn && mem_valid && mem_ready && |mem_wstrb) begin
            for (int b=0; b<4; b++)
                if (mem_wstrb[b]) memory[mem_addr[11:2]][8*b +: 8] <= mem_wdata[8*b +: 8];
        end
        if (resetn) begin
            cycles <= cycles + 1;
            if (rvfi_valid) begin
                $fdisplay(fd, "%0d,%08x,%08x,%0d,%08x,%0d,%08x,%0d,%08x,%08x,%x,%x,%08x,%08x,%08x,%0d",
                    rvfi_order, rvfi_pc_rdata, rvfi_insn,
                    rvfi_rs1_addr, rvfi_rs1_rdata, rvfi_rs2_addr, rvfi_rs2_rdata,
                    rvfi_rd_addr, rvfi_rd_wdata, rvfi_mem_addr, rvfi_mem_rmask,
                    rvfi_mem_wmask, rvfi_mem_rdata, rvfi_mem_wdata,
                    rvfi_pc_wdata, rvfi_trap);
            end
            if (trap) begin
                $fclose(fd);
                $display("CORE_TRAP after %0d cycles", cycles);
                $finish;
            end
            if (cycles > 5000) $fatal(1, "timeout waiting for test program trap");
        end
    end

    picorv32 #(
        .ENABLE_COUNTERS(1), .ENABLE_COUNTERS64(0),
        .ENABLE_REGS_16_31(1), .ENABLE_REGS_DUALPORT(1),
        .COMPRESSED_ISA(0), .ENABLE_MUL(0), .ENABLE_DIV(0),
        .ENABLE_IRQ(0), .ENABLE_TRACE(1), .REGS_INIT_ZERO(1),
        .PROGADDR_RESET(32'h0000_0000)
    ) dut (
        .clk(clk), .resetn(resetn), .trap(trap),
        .mem_valid(mem_valid), .mem_instr(mem_instr), .mem_ready(mem_ready),
        .mem_addr(mem_addr), .mem_wdata(mem_wdata), .mem_wstrb(mem_wstrb), .mem_rdata(mem_rdata),
        .mem_la_read(mem_la_read), .mem_la_write(mem_la_write), .mem_la_addr(mem_la_addr),
        .mem_la_wdata(mem_la_wdata), .mem_la_wstrb(mem_la_wstrb),
        .pcpi_valid(), .pcpi_insn(), .pcpi_rs1(), .pcpi_rs2(), .pcpi_wr(pcpi_wr), .pcpi_rd(pcpi_rd),
        .pcpi_wait(pcpi_wait), .pcpi_ready(pcpi_ready), .irq(32'b0), .eoi(eoi),
        .rvfi_valid(rvfi_valid), .rvfi_order(rvfi_order), .rvfi_insn(rvfi_insn),
        .rvfi_trap(rvfi_trap), .rvfi_halt(rvfi_halt), .rvfi_intr(rvfi_intr),
        .rvfi_mode(rvfi_mode), .rvfi_ixl(rvfi_ixl), .rvfi_rs1_addr(rvfi_rs1_addr),
        .rvfi_rs2_addr(rvfi_rs2_addr), .rvfi_rs1_rdata(rvfi_rs1_rdata),
        .rvfi_rs2_rdata(rvfi_rs2_rdata), .rvfi_rd_addr(rvfi_rd_addr), .rvfi_rd_wdata(rvfi_rd_wdata),
        .rvfi_pc_rdata(rvfi_pc_rdata), .rvfi_pc_wdata(rvfi_pc_wdata), .rvfi_mem_addr(rvfi_mem_addr),
        .rvfi_mem_rmask(rvfi_mem_rmask), .rvfi_mem_wmask(rvfi_mem_wmask),
        .rvfi_mem_rdata(rvfi_mem_rdata), .rvfi_mem_wdata(rvfi_mem_wdata),
        .rvfi_csr_mcycle_rmask(rvfi_csr_mcycle_rmask), .rvfi_csr_mcycle_wmask(rvfi_csr_mcycle_wmask),
        .rvfi_csr_mcycle_rdata(rvfi_csr_mcycle_rdata), .rvfi_csr_mcycle_wdata(rvfi_csr_mcycle_wdata),
        .rvfi_csr_minstret_rmask(rvfi_csr_minstret_rmask), .rvfi_csr_minstret_wmask(rvfi_csr_minstret_wmask),
        .rvfi_csr_minstret_rdata(rvfi_csr_minstret_rdata), .rvfi_csr_minstret_wdata(rvfi_csr_minstret_wdata),
        .trace_valid(trace_valid), .trace_data(trace_data)
    );
endmodule
