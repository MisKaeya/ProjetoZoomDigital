module block_averaging (
    input             CLK,
    input             RESET,
    input             FETCH_ENABLE,  
    input      [8:0]  X_OUT_COORD,
    input      [7:0]  Y_OUT_COORD,
    input      [7:0]  PIXEL_IN,      

    output reg [14:0] R_ADDR,
    output     [7:0]  PIXEL_OUT,
    output reg        FETCH_DONE   
);

	 localparam SHIFT_FACTOR = 1;
    localparam IMG_WIDTH_IN = 160;
    
    reg [1:0] fetch_counter;
    reg [7:0] p_a_reg, p_b_reg, p_c_reg, p_d_reg;

    always @(*) begin
	 
        case(fetch_counter)
            'd0: R_ADDR = (Y_OUT_COORD * 2)     * IMG_WIDTH_IN + (X_OUT_COORD * 2);
            'd1: R_ADDR = (Y_OUT_COORD * 2)     * IMG_WIDTH_IN + (X_OUT_COORD * 2 + 1);
            'd2: R_ADDR = (Y_OUT_COORD * 2 + 1) * IMG_WIDTH_IN + (X_OUT_COORD * 2);
            'd3: R_ADDR = (Y_OUT_COORD * 2 + 1) * IMG_WIDTH_IN + (X_OUT_COORD * 2 + 1);
            default: R_ADDR = 0;
				
        endcase
    end

    always @(posedge CLK or posedge RESET) begin
	 
        if (RESET) begin
		  
            fetch_counter <= 0;
            FETCH_DONE <= 1'b0;
            p_a_reg <= 0; p_b_reg <= 0; p_c_reg <= 0; p_d_reg <= 0;
				
        end else if (FETCH_ENABLE) begin
		  
            FETCH_DONE <= 1'b0;
				
            case(fetch_counter)
				
                'd0: p_a_reg <= PIXEL_IN;
                'd1: p_b_reg <= PIXEL_IN;
                'd2: p_c_reg <= PIXEL_IN;
                'd3: p_d_reg <= PIXEL_IN;
					 
            endcase
            
            if(fetch_counter == 3) begin
				
                FETCH_DONE <= 1'b1;
                fetch_counter <= 0; 
					 
            end else begin
				
                fetch_counter <= fetch_counter + 1;
					 
            end
				
        end else begin
		  
            fetch_counter <= 0;
            FETCH_DONE <= 1'b0;
        end
    end

    wire [9:0] sum = p_a_reg + p_b_reg + p_c_reg + p_d_reg;
    assign PIXEL_OUT = sum >> 2;

endmodule