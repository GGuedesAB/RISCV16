module control #(parameter instruction_size = 16)
(
    input wire [instruction_size-1:0] instruction,
    //EX Signals
    output wire ALUSrc,
    output wire [1:0] ALUOp,
    //MEM Signals
    output wire branch,
    output wire memWrite,
    //We won't use memory read signal
    //WB Signals
    output wire memToReg,
    output wire regWrite
);

wire [1:0] funct2 = instruction [7:6];
wire [1:0] opcode = instruction [1:0];

//EX Signals logic

//ALUSrc will be either and immediate or the second register
assign ALUSrc =
    (opcode == 2'b00) ? 1'b0 : //R-Type uses register
    (opcode == 2'b01) ? 1'b1 : //I-Type uses immediate
    (opcode == 2'b10) ? 1'b1 : //S-Type uses immediate
                        1'b0;  //B-Type uses register for comparison

//ALUOp is different from funct2 only for the load instruction
assign ALUOp =
    ((instruction[7:6] == 2'b01) && (instruction[1:0] == 2'b01)) ? 2'b00 :
                                                                   instruction[7:6];

//MEM Signals

assign branch =
    (opcode == 2'b11) ? 1'b1 : //Is a branch instruction
                        1'b0;  //Not a branch instruction

assign memWrite =
    (opcode == 2'b10 && funct2 == 2'b00) ? 1'b1 : //Is a store instruction
                                           1'b0;  //Not a store instruction

//WB Signals

assign memToReg =
    (opcode == 2'b01 && funct2 == 2'b01) ? 1'b1 : //Only loads uses memory output
                                           1'b0;  //Any other instruction will use the ALU's result

assign regWrite =
    (opcode == 2'b00) ? 1'b1 : //R-Type writes on registers
    (opcode == 2'b01) ? 1'b1 : //I-Type (load) writes on registres
                        1'b0;  //Any other instruction doesn't write on registers

endmodule