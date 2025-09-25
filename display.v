module display (

	input      [1:0] ALGORITHM,
	input      [1:0] ZOOM_LEVEL,
	
	output reg [6:0] HEX0,
	output reg [6:0] HEX1,
	output reg [6:0] HEX2,
	output reg [6:0] HEX3,
	output reg [6:0] HEX4,
	output reg [6:0] HEX5
);

	localparam NN = 2'd0;
	localparam PR = 2'd1;
	localparam DC = 2'd2;
	localparam BA = 2'd3;
	
	localparam Z1X = 2'b00;
	localparam Z2X = 2'b01;
	localparam Z4X = 2'b10;
	localparam Z8X = 2'b11;
	
	// HEX3 - 1st digit
	// HEX2 - 2nd digit

	always@(*) begin
		case (ALGORITHM)
		
			NN: begin
				HEX3 <= 7'b1001000;
				HEX2 <= 7'b1001000;
				HEX4 <= 7'b1111111;
				HEX5 <= 7'b1111111;
			end	
				
			PR: begin
				HEX3 <= 7'b0001100;
				HEX2 <= 7'b1001100;
				HEX4 <= 7'b1111111;
				HEX5 <= 7'b1111111;
			end	
				
			DC: begin
				HEX3 <= 7'b1000000;
				HEX2 <= 7'b1000110;
				HEX4 <= 7'b1111111;
				HEX5 <= 7'b1111111;
			end	
				
			BA: begin
				HEX3 <= 7'b0000011;
				HEX2 <= 7'b0001000;
				HEX4 <= 7'b1111111;
				HEX5 <= 7'b1111111;
			end	
				
			default: begin
				HEX2 = 7'b1111111;
				HEX3 = 7'b1111111;
				HEX4 = 7'b1111111;
				HEX5 = 7'b1111111;
			end
		endcase
		
		case (ZOOM_LEVEL)
		
			Z1X : begin
				HEX0 <= 7'b0001001;
				HEX1 <= 7'b1111001;
			end
			
			Z2X : begin
				HEX0 <= 7'b0001001;
				HEX1 <= 7'b0100100;
			end
			
			Z4X : begin
				HEX0 <= 7'b0001001;
				HEX1 <= 7'b0011001	;
			end
			
			Z8X : begin
				HEX0 = 7'b0001001;
				HEX1 = 7'b0000000;
			end
			
			default : begin
				HEX0 = 7'b1111111;
				HEX1 = 7'b1111111;
			end
		endcase
	end
endmodule