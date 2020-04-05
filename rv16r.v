module rv16r 
(
	input wire clk,
	input wire rst,
	output wire [15:0] printRegOneData,
	output wire [15:0] printRegTwoData,
	output wire [15:0] printRegThreeData
);

//Pipeline registers IF/ID
//Data registers
reg [15:0] IFID_instruction;
reg [15:0] IFID_PC;

//Pipeline registers ID/EX
//Data registers
reg [15:0] IDEX_instruction;
reg [15:0] IDEX_PC;
reg [15:0] IDEX_contentOfRSOne;
reg [15:0] IDEX_contentOfRSTwo;
reg [15:0] IDEX_immediate;

//Control registers (Forwarding unit)
reg [3:0]  IDEX_RS1;
reg [3:0]  IDEX_RS2;
reg [3:0]  IDEX_RDAddress;
//Control registers
reg [1:0]  IDEX_ALUOp;
reg        IDEX_ALUSrc;
reg        IDEX_branch;
reg        IDEX_memWrite;
reg        IDEX_memToReg;
reg        IDEX_regWrite;

//Pipeline registers EX/MEM
//Data registers
reg [15:0] EXMEM_instruction;
reg [15:0] EXMEM_branchPC;
reg [15:0] EXMEM_ALUResult;
reg [15:0] EXMEM_contentOfRSTwo;
reg [3:0] EXMEM_RDAddress;
//Control registers
reg        EXMEM_zero;
reg        EXMEM_branch;
reg        EXMEM_memWrite;
reg        EXMEM_memToReg;
reg        EXMEM_regWrite;

//Pipeline registers MEM/WB
//Data registers
reg [15:0] MEMWB_instruction;
reg [15:0] MEMWB_memoryData;
reg [15:0] MEMWB_ALUResult;
reg [3:0]  MEMWB_RDAddress;
//Control registers
reg        MEMWB_PCSrc;
reg        MEMWB_memToReg;
reg        MEMWB_regWrite;

//Organization intrinsic wires and registers
wire [15:0] aluFirstOperand;
wire [15:0] aluSecondOperand;
wire [15:0] writeBackData;
wire [15:0] RSOneData;
wire [15:0] RSTwoData;
wire [15:0] RSTwoRealData;
wire [15:0] next_instruction;
wire [15:0] instruction;
//wire [15:0] next_instruction;
wire [15:0] immediate;
wire [15:0] memoryData;
wire        ALUSrc;
wire [1:0]  ALUOp;
wire        branch;
wire        memWrite;
wire        memToReg;
wire        regWrite;
wire [15:0] ALUResult;
wire        zero;
wire PCSrc;
wire [1:0] forwardA;
wire [1:0] forwardB;
wire stall;
reg [15:0] PC;

wire [15:0] instr_mem_data;

//Components instantiation

register_bank Registers (clk, MEMWB_regWrite, printRegOneData, printRegTwoData, printRegThreeData,
								IFID_instruction[11:8], RSOneData, IFID_instruction[15:12], 
								RSTwoData, MEMWB_RDAddress, writeBackData);
															 
instruction_memory Instructions (PC, clk, instr_mem_data, we, rst, next_instruction);

immediate_gen Imm_Gen (IFID_instruction, immediate);

data_memory Data_Mem (EXMEM_ALUResult, clk, EXMEM_contentOfRSTwo, EXMEM_memWrite, rst, memoryData);

control Control_Unit (IFID_instruction, ALUSrc, ALUOp, branch, memWrite, memToReg, regWrite);

fwdunit Forwarding_Unit (IDEX_RS1, IDEX_RS2, MEMWB_RDAddress, EXMEM_RDAddress, EXMEM_regWrite, MEMWB_regWrite, forwardA, forwardB);

hazard_detect Hazard_Detection (IDEX_memToReg, IDEX_RDAddress, IFID_instruction[11:8], IFID_instruction[15:12], stall);

alu ALU (IDEX_ALUOp, aluFirstOperand, aluSecondOperand, ALUResult, zero);

assign outputInstruction = IFID_instruction;

//Forward to store
assign RSTwoRealData =
	//EX Hazard
	((forwardB == 2'b10)) ? EXMEM_ALUResult : 
	//MEM Hazard
	((forwardB == 2'b01)) ? writeBackData :
	//No Hazard
	IDEX_contentOfRSTwo;

//Mux1 ALU
assign aluFirstOperand =
	//EX Hazard
	((forwardA == 2'b10)) ? EXMEM_ALUResult : 
	//MEM Hazard
	((forwardA == 2'b01)) ? writeBackData :
	//No Hazard
	IDEX_contentOfRSOne;	
	
//Mux2 ALU
assign aluSecondOperand =
	//Only forward if second operand is a register, in case of immediate there is no need to forward.
	//This may seem unnecessary, but if you tried to operate a register with an immediate that was 
	//equal to that register's address it would forward that register intead of using the immediate.
	//Example: R2 = R2 + 2 would become R2 = R2 + R2.
	
	//EX Hazard
	((IDEX_ALUSrc == 1'b0) && (forwardB == 2'b10)) ? EXMEM_ALUResult :
	//MEM Hazard
	((IDEX_ALUSrc == 1'b0) && (forwardB == 2'b01)) ? writeBackData :
	//No Hazard
	((IDEX_ALUSrc == 1'b0) && (forwardB == 2'b00)) ? IDEX_contentOfRSTwo :
	//Not a register
	IDEX_immediate;

//And PC
//PCSrc = 1 means branch was taken
assign PCSrc = EXMEM_zero & EXMEM_branch;

assign instruction =
	(PCSrc == 1'b1 || MEMWB_PCSrc == 1'b1) ? 16'b0 :
	next_instruction;

//Mux Write Back
assign writeBackData =
	(MEMWB_memToReg == 1'b1) ? MEMWB_memoryData :
	MEMWB_ALUResult;
	
always @ (posedge clk)
begin
	//Initializing processor.
	if (rst == 1'b1)
	begin
	   PC <= 16'b0;
		IFID_instruction <= 16'b0;
		IFID_PC <= 16'b0;

		//Pipeline registers ID/EX
		//Data registers
		IDEX_instruction <= 16'b0;
		IDEX_PC <= 16'b0;
		IDEX_contentOfRSOne <= 16'b0;
		IDEX_contentOfRSTwo <= 16'b0;
		IDEX_immediate <= 16'b0;

		//Control registers (Forwarding unit)
		IDEX_RS1 <= 4'b0;
		IDEX_RS2 <= 4'b0;
		IDEX_RDAddress <= 4'b0;
		//Control registers
		IDEX_ALUOp <= 2'b0;
		IDEX_ALUSrc <= 1'b0;
		IDEX_branch <= 1'b0;
		IDEX_memWrite <= 1'b0;
		IDEX_memToReg <= 1'b0;
		IDEX_regWrite <= 1'b0;

		//Pipeline registers EX/MEM
		//Data registers
		EXMEM_instruction <= 16'b0;
		EXMEM_branchPC <= 16'b0;
		EXMEM_ALUResult <= 16'b0;
		EXMEM_contentOfRSTwo <= 16'b0;
		EXMEM_RDAddress <= 4'b0;
		//Control registers
		EXMEM_zero <= 1'b0;
		EXMEM_branch <= 1'b0;
		EXMEM_memWrite <= 1'b0;
		EXMEM_memToReg <= 1'b0;
		EXMEM_regWrite <= 1'b0;
		//Pipeline registers MEM/WB
		//Data registers
		MEMWB_instruction <= 16'b0;
		MEMWB_memoryData <= 16'b0;
		MEMWB_ALUResult <= 16'b0;
		MEMWB_RDAddress <= 4'b0;
		//Control registers
		MEMWB_PCSrc <= 1'b0;
		MEMWB_memToReg <= 1'b0;
		MEMWB_regWrite <= 1'b0;
	end
	
	else
	begin
		
		//Determines the case of branch, stall or normal execution
		if (PC >= 16'h0fff)
		begin
			PC <= 16'h0fff;
		end
		else if (PCSrc == 1'b1)
		begin
			PC <= EXMEM_branchPC;
		end
		else if (stall == 1'b1)
		begin
			PC <= PC;
		end
		else
		begin
			PC <= PC+16'b1;
		end
	
		//IFID new signal creation
		//Stall condition
		if (stall == 1'b1)
		begin
			IFID_instruction <= IFID_instruction;
			IFID_PC <= IFID_PC;
		end
		
		//Branch taken condition
		else if (PCSrc == 1'b1)
		begin
			IFID_instruction <= 16'b0;
			IFID_PC <= 16'b0;
		end
		
		else
		begin
			IFID_instruction <= instruction;
			IFID_PC <= PC;
		end
		
		//IFID to IDEX
		//Data registers
		//Stall condition
		if (stall == 1'b1 || PCSrc == 1'b1)
		begin
			IDEX_instruction <= 16'b0;
			IDEX_PC <= 16'b0;
			
			//IDEX new signal creation
			//Coming from control unit
			IDEX_ALUSrc <= 1'b0;
			IDEX_ALUOp <= 2'b0;
			IDEX_branch <= 1'b0;
			IDEX_memWrite <= 1'b0;
			IDEX_memToReg <= 1'b0;
			IDEX_regWrite <= 1'b0;
			IDEX_contentOfRSOne <= 16'b0;
			IDEX_contentOfRSTwo <= 16'b0;
			
			//Coming from immediate generator
			IDEX_immediate <= 16'b0;
			
			//Forwarding unit register name signals
			IDEX_RS1 <= 4'b0;
			IDEX_RS2 <= 4'b0;
			IDEX_RDAddress <= 4'b0;
		
		end
		
		else
		begin
			IDEX_instruction <= IFID_instruction;
			IDEX_PC <= IFID_PC;
			//Control register
			
			//IDEX new signal creation
			//Coming from control unit
			IDEX_ALUSrc <= ALUSrc;
			IDEX_ALUOp <= ALUOp;
			IDEX_branch <= branch;
			IDEX_memWrite <= memWrite;
			IDEX_memToReg <= memToReg;
			IDEX_regWrite <= regWrite;
		
			//Coming from register bank
			IDEX_contentOfRSOne <= RSOneData;
			IDEX_contentOfRSTwo <= RSTwoData;
			
			//Coming from immediate generator
			IDEX_immediate <= immediate;
			
			//Forwarding unit register name signals
			IDEX_RS1 <= IFID_instruction [11:8];
			IDEX_RS2 <= IFID_instruction [15:12];
			IDEX_RDAddress <= IFID_instruction [5:2];
		end
		
		
		if (PCSrc == 1'b1)
		begin
			//PC Branch Calculation
			EXMEM_instruction <= 16'b0;
			EXMEM_branchPC <= 16'b0;
		
			//EXMEM new signal creation
			EXMEM_ALUResult <= 16'b0;
		
			//IDEX to EXMEM
			//Data registers
			EXMEM_RDAddress <= 4'b0;
			EXMEM_contentOfRSTwo <= 16'b0;
			//Control registers
			EXMEM_zero = 1'b0;
			EXMEM_branch <= 1'b0;
			EXMEM_memWrite <= 1'b0;
			EXMEM_memToReg <= 1'b0;
			EXMEM_regWrite <= 1'b0;
		end
		
		else
		begin
			//PC Branch Calculation
			EXMEM_instruction <= IDEX_instruction;
			EXMEM_branchPC <= IDEX_PC + IDEX_immediate;
			
			//EXMEM new signal creation
			EXMEM_ALUResult <= ALUResult;
			
			//IDEX to EXMEM
			//Data registers
			EXMEM_RDAddress <= IDEX_RDAddress;
			EXMEM_contentOfRSTwo <= RSTwoRealData;
			//Control registers
			EXMEM_zero = zero;
			EXMEM_branch <= IDEX_branch;
			EXMEM_memWrite <= IDEX_memWrite;
			EXMEM_memToReg <= IDEX_memToReg;
			EXMEM_regWrite <= IDEX_regWrite;
		end
		
		//EXMEM to MEMWB
		//Data registers
		MEMWB_PCSrc <= PCSrc;
		MEMWB_instruction <= EXMEM_instruction;
		MEMWB_RDAddress <= EXMEM_RDAddress;
		MEMWB_ALUResult <= EXMEM_ALUResult;
		//Control registers
		MEMWB_regWrite <= EXMEM_regWrite;
		MEMWB_memToReg <= EXMEM_memToReg;
		
		
		//MEMWB new signal creation
		MEMWB_memoryData <= memoryData;
	end
end
endmodule