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
	input wire clk,rst,// ʱ�Ӻ͸�λ�ź�
	output wire[31:0] pcF,input wire[31:0] instrF,// ȡָ�׶�
	input wire pcsrcD,branchD,input wire jumpD,output wire equalD,output wire[5:0] opD,functD,	// ����/���Ĵ����׶�
	input wire memtoregE,input wire alusrcE,regdstE,input wire regwriteE,input wire[2:0] alucontrolE,output wire flushE, // ִ�н׶�
	input wire memtoregM,input wire regwriteM,output wire[31:0] aluoutM,writedataM,input wire[31:0] readdataM,// �洢�����ʽ׶�
	input wire memtoregW,input wire regwriteW // д�ؽ׶�
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

    // �Ĵ����ѵ�ʵ����
	regfile rf(.clk(clk),.we3(regwriteW),.ra1(rsD),.ra2(rtD),.wa3(writeregW),.wd3(resultW),.rd1(srcaD),.rd2(srcbD));

    //ð��ģ��
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
    //������һ�׶�pc
    //��һ���ֲ���decoder����ģ���Ϊû�мĴ����������Ҿ��������
    sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnext_tmp);
	mux2 #(32) pcmux(pcnext_tmp,{pcplus4D[31:28],instrD[25:0],2'b00},jumpD,pcnextFD);		    
	//���ָ��
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
    //F-D�Ĵ���
    flopenr #(32) r1D(clk,rst,~stallD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	// �з�����չ
	sign_extended se(instrD[15:0],signimmD);    
    //����ð�յ�����ǰ��
    mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	//Ԥ���֧
	eqcmp comp(srca2D,srcb2D,equalD);

//Execute
	//D-E�Ĵ���
	floprc #(32) r1E(clk,rst,flushE,srcaD,srcaE);
	floprc #(32) r2E(clk,rst,flushE,srcbD,srcbE);
	floprc #(32) r3E(clk,rst,flushE,signimmD,signimmE);
	floprc #(5) r4E(clk,rst,flushE,rsD,rsE);
	floprc #(5) r5E(clk,rst,flushE,rtD,rtE);
	floprc #(5) r6E(clk,rst,flushE,rdD,rdE);
    //����ð�յ�����ǰ��
	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	//ALU
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);
	alu alu1(srca2E,srcb3E,alucontrolE,aluoutE);
	//ѡ��д�ĸ��Ĵ���
	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE);
	
	//Memory
	//E-M�Ĵ���
	flopr #(32) r1M(clk,rst,srcb2E,writedataM);
	flopr #(32) r2M(clk,rst,aluoutE,aluoutM);
	flopr #(5) r3M(clk,rst,writeregE,writeregM);	
    
    //Write-back
    //�ĸ�ֵд���洢��
    mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW); // 32λ��һ����ѡ��
	//M-W�Ĵ���
	flopr #(32) r1W(clk,rst,aluoutM,aluoutW);
	flopr #(32) r2W(clk,rst,readdataM,readdataW);
	flopr #(5)  r3W(clk,rst,writeregM,writeregW);
endmodule
