`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 13:50:53
// Design Name: 
// Module Name: top
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


module top(
	input wire clk,rst,
	output wire[31:0] writedata,dataadr,pc,instr,
	output wire memwrite
    );

	wire[31:0] readdata;

	mips mips(clk,rst,pc,instr,memwrite,dataadr,writedata,readdata);
	signlerom imem(.clka(~clk),.addra(pc[9:2]),.douta(instr));
	singleram dmem(.clka(~clk),.wea(memwrite),.addra(dataadr),
	               .dina(writedata),.douta(readdata));
endmodule
