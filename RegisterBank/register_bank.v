module register_bank //#(parameter reg_bank_size = 4, //Memory size is 2^mem_size
							//	parameter word_size = 16) //Word size is actually word_size
(	input wire clk,
	input wire we,
	//Print register
	output wire [15:0] printRegOneData,
	output wire [15:0] printRegTwoData,
	output wire [15:0] printRegThreeData,
	//RS1 Signals
	input wire [3:0] regRSOneread_addr,
	output wire [15:0] regRSOneread_data,
	//RS2 Signals
	input wire [3:0] regRSTworead_addr,
	output wire [15:0] regRSTworead_data,
	//RD Signals
	input wire [3:0] regRD_addr,
	input wire [15:0] regRD_data
);

reg [15:0] reg_bank [15:0];

//Forces 0 if reading R0
assign regRSOneread_data = 
	(regRSOneread_addr == 4'b0) ? 16'b0 :
	//This deals with pre-written data forwarding
	//when the instruction on ID is fetching data that is on WB
	((regRSOneread_addr == regRD_addr) && (regRSOneread_addr != 4'b0)) ? regRD_data :
	reg_bank[regRSOneread_addr];

//Forces 0 if reading R0	
assign regRSTworead_data = 
	(regRSTworead_addr == 4'b0) ? 16'b0 :
	//This deals with pre-written data forwarding
	//when the instruction on ID is fetching data that is on WB
	((regRSTworead_addr == regRD_addr) && (regRSTworead_addr != 4'b0)) ? regRD_data :
	reg_bank[regRSTworead_addr];
	
assign printRegOneData = reg_bank[4'b1111];
assign printRegTwoData = reg_bank[4'b1110];
assign printRegThreeData = reg_bank[4'b1101];

always @ (posedge clk)
begin
	if (we == 1'b1 && (regRD_addr != 4'b0))
	begin
		reg_bank [regRD_addr] = regRD_data;
	end
end
endmodule
