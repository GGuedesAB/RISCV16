`timescale 1ns/1ns
module instruction_memory
#(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=16, parameter MEM_SIZE=1024)
(
    input [(ADDR_WIDTH-1):0] addr,
    input clk,
    input [(DATA_WIDTH-1):0] data,
    input we,
    input rst,
    output [(DATA_WIDTH-1):0] q
);

    wire clear_program;
    assign clear_program = 1'b0;

    // Declare the RAM variable
    reg [DATA_WIDTH-1:0] ram [MEM_SIZE-1:0];
    integer i;
    wire [9:0] internal_addr;
    assign internal_addr = addr[9:0];
    always @ (posedge clk)
    begin
        // Write
        if (we)
        begin
            ram[internal_addr] <= data;
        end
        else
        begin
            for (i=0;i<(ADDR_WIDTH-1); i=i+1)
            begin
                if (clear_program)
                begin
                    ram[i] <= 16'b0;
                end
                else
                begin
                    ram[i] <= ram[i];
                end
            end
        end
    end
    // Continuous assignment implies read returns NEW data.
    // This is the natural behavior of the TriMatrix memory
    // blocks in Single Port mode.
    assign q = ram[internal_addr];

endmodule
