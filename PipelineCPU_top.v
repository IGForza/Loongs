`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/07 16:39:01
// Design Name: 
// Module Name: PipelineCPU_top
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


module PipelineCPU_top(
    input sysclk,
    input reset,
    output [11:0] leds
    );

    wire clk;
    
    clk_gen clkgen1(
        .clk (sysclk),
        .reset  (reset),
        .clk_1K (clk)
    );
    
    Pipeline_CPU_2  cpu(
        .clk    (clk),
        .reset  (reset),
        .leds   (leds)
    );
    
endmodule
