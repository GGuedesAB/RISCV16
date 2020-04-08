module immediate_gen #(parameter instruction_size = 16)
(
    input wire [instruction_size-1:0] instruction,
    output wire [15:0] immediate
);

wire [1:0] opcode = instruction [1:0];

assign immediate =
    (opcode == 2'b00) ? 16'b0 :                                       //R-Type instructions have no immediate
    (opcode == 2'b01) ? {{13{instruction[15]}}, instruction[14:12]} : //I-Type (load) instructions
    (opcode == 2'b10) ? {{13{instruction[5]}}, instruction[4:2]} :    //S-Type instructions
                        {{13{instruction[5]}},instruction[4:2]};      //B-Type instructions (this is crazy)

endmodule