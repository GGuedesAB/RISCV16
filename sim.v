`timescale 1ns/1ns
module sim ();

reg clock;
reg reset;
reg write_enable;
reg finish;
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

always @ (posedge finish)
begin
    $display("Output terminal: \n  R13 = %5d\n  R14 = %5d\n  R15 = %5d", printRegThreeData, printRegTwoData, printRegOneData);
end

always #1 clock = ~clock;

initial begin
    $dumpfile("my_dumpfile.vcd");
    $dumpvars(0, sim);
    $readmemh("program.hex", proc.Instructions.ram, 0, 1023);
    #0 reset = 1;
    #0 clock = 0;
    #2 reset = 0;
    #500 finish = 1;
    #0 $finish;
end
endmodule