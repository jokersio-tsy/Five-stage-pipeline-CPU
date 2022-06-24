`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/04 21:20:20
// Design Name: 
// Module Name: main_decoder
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


module main_decoder (
input wire [5:0] op ,
output wire jump ,
output wire branch ,
output wire alusrc ,
output wire memwrite ,
output wire memtoreg ,
output wire regwrite ,
output wire regdst ,
output wire [1:0] aluop
);

    reg [8:0] tmp_control ;
    assign { regwrite , regdst , alusrc , branch , memwrite , memtoreg , jump , aluop } = tmp_control;
    always@(op) begin
        case(op)
            6'b000000:tmp_control<=9'b110000010;//R
            6'b100011:tmp_control<=9'b101001000;//lw
            6'b101011:tmp_control<=9'b001010000;//sw
            6'b000100:tmp_control<=9'b000100001;//beq
            6'b001000:tmp_control<=9'b101000000;//addi
            6'b000010:tmp_control<=9'b000000100;//j
            default: tmp_control<=9'bzzzzzzzzz;
        endcase
    end
        
    
endmodule
