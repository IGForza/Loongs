module    mult_low
  #(parameter N=4,
    parameter M=4)
   (
      input                     clk,
      input                     rstn,

      input                     data_rdy ,
      input [N-1:0]             mult1,
      input [M-1:0]             mult2,

      output                    res_rdy ,
      output [N+M-1:0]          res
    );

   //calculate counter
   reg [31:0]           cnt ;
   wire [31:0]          cnt_temp = (cnt == M)? 'b0 : cnt + 1'b1 ;
   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         cnt    <= 'b0 ;
      end
      else if (data_rdy) begin
         cnt    <= cnt_temp ;
      end
      else if (cnt != 0 ) begin
         cnt    <= cnt_temp ;
      end
      else begin
         cnt    <= 'b0 ;
      end
   end

   //multiply
   reg [M-1:0]          mult2_shift ;
   reg [M+N-1:0]        mult1_shift ;
   reg [M+N-1:0]        mult1_acc ;
   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         mult2_shift    <= 'b0 ;
         mult2_shift    <= 'b0 ;
         mult1_acc      <= 'b0 ;
      end
      else if (data_rdy && cnt=='b0)begin
         mult1_shift    <= {{(N){1'b0}}, mult1} << 1 ;
         mult2_shift    <= mult2 >> 1 ;
         mult1_acc      <= mult2[0] ? {{(N){1'b0}}, mult1} : 'b0 ;
      end
      else if (cnt != M) begin
         mult1_shift    <= mult1_shift << 1 ;
         mult2_shift    <= mult2_shift >> 1 ;
         mult1_acc      <= mult2_shift[0] ? mult1_acc + mult1_shift : mult1_acc ;
      end
      else begin
         mult2_shift    <= 'b0 ;
         mult2_shift    <= 'b0 ;
         mult1_acc      <= 'b0 ;
      end
   end

   //results
   reg [M+N-1:0]        res_r ;
   reg                  res_rdy_r ;
   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         res_r          <= 'b0 ;
         res_rdy_r      <= 'b0 ;
      end
      else if (cnt == M) begin
         res_r          <= mult1_acc ;
         res_rdy_r      <= 1'b1 ;
      end
      else begin
         res_r          <= 'b0 ;
         res_rdy_r      <= 'b0 ;
      end
   end

   assign res_rdy       = res_rdy_r;
   assign res           = res_r;

endmodule