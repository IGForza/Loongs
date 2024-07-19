`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/04 09:50:52
// Design Name: 
// Module Name: Forward_UnitA
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


module Forward_UnitA(
//input
    input [5 -1:0] MEM_RegDstAddr,
    input  [32 -1:0] RF_Instruction,
    input MEM_RegWr,
//output
    output reg RF_Comp_rsSrc,
    output reg RF_Comp_rtSrc,
    output reg RF_jrSrc      
    );
    
    //beq ID/RF阶段判断需要的转发
    //同时也判断jal-jr紧紧相连的转发
    always @(*) begin
        //beq 从前前条转发，因为如果是前一条一定会stall
        if(MEM_RegWr && MEM_RegDstAddr == RF_Instruction[25:21] && MEM_RegDstAddr == RF_Instruction[20:16] && MEM_RegDstAddr != 5'b00000) begin
            RF_Comp_rtSrc <= 1'b1;
            RF_Comp_rsSrc <= 1'b1;
        end
        else if (MEM_RegWr && MEM_RegDstAddr == RF_Instruction[25:21]&& MEM_RegDstAddr != 5'b00000) begin
            RF_Comp_rtSrc <= 1'b0;
            RF_Comp_rsSrc <= 1'b1;
        end
        else if(MEM_RegWr && MEM_RegDstAddr == RF_Instruction[20:16]&& MEM_RegDstAddr != 5'b00000) begin
            RF_Comp_rtSrc <= 1'b1;
            RF_Comp_rsSrc <= 1'b0;
        end
        else begin
            RF_Comp_rtSrc <= 1'b0;
            RF_Comp_rsSrc <= 1'b0;
        end
        //jal-jr
        if(MEM_RegWr && MEM_RegDstAddr == 5'b11111) RF_jrSrc <= 1'b1;
        else RF_jrSrc <= 1'b0;
    end
    
endmodule
