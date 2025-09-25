module vga_controller (

    input   [1:0]   IMAGE_STATE,
    input   [9:0]   X_CUR_COORD,
    input   [9:0]   Y_CUR_COORD,

    output          CUR_COORD_STATE,
    output  [16:0]  R_ADDR
);
	 
    localparam H_DISPLAY = 640;
    localparam V_DISPLAY = 480;

    // -- INTERMEDIATE WIRES
	 
    wire [9:0] IMG_WIDTH_OUT;
    wire [9:0] IMG_HEIGHT_OUT;
    wire [9:0] H_OFFSET;
    wire [9:0] V_OFFSET;

    // -- OUTPUT IMAGE SIZE
	 
    assign IMG_WIDTH_OUT =  (IMAGE_STATE == 3'd2) ? 80   :
                            (IMAGE_STATE == 3'd1) ? 320  : 160;

    assign IMG_HEIGHT_OUT = (IMAGE_STATE == 3'd2) ? 60   :
                            (IMAGE_STATE == 3'd1) ? 240  : 120;
									
    // -- OFFSET CALCULATION
	 
    assign H_OFFSET = (H_DISPLAY - IMG_WIDTH_OUT)  / 2;
    assign V_OFFSET = (V_DISPLAY - IMG_HEIGHT_OUT) / 2;

    // -- CURRENT COORD CHECK
	 
    assign CUR_COORD_STATE = (X_CUR_COORD >= H_OFFSET) && (X_CUR_COORD < H_OFFSET + IMG_WIDTH_OUT) &&
                             (Y_CUR_COORD >= V_OFFSET) && (Y_CUR_COORD < V_OFFSET + IMG_HEIGHT_OUT);
	  	 
    // -- READ ADDRESS CHECK
	 
    assign R_ADDR = CUR_COORD_STATE ? ((Y_CUR_COORD - V_OFFSET) * IMG_WIDTH_OUT) + (X_CUR_COORD - H_OFFSET) : 0;

endmodule