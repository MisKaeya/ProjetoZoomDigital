module pixel_replication (

    input  [8:0]  X_OUT_COORD, 
    input  [7:0]  Y_OUT_COORD, 
    input  [7:0]  PIXEL_IN,      

    output [14:0] R_ADDR,     
    output [7:0]  PIXEL_OUT
);
	
	 localparam SHIFT_FACTOR = 1;
    localparam IMG_WIDTH_IN = 160;

    assign R_ADDR = (Y_OUT_COORD >> SHIFT_FACTOR) * IMG_WIDTH_IN + (X_OUT_COORD >> SHIFT_FACTOR);
    
    assign PIXEL_OUT = PIXEL_IN;
	 
endmodule