// Symbolic, unconstrained input space. No clock: a combinational proof.
module alu_properties;
    (* anyconst *) logic [31:0] a;
    (* anyconst *) logic [31:0] b;
    (* anyconst *) logic [3:0]  op;
    wire [31:0] result;
    alu dut (.a(a), .b(b), .op(op), .result(result));

    always_comb begin
        case (op)
            4'd0: assert (result == (a + b));
            4'd1: assert (result == (a - b));
            4'd2: assert (result == (a & b));
            4'd3: assert (result == (a | b));
            4'd4: assert (result == (a ^ b));
            4'd5: assert (result == (a << b[4:0]));
            4'd6: assert (result == (a >> b[4:0]));
            // Keep the comparison signed so SRA replicates the sign bit.
            4'd7: assert ($signed(result) == ($signed(a) >>> b[4:0]));
            4'd8: assert (result == {31'b0, ($signed(a) < $signed(b))});
            4'd9: assert (result == {31'b0, (a < b)});
            default: assert (result == 32'b0);
        endcase
    end
endmodule
