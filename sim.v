module sim ();

reg clock;
reg reset;

assign clk = clock;
assign rst = reset;
wire [15:0] printRegOneData;
wire [15:0] printRegTwoData;
wire [15:0] printRegThreeData;

rv16r proc (clk, rst, printRegOneData, printRegTwoData, printRegThreeData);

always #1 clock = ~clock;
	
initial begin
	$dumpfile("my_dumpfile.vcd"); 
	$dumpvars(0, sim);
	$readmemh("program.hex", proc.Instructions.ram, 0, 65535);
	#1 reset = 1;
    #1 clock = 0;
    #5 reset = 0;
	#500 $finish;
end
endmodule