`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/03 17:01:28
// Design Name: 
// Module Name: MEM_WB
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


module MEM_WB(
//input
        input clk,  
        input reset,             
        //ControlSignals
        input RegWr_i,           
        input [2 -1:0] MemtoReg_i,     
        //ALUData&RegDst&MemWriteData
        input [32 -1:0] ALUOut_i,   
        input [32 -1:0] MemReadData_i,      
        input [5 -1:0] RegDstAddr_i,    
        input [32 -1:0] PC_i,            
//output
        output reg RegWr_o,            
        output reg [2 -1:0] MemtoReg_o,    
        output reg [32 -1:0] ALUOut_o,         
        output reg [32 -1:0] MemReadData_o,      
        output reg [5 -1:0] RegDstAddr_o,     
        output reg [32 -1:0] PC_o              //for jal
    );
    
    always @(posedge reset or posedge clk) begin
            if(reset) begin
                RegWr_o <= 1'b0;
                MemtoReg_o <= 2'b00;
                ALUOut_o <= 32'h00000000;
                MemReadData_o <= 32'h00000000;
                RegDstAddr_o <= 5'b00000;
                PC_o <= 32'h00000000;
            end
            else begin
                RegWr_o <= RegWr_i;
                MemtoReg_o <= MemtoReg_i;
                ALUOut_o <= ALUOut_i;
                MemReadData_o <= MemReadData_i;
                RegDstAddr_o <= RegDstAddr_i;
                PC_o <= PC_i;
            end
        end
endmodule
