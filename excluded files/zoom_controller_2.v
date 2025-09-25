module zoom_controller_2 (

	input               CLK,
	input               RESET,
	input               SELECT,
	input               zoom_level_button,
	input					  zoom_requested,

	output reg   [1:0]  ALGORITHM,
	output reg   [1:0]  SHIFT_FACTOR,
   output reg   [10:0] IMG_WIDTH_OUT,
   output reg   [9:0]  IMG_HEIGHT_OUT,
	output reg 	        zoom_level
);

	localparam S_NN = 2'b00;
	localparam S_PR = 2'b01;
	localparam S_DC = 2'b10;
	localparam S_BA = 2'b11;
	
	localparam ZOOM_LEVEL_1X = 2'b00;
	localparam ZOOM_LEVEL_2X = 2'b01;
	localparam ZOOM_LEVEL_4X = 2'b10;
	localparam ZOOM_LEVEL_8X = 2'b11;
	
	localparam IMG_WIDTH_IN  = 160;
   localparam IMG_HEIGHT_IN = 120;

	always @(posedge CLK or posedge RESET) begin
		if (RESET) begin
			zoom_level <= ZOOM_LEVEL_1X;
		end else begin
			if (ALGORITHM == S_NN || ALGORITHM == S_PR || ALGORITHM == S_DC || ALGORITHM == S_BA) begin
				zoom_level <= ZOOM_LEVEL_2X;
			end else begin
				zoom_level <= ZOOM_LEVEL_1X;
			end
		end
	end


	always @(*) begin
        SHIFT_FACTOR = zoom_level;

		if ((ALGORITHM == S_NN || ALGORITHM == S_PR) && (zoom_level > ZOOM_LEVEL_1X)) begin
			IMG_WIDTH_OUT  = IMG_WIDTH_IN << SHIFT_FACTOR;
			IMG_HEIGHT_OUT = IMG_HEIGHT_IN << SHIFT_FACTOR;
		end else if ((ALGORITHM == S_DC || ALGORITHM == S_BA) && (zoom_level > ZOOM_LEVEL_1X)) begin
			IMG_WIDTH_OUT  = IMG_WIDTH_IN >> SHIFT_FACTOR;
			IMG_HEIGHT_OUT = IMG_HEIGHT_IN >> SHIFT_FACTOR;
		end else begin
			IMG_WIDTH_OUT  = IMG_WIDTH_IN;
			IMG_HEIGHT_OUT = IMG_HEIGHT_IN;
		end
	end
	
	// -- ALGORITHM SWITCH
	
	always @(posedge CLK or posedge RESET) begin
		if (RESET) begin
		
			ALGORITHM  <= S_NN;
			
		end else if (SELECT) begin
			
			case (ALGORITHM)
				
				S_NN: begin
					ALGORITHM <= S_PR;
				end
				
				S_PR: begin
					ALGORITHM <= S_DC;
				end
				
				S_DC: begin
					ALGORITHM <= S_BA;
				end
				
				S_BA: begin
					ALGORITHM <= S_NN;
				end
				
				default: begin
					ALGORITHM <= S_NN;
				end
			endcase
		end
	end

endmodule