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
	// ȡֵ�����롢ִ�С��洢����д������׶εĸ����ź�
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

	// ����ð�յ�����ǰ��(����)
	assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);    

    //����ð�յ�����ǰ��(ִ��)
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
	
	//����ð�յ���ͣ
	assign  lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	
	//����ð�յ���ͣ
	assign branchstallD = branchD & (regwriteE & (writeregE == rsD | writeregE == rtD) |memtoregM &(writeregM == rsD | writeregM == rtD));
	
	//��ͣ�źŵĴ���
	assign  stallD = lwstallD | branchstallD;
	assign  stallF = stallD;
	assign  flushE = stallD;    
endmodule
