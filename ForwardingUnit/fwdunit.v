module fwdunit 

(	input wire [3:0] IDEX_RS1,
	input wire [3:0] IDEX_RS2,
	input wire [3:0] MEMWB_RD,
	input wire [3:0] EXMEM_RD,
	input wire EXMEM_regWrite,
	input wire MEMWB_regWrite,
	output wire [1:0] forwardA,
	output wire [1:0] forwardB
);

assign forwardA =
	//EX Hazard
	((EXMEM_regWrite == 1'b1) && (EXMEM_RD != 4'b0) && (EXMEM_RD == IDEX_RS1)) ? 2'b10 :
	//MEM Hazard
	((MEMWB_regWrite == 1'b1) && (MEMWB_RD != 4'b0) && !((EXMEM_regWrite == 1'b1) && (EXMEM_RD != 4'b0) && (EXMEM_RD == IDEX_RS1)) && (MEMWB_RD == IDEX_RS1)) ? 2'b01 :
	//No Hazard
	2'b00;

assign forwardB =
	//EX Hazard
	((EXMEM_regWrite == 1'b1) && (EXMEM_RD != 4'b0) && (EXMEM_RD == IDEX_RS2)) ? 2'b10:
	//MEM Hazard
	((MEMWB_regWrite == 1'b1) && (MEMWB_RD != 4'b0) && !((EXMEM_regWrite == 1'b1) && (EXMEM_RD != 4'b0) && (EXMEM_RD == IDEX_RS2)) && (MEMWB_RD == IDEX_RS2)) ? 2'b01 : 
	//No Hazard
	2'b00;
	
endmodule