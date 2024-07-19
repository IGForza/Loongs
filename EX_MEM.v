`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/03 16:47:20
// Design Name: 
// Module Name: EX_MEM
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


module EX_MEM(
//input
        input clk,  
        input reset,         
        input flush,      
        //ControlSignals
        input RegWr_i,       
        input MemRead_i ,      
        input MemWr_i,       
        input [2 -1:0] MemtoReg_i,     
        //ALUData&RegDst&MemWriteData
        input [32 -1:0] ALUOut_i,   
        input [32 -1:0] MemWrData_i,      
        input [5 -1:0] RegDstAddr_i,
        input [5 -1:0] EX_rt,    
        input [32 -1:0] PC_i,            
//output
        output reg RegWr_o,       
        output reg MemRead_o,       
        output reg MemWr_o,        
        output reg [2 -1:0] MemtoReg_o,    
        output reg [32 -1:0] ALUOut_o,         
        output reg [32 -1:0] MemWrData_o,      
        output reg [5 -1:0] RegDstAddr_o,
        output reg [5 -1:0] MEM_rt,     
        output reg [32 -1:0] PC_o              //for jal
    );
    
        always @(posedge reset or posedge clk) begin
        if(reset) begin
            RegWr_o <= 1'b0;
            MemRead_o <= 1'b0;
            MemWr_o <= 1'b0;
            MemtoReg_o <= 2'b00;
            ALUOut_o <= 32'h00000000;
            MemWrData_o <= 32'h00000000;
            RegDstAddr_o <= 5'b00000;
            MEM_rt <= 5'b00000;
            PC_o <= 32'h00000000;
        end
        else if (flush) begin
            RegWr_o <= 1'b0;
            MemRead_o <= 1'b0;
            MemWr_o <= 1'b0;
            MemtoReg_o <= 2'b00;
            ALUOut_o <= 32'h00000000;
            MemWrData_o <= 32'h00000000;
            RegDstAddr_o <= 5'b00000;
            MEM_rt <= 5'b00000;
            PC_o <= 32'h00000000;
        end
        else begin
            RegWr_o <= RegWr_i;
            MemRead_o <= MemRead_i;
            MemWr_o <= MemWr_i;
            MemtoReg_o <= MemtoReg_i;
            ALUOut_o <= ALUOut_i;
            MemWrData_o <= MemWrData_i;
            RegDstAddr_o <= RegDstAddr_i;
            MEM_rt <= EX_rt;
            PC_o <= PC_i;
        end
    end
    
endmodule
