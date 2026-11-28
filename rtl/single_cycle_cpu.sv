// Single-cycle core with a combinational instruction-memory read port.
// Unsupported instructions and misaligned jump targets hold PC and suppress writes.
module single_cycle_cpu #(
    parameter logic [31:0] RESET_PC = 32'h8000_0000
) (
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] pc,
    input  logic [31:0] instr,
    output logic        fault
);
    logic [31:0] regs [0:31];
    wire [4:0] rd = instr[11:7];
    wire [31:0] rs1_data = regs[instr[19:15]];
    wire [31:0] rs2_data = regs[instr[24:20]];
    wire [31:0] imm_i = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] imm_j = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

    logic [3:0] alu_op;
    logic [31:0] operand_b, alu_result, next_pc, write_data;
    wire [31:0] pc_plus_four = pc + 32'd4;

    alu arithmetic (.a(rs1_data), .b(operand_b), .op(alu_op), .result(alu_result));

    always_comb begin
        operand_b = rs2_data;
        alu_op = 4'd0; // ADD
        next_pc = pc_plus_four;
        fault = 1'b0;
        case (instr[6:0])
            7'b0010011: begin // ADDI
                operand_b = imm_i;
                fault = instr[14:12] != 3'b000;
            end
            7'b0110011: begin // ADD or SUB
                case ({instr[31:25], instr[14:12]})
                    10'b0000000_000: alu_op = 4'd0;
                    10'b0100000_000: alu_op = 4'd1;
                    default: fault = 1'b1;
                endcase
            end
            7'b1101111: begin // JAL
                next_pc = pc + imm_j;
                fault = next_pc[1:0] != 2'b00;
            end
            default: fault = 1'b1;
        endcase
    end

    assign write_data = (instr[6:0] == 7'b1101111) ? pc_plus_four : alu_result;

    always_ff @(posedge clk) begin
        if (reset) begin
            pc <= RESET_PC;
            for (int i = 0; i < 32; i++)
                regs[i] <= 32'b0;
        end else if (!fault) begin
            pc <= next_pc;
            if (rd != 5'd0)
                regs[rd] <= write_data;
        end
    end
endmodule
