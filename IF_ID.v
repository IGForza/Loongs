`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/03 16:06:10
// Design Name: 
// Module Name: IF_ID
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


module IF_ID(
    //input
    input clk,       
    input reset,     
    input flush,
    input keep,       
    input [32 -1:0]PC_i,      
    input [32 -1:0]Instruction_i,  
//output
    output reg [32 -1:0] PC_o,          
    output reg [32 -1:0]Instruction_o  
    );
    
    always @(posedge reset or posedge clk) begin
        if(reset) begin
            PC_o <= 32'h00000000;
            Instruction_o <= 32'h00000000;
        end
        else if (flush) begin
            PC_o <= 32'h00000000;
            Instruction_o <= 32'h00000000;
        end
        else if(keep) begin
            PC_o <= PC_o;
            Instruction_o <= Instruction_o;
        end
        else begin
            PC_o <= PC_i;
            Instruction_o <= Instruction_i;
        end
    end
    
    
endmodule
