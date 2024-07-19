module DataMemory(
	input  reset    , 
	input  clk      ,  
	input  MemRead  ,
	input  MemWrite ,
	input  [32 -1:0] Address    ,
	input  [32 -1:0] Write_data ,
//	input button, //for bcd7
	output [32 -1:0] Read_data   ,
	output [12 -1:0] LEDS //与外设交互预留接口
);
	
	// RAM size is 512 words, each word is 32 bits, valid address is 8 bits
	parameter RAM_SIZE      = 512;
	parameter RAM_SIZE_BIT  = 9;
	
	// RAM_data is an array of 256 32-bit registers
	reg [31:0] RAM_data [RAM_SIZE - 1: 0];
	reg [31:0] RAM_LEDS; //for BCD7

	// read data from RAM_data as Read_data
	assign Read_data = MemRead? Address == 32'h40000010 ? RAM_LEDS : 
	   RAM_data[Address[RAM_SIZE_BIT + 1:2]]: 32'h00000000;
	
	// write Write_data to RAM_data at clock posedge
	integer i;
	always @(posedge reset or posedge clk)begin
		if (reset) begin
			// -------- Paste Data Memory Configuration Below (Data-q1.txt)
			
          for (i = 0; i < RAM_SIZE; i = i + 1)
            RAM_data[i] <= 32'h00000000;
            RAM_LEDS <= 32'h00000000;
            
            RAM_data[0] <= 32'h00000000;
            RAM_data[1] <= 32'h00000000;
            RAM_data[2] <= 32'h00000000;
            RAM_data[3] <= 32'h00000000;
            RAM_data[4] <= 32'd24;
            RAM_data[5] <= 32'd1;
            RAM_data[6] <= 32'd2;
            RAM_data[7] <= 32'd3;
            RAM_data[8] <= 32'd3;
            RAM_data[9] <= 32'd46979;
            RAM_data[10] <= 32'd56009;
            RAM_data[11] <= 32'd36569;
            RAM_data[12] <= 32'd2559;
            RAM_data[13] <= 32'd12100;
            RAM_data[14] <= 32'd1102;
            RAM_data[15] <= 32'd39065;
            RAM_data[16] <= 32'd15446;
            RAM_data[17] <= 32'd4749;
            RAM_data[18] <= 32'd56291;
            RAM_data[19] <= 32'd54452;
            RAM_data[20] <= 32'd14152;
            RAM_data[21] <= 32'd14616;
            RAM_data[22] <= 32'd16658;
            RAM_data[23] <= 32'd50073;
            RAM_data[24] <= 32'd18773;
            RAM_data[25] <= 32'd57648;
            RAM_data[26] <= 32'd58940;
            RAM_data[27] <= 32'd59089;
            RAM_data[28] <= 32'd59789;

			// -------- Paste Data Memory Configuration Above
		end
		else if (MemWrite) begin
		    if(Address == 32'h40000010)
		      RAM_LEDS <= Write_data;
		    else
			  RAM_data[Address[RAM_SIZE_BIT + 1:2]] <= Write_data;
		end
	end
	
	assign LEDS = RAM_LEDS;	
//	integer j;	
//	assign LEDS = RAM_LEDS;
		
//	always @(posedge reset or posedge button) begin
//	   if (reset) begin
//	       j<=0;
//	       RAM_LEDS <= 32'h00000000;
//	   end
//	   else if(j <= RAM_data[0]) begin
//	       RAM_LEDS <= RAM_data[j+5];
//	       j = j + 1; 
//	   end    
//	   else
//	       RAM_LEDS <= 32'h00000000;
//	end
			
endmodule
