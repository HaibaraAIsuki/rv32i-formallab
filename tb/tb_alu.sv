module tb_alu;
    logic [31:0] a, b, result;
    logic [3:0] op;
    alu dut (.a(a), .b(b), .op(op), .result(result));

    task automatic check(
        input logic [31:0] aa, bb,
        input logic [3:0] opcode,
        input logic [31:0] expected
    );
        a = aa;
        b = bb;
        op = opcode;
        #1;
        if (result !== expected) begin
            $display("FAIL op=%0d a=%h b=%h got=%h expected=%h",
                      opcode, aa, bb, result, expected);
            $fatal(1, "ALU directed test failed");
        end
    endtask

    initial begin
        check(32'hffffffff, 32'd1, 4'd0, 32'd0); // wraparound ADD
        check(32'd0, 32'd1, 4'd1, 32'hffffffff); // SUB
        check(32'hf0f0, 32'h0ff0, 4'd2, 32'h00f0); // AND
        check(32'hf000, 32'h00f0, 4'd3, 32'hf0f0); // OR
        check(32'hffff, 32'h0f0f, 4'd4, 32'hf0f0); // XOR
        check(32'd1, 32'd31, 4'd5, 32'h80000000); // SLL
        check(32'h80000000, 32'd31, 4'd6, 32'd1); // SRL
        check(32'h80000000, 32'd31, 4'd7, 32'hffffffff); // SRA
        check(32'hffffffff, 32'd1, 4'd8, 32'd1); // signed SLT
        check(32'hffffffff, 32'd1, 4'd9, 32'd0); // unsigned SLTU
        check(32'h12345678, 32'd0, 4'd15, 32'd0); // unsupported op
        $display("PASS: directed ALU tests");
        $finish;
    end
endmodule
