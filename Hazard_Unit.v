`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/04 09:21:20
// Design Name: 
// Module Name: Hazard_Unit
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


module Hazard_Unit(
//input
    //for load-use
    input EX_MemRead,
    input [32 -1:0] RF_Instruction,
    //input [5 -1:0] EX_rt,
    //for beq RAW
    input RF_Branch,
    input EX_RegWr,
    input [5 -1:0] EX_RegDstAddr,
    //for beq load-use
    input MEM_RegWr,
    input MEM_RegDstAddr,
    input MEM_MemRead,
    //for beq&j-type
    input RF_PCSrc1,//beq?
    input [2 -1:0] RF_PCSrc2,//j?,0代表不jump
        //output
    output reg keep_IF_ID,
    output reg keep_PC,
    output reg [2 -1:0] flush 
    );
    
    parameter J = 6'b000010;
    parameter JAL = 6'b000011;
    parameter JR_FUNCT = 6'b001000;
    parameter SW = 6'b101011;
    
    always @(*) begin
        //load-use，注意判断不是load-store
        if(EX_RegWr && EX_RegDstAddr != 5'b00000 && EX_MemRead &&(EX_RegDstAddr == RF_Instruction[25:21] || EX_RegDstAddr == RF_Instruction[20:16]) && (RF_Instruction[31:26] != SW))
        begin
            keep_IF_ID <= 1'b1;
            keep_PC <= 1'b1;
            flush <= 2'b01;//flush ID/EX
        end
        //beq RAW
        else if(EX_RegWr && EX_RegDstAddr != 5'b00000 && RF_Branch && (EX_RegDstAddr == RF_Instruction[25:21] || EX_RegDstAddr == RF_Instruction[20:16]))
        begin
            keep_IF_ID <= 1'b1;
            keep_PC <= 1'b1;
            flush <= 2'b01;//flush ID/EX
        end
        //beq load-use:
        else if(MEM_RegWr && MEM_RegDstAddr != 5'b00000 && RF_Branch && MEM_MemRead && (MEM_RegDstAddr == RF_Instruction[25:21] || MEM_RegDstAddr == RF_Instruction[20:16]))
        begin
            keep_IF_ID <= 1'b1;
            keep_PC <= 1'b1;
            flush <= 2'b01;//flush ID/EX
        end
        //beq & j-type
        else if(RF_PCSrc1 || RF_Instruction[31:26] == J || RF_Instruction[31:26] == JAL
        || (RF_Instruction[31:26] == 6'b000000 && RF_Instruction[5:0] == JR_FUNCT))
        begin
            keep_IF_ID <= 1'b0;
            keep_PC <= 1'b0;
            flush <= 2'b10;//flush IF/ID
        end
        else
        begin
            keep_IF_ID <= 1'b0;
            keep_PC <= 1'b0;
            flush <= 2'b00;
        end
    end
    
endmodule
