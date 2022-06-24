`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/19 16:59:01
// Design Name: 
// Module Name: hazard
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module hazard(
	// 取值、译码、执行、存储器、写回五个阶段的各个信号
	input wire[4:0] rsD,rtD,
	input wire branchD,
	output wire forwardaD,forwardbD, stallF,stallD,
	input wire[4:0] rsE,rtE,writeregE,
	input wire regwriteE,memtoregE,flushE,
	output reg[1:0] forwardaE,forwardbE,
	input wire[4:0] writeregM,
	input wire regwriteM, memtoregM,regwriteW,
	input wire[4:0] writeregW
    );
    
    wire lwstallD,branchstallD;

	// 控制冒险的数据前推(译码)
	assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);    

    //数据冒险的数据前推(执行)
	always @(*) begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if(rsE != 0) begin
			if(rsE == writeregM & regwriteM) begin
				forwardaE = 2'b10;
			end else if(rsE == writeregW & regwriteW) begin
				forwardaE = 2'b01;
			end
		end
		if(rtE != 0) begin
			if(rtE == writeregM & regwriteM) begin
				forwardbE = 2'b10;
			end else if(rtE == writeregW & regwriteW) begin
				forwardbE = 2'b01;
			end
		end
	end
	
	//数据冒险的暂停
	assign  lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	
	//控制冒险的暂停
	assign branchstallD = branchD & (regwriteE & (writeregE == rsD | writeregE == rtD) |memtoregM &(writeregM == rsD | writeregM == rtD));
	
	//暂停信号的传递
	assign  stallD = lwstallD | branchstallD;
	assign  stallF = stallD;
	assign  flushE = stallD;    
endmodule
