`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/04 10:08:39
// Design Name: 
// Module Name: Forward_UnitB
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


module Forward_UnitB(
//input
    input [5 -1:0] MEM_RegDstAddr,
    input MEM_RegWr,
    input [5 -1:0] WB_RegDstAddr,
    input WB_RegWr,
    input [5 -1:0] EX_rt,
    input [5 -1:0] EX_rs,
//output
    output reg [2 -1:0] ALUinASrc,
    output reg [2 -1:0] ALUinBSrc
    );
    
    //ALU input forwarding
    always @(*) begin
        //rs
        if(MEM_RegWr && MEM_RegDstAddr != 5'b00000 && MEM_RegDstAddr == EX_rs)
            ALUinASrc <= 2'b10; //表示从EX/MEM转发
        else if(WB_RegWr && WB_RegDstAddr != 5'b00000 && WB_RegDstAddr == EX_rs &&(MEM_RegDstAddr != EX_rs || ~MEM_RegWr))
            ALUinASrc <= 2'b01; //表示从MEM/WB转发
        else  ALUinASrc <= 2'b00; //表示不转发 
        
        //rt
        if(MEM_RegWr && MEM_RegDstAddr != 5'b00000 && MEM_RegDstAddr == EX_rt)
            ALUinBSrc <= 2'b10; //表示从EX/MEM转发
        else if(WB_RegWr && WB_RegDstAddr != 5'b00000 && WB_RegDstAddr == EX_rt &&(MEM_RegDstAddr != EX_rt || ~MEM_RegWr))
            ALUinBSrc <= 2'b01; //表示从MEM/WB转发
        else  ALUinBSrc <= 2'b00; //表示不转发 
    end
    
endmodule
