module vga_clock (

	input wire  CLK_IN,
	input wire  RESET,
	output reg  CLK_OUT_25
);

   always @(posedge CLK_IN or posedge RESET) begin
	 
		if (RESET) begin
          CLK_OUT_25 <= 1'b0;
      end else begin
          CLK_OUT_25 <= ~CLK_OUT_25;
      end
   end
	 
endmodule