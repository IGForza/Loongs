`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/03 16:16:37
// Design Name: 
// Module Name: ID_EX
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


module ID_EX(
//input
        input clk,     
        input reset,   
        input flush,      
        //ControlUnitOutput
        input RegWr_i,         
        input ALUSrc1_i,       
        input ALUSrc2_i,       
        input [2 -1:0] RegDst_i,      
        //.Branch_i         (RF_Branch),
        input MemRead_i,     
        input MemWr_i,        
        input [2 -1:0] MemtoReg_i,       
        input [4 -1:0] ALUOp_i,          
        //RFData&InstruntionData
        input [32 -1:0] ReadData1_i,   
        input [32 -1:0] ReadData2_i,      
        input [32 -1:0] ExtImm_i,        
        input [5 -1:0] rt_i,            
        input [5 -1:0] rd_i,             
        input [5 -1:0] rs_i,//for Forward             
        input [5 -1:0] shamt_i,          
        input [6 -1:0] Funct_i,          
        input [32 -1:0] PC_i,           //for jal
//output
        output reg RegWr_o,         
        output reg ALUSrc1_o,        
        output reg AlUSrc2_o,       
        output reg [2 -1:0] RegDst_o,         
        //.Branch_o         (),
        output reg MemRead_o,        
        output reg MemWr_o,          
        output reg [2 -1:0] MemtoReg_o,    
        output reg [4 -1:0] ALUOp_o,        
        output reg [32 -1:0] ReadData1_o, 
        output reg [32 -1:0] ReadData2_o,      
        output reg [32 -1:0] ExtImm_o,      
        output reg [5 -1:0] rt_o,             
        output reg [5 -1:0] rd_o,            
        output reg [5 -1:0] rs_o,          
        output reg [5 -1:0] shamt_o,          
        output reg [6 -1:0] Funct_o,          
        output reg [32 -1:0] PC_o            
    );
    
    always @(posedge reset or posedge clk) begin
        if(reset) begin
            RegWr_o <= 1'b0;         
            ALUSrc1_o <= 1'b0;        
            AlUSrc2_o <= 1'b0;      
            RegDst_o <= 2'b00;         
            //.Branch_o         (),
            MemRead_o <= 1'b0;        
            MemWr_o <= 1'b0;          
            MemtoReg_o <= 2'b00;    
            ALUOp_o <= 4'b0000;        
            ReadData1_o <= 32'h00000000; 
            ReadData2_o <= 32'h00000000;      
            ExtImm_o <= 32'h00000000;      
            rt_o <= 5'b00000;             
            rd_o <= 5'b00000;            
            rs_o <= 5'b00000;          
            shamt_o <= 5'b00000;          
            Funct_o <=6'h00;          
            PC_o <= 32'h00000000;
        end
        else if (flush) begin
            RegWr_o <= 1'b0;         
            ALUSrc1_o <= 1'b0;        
             AlUSrc2_o <= 1'b0;      
            RegDst_o <= 2'b00;         
            //.Branch_o         (),
            MemRead_o <= 1'b0;        
            MemWr_o <= 1'b0;          
            MemtoReg_o <= 2'b00;    
            ALUOp_o <= 4'b0000;        
            ReadData1_o <= 32'h00000000; 
            ReadData2_o <= 32'h00000000;      
            ExtImm_o <= 32'h00000000;      
            rt_o <= 5'b00000;             
            rd_o <= 5'b00000;            
            rs_o <= 5'b00000;          
            shamt_o <= 5'b00000;          
            Funct_o <=6'h00;          
            PC_o <= 32'h00000000;
        end
        else begin
            RegWr_o <= RegWr_i;         
            ALUSrc1_o <= ALUSrc1_i;        
            AlUSrc2_o <= ALUSrc2_i;      
             RegDst_o <= RegDst_i;         
            //.Branch_o         (),
            MemRead_o <= MemRead_i;        
            MemWr_o <= MemWr_i;          
            MemtoReg_o <= MemtoReg_i;    
            ALUOp_o <= ALUOp_i;        
            ReadData1_o <= ReadData1_i; 
            ReadData2_o <= ReadData2_i;      
            ExtImm_o <= ExtImm_i;      
            rt_o <= rt_i;             
            rd_o <= rd_i;            
            rs_o <= rs_i;          
            shamt_o <= shamt_i;          
            Funct_o <= Funct_i;          
            PC_o <= PC_i;
        end
    end
    
endmodule
