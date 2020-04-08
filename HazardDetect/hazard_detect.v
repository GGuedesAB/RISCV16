`timescale 1ns/1ns
module hazard_detect
(
    input wire IDEX_memToReg,
    input wire [3:0] IDEX_RD,
    input wire [3:0] IFID_RS1,
    input wire [3:0] IFID_RS2,
    output wire select
);

//If output == 1 (stall pipeline sending nop)
assign select =
    ((IDEX_memToReg == 1'b1) && ((IDEX_RD == IFID_RS1) || (IDEX_RD == IFID_RS2))) ? 1'b1 : 1'b0;

endmodule