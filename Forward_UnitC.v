`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/04 10:28:13
// Design Name: 
// Module Name: Forward_UnitC
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


module Forward_UnitC(
//input
     input [5 -1:0] WB_RegDstAddr,
     input WB_RegWr,
     input MEM_MemWr,
     input [5 -1:0] MEM_rt,
//output
     output reg MemWrDataSrc       
    );
    
    //for load-store hazard
    always @(*) begin
        if(WB_RegWr && MEM_MemWr && WB_RegDstAddr != 5'b00000 && WB_RegDstAddr == MEM_rt)
            MemWrDataSrc <= 1'b1;
        else 
            MemWrDataSrc <= 1'b0;
    end
    
endmodule
