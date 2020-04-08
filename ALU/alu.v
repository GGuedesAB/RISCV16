module alu #(parameter word_size = 16) //Word size is actually word_size
(
    input wire  [1:0]           operation,
    input wire  [word_size-1:0] operandA,
    input wire  [word_size-1:0] operandB,
    output wire [word_size-1:0] result,
    output wire                 zero
);

assign result =
    (operation == 2'b00) ? operandA + operandB : //funct2 = 00 -> add
    (operation == 2'b01) ? operandA - operandB : //funct2 = 01 -> sub
    (operation == 2'b10) ? operandA & operandB : //funct2 = 10 -> and
                           operandA | operandB;  //funct2 = 11 -> or

assign zero =
    (result == 16'b0) ? 1'b1 :
                        1'b0;

endmodule
