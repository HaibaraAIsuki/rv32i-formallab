// Educational RV32I integer ALU (combinational).
// op: ADD=0 SUB=1 AND=2 OR=3 XOR=4 SLL=5 SRL=6 SRA=7 SLT=8 SLTU=9
module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  op,
    output logic [31:0] result
);
    localparam logic [3:0]
        OP_ADD  = 4'd0, OP_SUB = 4'd1,
        OP_AND  = 4'd2, OP_OR  = 4'd3, OP_XOR = 4'd4,
        OP_SLL  = 4'd5, OP_SRL = 4'd6, OP_SRA = 4'd7,
        OP_SLT  = 4'd8, OP_SLTU = 4'd9;

    always_comb begin
        result = 32'b0;
        case (op)
            OP_ADD:  result = a + b;
            OP_SUB:  result = a - b;
            OP_AND:  result = a & b;
            OP_OR:   result = a | b;
            OP_XOR:  result = a ^ b;
            OP_SLL:  result = a << b[4:0];
            OP_SRL:  result = a >> b[4:0];
            OP_SRA:  result = $signed(a) >>> b[4:0];
            OP_SLT:  result = {31'b0, ($signed(a) < $signed(b))};
            OP_SLTU: result = {31'b0, (a < b)};
            default: result = 32'b0; // Unsupported opcode (learning convention).
        endcase
    end
endmodule
