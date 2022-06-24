`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/19 10:41:40
// Design Name: 
// Module Name: controller
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


module controller(
	input wire clk,rst,
	input wire[5:0] opD,functD, // 译码阶段使用的输入
	output wire pcsrcD,branchD,equalD,jumpD, // 译码阶段的输出
	input wire flushE,// 执行阶段使用的输入
	output wire memtoregE,alusrcE,regdstE,regwriteE,// 执行阶段的输出
	output wire[2:0] alucontrolE,
	output wire memtoregM,memwriteM,regwriteM,	// 存储器阶段的输出
	output wire memtoregW,regwriteW // 写回阶段的输出信号
    );
    
	wire[1:0] alu_opD;
	wire memtoregD,memwriteD,alusrcD,regdstD,regwriteD;
	wire[2:0] alucontrolD;
	wire memwriteE;
	
    main_decoder md(
        .op(opD),
        .memtoreg(memtoregD),
        .memwrite(memwriteD),
        .branch(branchD),
        .alusrc(alusrcD),
        .regdst(regdstD),
        .regwrite(regwriteD),
        .jump(jumpD),
        .aluop(alu_opD)
    );
    
    alu_decoder ad(
        .funct(functD),
        .aluop(alu_opD),
        .alucontrol(alucontrolD)
    );
    assign pcsrcD = branchD & equalD;
    
    //流水线向前输送
    floprc #(8) regE(clk,rst,flushE,{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD},{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE});
	flopr #(3)  regM(clk,rst,{memtoregE,memwriteE,regwriteE},{memtoregM,memwriteM,regwriteM});
	flopr #(2)  regW(clk,rst,{memtoregM,regwriteM},{memtoregW,regwriteW});
        
endmodule
