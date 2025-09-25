module data_processing_2 (

	input               CLK,
	input               RESET,
	input        [9:0]  IMG_WIDTH_OUT,
	input        [8:0]  IMG_HEIGHT_OUT,
	input               enable,
	input        [1:0]  ALGORITHM,
	input        [7:0]  PIXEL_IN,
	
	output reg   [7:0]  PIXEL_OUT,
	output reg   [16:0] W_ADDR,
	output reg   [14:0] R_ADDR,
	output reg          wren_out,
	output reg          done
);
	
	// -- PARAMETERS 
	
	localparam NN = 2'b00;
	localparam PR = 2'b01;
	localparam DC = 2'b10;
	localparam BA = 2'b11;
	
   localparam S_IDLE   = 3'd0;
   localparam S_FETCH  = 3'd1;
   localparam S_WRITE  = 3'd2;
   localparam S_UPDATE = 3'd3;
   localparam S_DONE   = 3'd4;
	 
	// -- INTERMEDIATE WIRES
	 
	wire [14:0] nn_r_addr, pr_r_addr, dc_r_addr, ba_r_addr;
	wire [7:0]  nn_pixel_out, pr_pixel_out, dc_pixel_out, ba_pixel_out;
   wire        ba_fetch_done;
	 
   wire [14:0] selected_r_addr;
   wire [7:0]  selected_pixel_out;
   wire        selected_fetch_done;

   reg  [2:0]  state, next_state;
	reg  [8:0]  x_counter;
	reg  [7:0]  y_counter;
   reg         ba_fetch_enable;

	// -- MODULES
	
    nearest_neighbor_2 nn_inst (
        .X_OUT_COORD(x_counter), 
		  .Y_OUT_COORD(y_counter), 
		  .PIXEL_IN(PIXEL_IN),
        .R_ADDR(nn_r_addr), 
		  .PIXEL_OUT(nn_pixel_out)
    );
	 
    pixel_replication_2 pr_inst (
        .X_OUT_COORD(x_counter), 
		  .Y_OUT_COORD(y_counter),
		  .PIXEL_IN(PIXEL_IN),
        .R_ADDR(pr_r_addr), 
		  .PIXEL_OUT(pr_pixel_out)
    );
	 
    decimation_2 dc_inst (
        .X_OUT_COORD(x_counter), 
		  .Y_OUT_COORD(y_counter), 
		  .PIXEL_IN(PIXEL_IN),
        .R_ADDR(dc_r_addr), 
		  .PIXEL_OUT(dc_pixel_out)
    );
	 
    block_averaging ba_inst (
        .CLK(CLK), 
		  .RESET(RESET), 
		  .FETCH_ENABLE(ba_fetch_enable),
        .X_OUT_COORD(x_counter), 
		  .Y_OUT_COORD(y_counter), 
		  .PIXEL_IN(PIXEL_IN),
        .R_ADDR(ba_r_addr), 
		  .PIXEL_OUT(ba_pixel_out), 
		  .FETCH_DONE(ba_fetch_done)
    );
	 
    assign selected_r_addr    = (ALGORITHM == NN) ? nn_r_addr :
                                (ALGORITHM == PR) ? pr_r_addr :
                                (ALGORITHM == DC) ? dc_r_addr :
                                ba_r_addr;
    
    assign selected_pixel_out = (ALGORITHM == NN) ? nn_pixel_out :
                                (ALGORITHM == PR) ? pr_pixel_out :
                                (ALGORITHM == DC) ? dc_pixel_out :
                                ba_pixel_out;
	 
    assign selected_fetch_done = (ALGORITHM == BA) ? ba_fetch_done : 1'b1;

	// -- FSM
	
	always@(posedge CLK or posedge RESET) begin
	
		if (RESET) 
			state <= S_IDLE;
		else       
			state <= next_state;
		
	end
	
	// - Counters
	
	always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            x_counter <= 0;
            y_counter <= 0;
        end else begin
          
            if (state == S_IDLE && next_state == S_FETCH) begin
                x_counter <= 0;
                y_counter <= 0;

            end else if (state == S_UPDATE) begin
                if (x_counter < IMG_WIDTH_OUT - 1) begin
                    x_counter <= x_counter + 1;
                end else begin
                    x_counter <= 0;
                    y_counter <= y_counter + 1;
                end
            end
        end
    end

	always@(*) begin
	
		next_state = state;
		done = 1'b0;
      ba_fetch_enable = 1'b0;
      R_ADDR = selected_r_addr;
      W_ADDR = 0;
      PIXEL_OUT = 0;
		wren_out = 1'b0;
		
		case (state)
		
			S_IDLE: begin
			
				if (enable) begin
			
					next_state = S_FETCH;
					
				end
			end
			
			S_FETCH: begin
                
                ba_fetch_enable = (ALGORITHM == BA); 
                if (selected_fetch_done)
                    next_state = S_WRITE;
                else
                    next_state = S_FETCH;
			end
			
			S_WRITE: begin
				
				wren_out = 1'b1;
            PIXEL_OUT = selected_pixel_out;
				W_ADDR = y_counter * IMG_WIDTH_OUT + x_counter;
				next_state = S_UPDATE;
			end
			
			S_UPDATE: begin
				
				 if (y_counter >= IMG_HEIGHT_OUT - 1 && x_counter >= IMG_WIDTH_OUT - 1)
				 
					  next_state = S_DONE;
					  
				 else
				 
					  next_state = S_FETCH;
			end
			
			S_DONE: begin
			
				done = 1'b1;
				
				if (!enable) 
					next_state = S_IDLE;
			end
		endcase
	end
endmodule