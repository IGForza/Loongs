module clk_gen(
    clk, 
    reset, 
    clk_1K
);

input           clk;
input           reset;
output          clk_1K;

reg             clk_1K;

parameter   CNT = 16'd5; //100MHz->1kHz��Ƶ��ÿ50000�������ط�תһ��

reg     [15:0]  count;

always @(posedge clk or posedge reset)
begin
    if(reset) begin
        clk_1K <= 1'b0;
        count <= 16'd0;
    end
    else begin
        count <= (count==CNT-16'd1) ? 16'd0 : count + 16'd1;
        clk_1K <= (count==16'd0) ? ~clk_1K : clk_1K;
    end
end

endmodule
