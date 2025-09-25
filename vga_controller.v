module vga_controller (
		
	 input   [9:0]  IMG_WIDTH_OUT,
	 input   [8:0]   IMG_HEIGHT_OUT,
    input   [9:0]   X_CUR_COORD,
    input   [9:0]   Y_CUR_COORD,

    output          CUR_COORD_STATE,
    output  [16:0]  R_ADDR
);
	 
    localparam H_DISPLAY = 640;
    localparam V_DISPLAY = 480;

    // -- INTERMEDIATE WIRES
	 
    wire [9:0] H_OFFSET;
    wire [9:0] V_OFFSET;
									
    // -- OFFSET CALCULATION
	 
    assign H_OFFSET = (H_DISPLAY - IMG_WIDTH_OUT)  / 2;
    assign V_OFFSET = (V_DISPLAY - IMG_HEIGHT_OUT) / 2;

    // -- CURRENT COORD CHECK
	 
    assign CUR_COORD_STATE = (X_CUR_COORD >= H_OFFSET) && (X_CUR_COORD < H_OFFSET + IMG_WIDTH_OUT) &&
                             (Y_CUR_COORD >= V_OFFSET) && (Y_CUR_COORD < V_OFFSET + IMG_HEIGHT_OUT);
	  	 
    // -- READ ADDRESS CHECK
	 
    assign R_ADDR = CUR_COORD_STATE ? ((Y_CUR_COORD - V_OFFSET) * IMG_WIDTH_OUT) + (X_CUR_COORD - H_OFFSET) : 0;

endmodule