module tb_cpu_smoke;
    localparam logic [31:0] BASE = 32'h8000_0000;
    logic clk;
    logic reset;
    logic [31:0] pc, instr;
    logic fault;
    logic [31:0] rom [0:4];
    logic [31:0] expected_regs [0:31];

    single_cycle_cpu #(.RESET_PC(BASE)) dut (.*);

    // Return an illegal instruction on any out-of-image fetch.
    always_comb begin
        instr = 32'b0;
        if (pc >= BASE && pc < BASE + 20 && pc[1:0] == 0)
            instr = rom[(pc - BASE) >> 2];
    end

    task automatic tick;
        #1;
        clk = 1;
        #1;
        clk = 0;
        #1;
    endtask

    task automatic check_step(input logic [31:0] expected_pc, expected_next_pc,
                              input int rd, input logic [31:0] value);
        if (fault || pc !== expected_pc)
            $fatal(1, "Fetch at %h expected %h, instr=%h fault=%b", pc, expected_pc, instr, fault);
        tick();
        if (pc !== expected_next_pc)
            $fatal(1, "After %h, PC=%h expected %h", expected_pc, pc, expected_next_pc);
        expected_regs[rd] = value;
        foreach (expected_regs[i])
            if (dut.regs[i] !== expected_regs[i])
                $fatal(1, "After %h, x%0d=%h expected %h", expected_pc, i, dut.regs[i], expected_regs[i]);
        $display("pc=%h next=%h x%0d=%h", expected_pc, pc, rd, dut.regs[rd]);
    endtask

    initial begin
        clk = 0;
        reset = 1;
        $readmemh("build/alu_smoke.hex", rom);
        foreach (expected_regs[i]) expected_regs[i] = 0;
        tick();
        reset = 0;
        check_step(BASE,      BASE + 4,  1, 5);
        check_step(BASE + 4,  BASE + 8,  2, 7);
        check_step(BASE + 8,  BASE + 12, 3, 12);
        check_step(BASE + 12, BASE + 16, 4, 7);
        check_step(BASE + 16, BASE + 16, 0, 0);
        $display("PASS: alu_smoke.S on single-cycle RTL");
        $finish;
    end
endmodule
