`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/20 15:12:22
// Design Name: 
// Module Name: datapath
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


module datapath(
	input wire clk,rst,// 时钟和复位信号
	output wire[31:0] pcF,input wire[31:0] instrF,// 取指阶段
	input wire pcsrcD,branchD,input wire jumpD,output wire equalD,output wire[5:0] opD,functD,	// 译码/读寄存器阶段
	input wire memtoregE,input wire alusrcE,regdstE,input wire regwriteE,input wire[2:0] alucontrolE,output wire flushE, // 执行阶段
	input wire memtoregM,input wire regwriteM,output wire[31:0] aluoutM,writedataM,input wire[31:0] readdataM,// 存储器访问阶段
	input wire memtoregW,input wire regwriteW // 写回阶段
    );	
	
	wire stallF;
	wire [31:0] pcnextFD,pcnext_tmp,pcplus4F,pcbranchD;
	wire [31:0] pcplus4D,instrD;
	wire [4:0] rsD,rtD,rdD,writeregM,writeregW;
	wire flushD,stallD,forwardaD,forwardbD;
	wire [31:0] signimmD,signimmshD,srcaD,srca2D,srcbD,srcb2D;
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE,writeregE;
	wire [31:0] signimmE,srcaE,srca2E,srcbE,srcb2E,srcb3E,aluoutE,aluoutW,readdataW,resultW;

    // 寄存器堆的实例化
	regfile rf(.clk(clk),.we3(regwriteW),.ra1(rsD),.ra2(rtD),.wa3(writeregW),.wd3(resultW),.rd1(srcaD),.rd2(srcbD));

    //冒险模块
    hazard h(.rsD(rsD),.rtD(rtD),.branchD(branchD),
	.forwardaD(forwardaD),.forwardbD(forwardbD), .stallF(stallF),.stallD(stallD),
	.rsE(rsE),.rtE(rtE),.writeregE(writeregE),
	.regwriteE(regwriteE),.memtoregE(memtoregE),.flushE(flushE),
	.forwardaE(forwardaE),.forwardbE(forwardbE),
	.writeregM(writeregM),
	.regwriteM(regwriteM), .memtoregM(memtoregM),.regwriteW(regwriteW),
	.writeregW(writeregW)
    );

    //Fetch  
	pc pcreg(clk,rst,~stallF,pcnextFD,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);

    //Decode
    //处理下一阶段pc
    //有一部分不是decoder里面的，因为没有寄存器阻塞，我就提出来了
    sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnext_tmp);
	mux2 #(32) pcmux(pcnext_tmp,{pcplus4D[31:28],instrD[25:0],2'b00},jumpD,pcnextFD);		    
	//解读指令
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
    //F-D寄存器
    flopenr #(32) r1D(clk,rst,~stallD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	// 有符号拓展
	sign_extended se(instrD[15:0],signimmD);    
    //控制冒险的数据前推
    mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	//预测分支
	eqcmp comp(srca2D,srcb2D,equalD);

//Execute
	//D-E寄存器
	floprc #(32) r1E(clk,rst,flushE,srcaD,srcaE);
	floprc #(32) r2E(clk,rst,flushE,srcbD,srcbE);
	floprc #(32) r3E(clk,rst,flushE,signimmD,signimmE);
	floprc #(5) r4E(clk,rst,flushE,rsD,rsE);
	floprc #(5) r5E(clk,rst,flushE,rtD,rtE);
	floprc #(5) r6E(clk,rst,flushE,rdD,rdE);
    //数据冒险的数据前推
	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	//ALU
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);
	alu alu1(srca2E,srcb3E,alucontrolE,aluoutE);
	//选择写哪个寄存器
	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE);
	
	//Memory
	//E-M寄存器
	flopr #(32) r1M(clk,rst,srcb2E,writedataM);
	flopr #(32) r2M(clk,rst,aluoutE,aluoutM);
	flopr #(5) r3M(clk,rst,writeregE,writeregM);	
    
    //Write-back
    //哪个值写进存储器
    mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW); // 32位的一个多选器
	//M-W寄存器
	flopr #(32) r1W(clk,rst,aluoutM,aluoutW);
	flopr #(32) r2W(clk,rst,readdataM,readdataW);
	flopr #(5)  r3W(clk,rst,writeregM,writeregW);
endmodule
