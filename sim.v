`timescale 1ns / 1ns
module sim ();

reg clock;
reg reset;
reg write_enable;
wire clk;
wire rst;
wire we;
assign clk = clock;
assign rst = reset;
assign we = write_enable;
wire [15:0] printRegOneData;
wire [15:0] printRegTwoData;
wire [15:0] printRegThreeData;

rv16r proc (clk, rst, we, printRegOneData, printRegTwoData, printRegThreeData);

always #1 clock = ~clock;

initial begin
    $dumpfile("my_dumpfile.vcd");
    $dumpvars(0, sim);
    $readmemh("program.hex", proc.Instructions.ram, 0, 1023);
    #1 reset = 1;
    #1 clock = 0;
    #5 reset = 0;
    #500 $finish;
end
endmodule