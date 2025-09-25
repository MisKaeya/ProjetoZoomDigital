module zoom_controller (

	input            CLK,
	input            RESET,
	input            SELECT,
	input            zoom_requested,
	
	output reg [1:0] ALGORITHM,
	output     [9:0] IMG_WIDTH_OUT,
	output     [8:0] IMG_HEIGHT_OUT
);
	
	localparam S_NN = 2'd0;
	localparam S_PR = 2'd1;
	localparam S_DC = 2'd2;
	localparam S_BA = 2'd3;

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
	
	localparam S_DEFAULT  = 2'd0;
	localparam S_ENLARGED = 2'd1;
	localparam S_REDUCED  = 2'd2;
	
	reg [1:0] IMAGE_STATE;
	
	always @(posedge CLK or posedge RESET) begin
		if (RESET) begin
			IMAGE_STATE <= S_DEFAULT;
			
		end else if (zoom_requested) begin
			
			if (ALGORITHM == S_NN || ALGORITHM == S_PR) begin
				IMAGE_STATE <= S_ENLARGED;
			end else if (ALGORITHM == S_BA || ALGORITHM == S_DC) begin
				IMAGE_STATE <= S_REDUCED;
			end else begin
				IMAGE_STATE <= S_DEFAULT;
			end
	   end
	end
	
	assign IMG_WIDTH_OUT =  (IMAGE_STATE == 3'd2) ? 80    :
                           (IMAGE_STATE == 3'd1) ? 320   : 160;

   assign IMG_HEIGHT_OUT = (IMAGE_STATE == 3'd2) ? 60    : 
                           (IMAGE_STATE == 3'd1) ? 240   : 120;

endmodule