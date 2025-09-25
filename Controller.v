module controller (

    input        CLK,
    input        RESET,
    input        START,    
    input        PROC_DONE,        

    output reg   PROC_ENABLE,       
    output reg   VGA_SOURCE_SELECT  // 0 = ROM, 1 = RAM
);
    // -- FSM STATES
	 
    localparam S_IDLE       = 2'd0;
    localparam S_PROCESSING = 2'd1;
    localparam S_DONE       = 2'd2;

    reg [1:0] state, next_state;

	 // -- FSM
	
    always @(posedge CLK or posedge RESET) begin
        if (RESET)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    always @(*) begin

        next_state = state;
        PROC_ENABLE = 1'b0;
        VGA_SOURCE_SELECT = 1'b0;

        case (state)
            S_IDLE: begin
                
                VGA_SOURCE_SELECT = 1'b0;
                PROC_ENABLE = 1'b0;
                          
                if (START)
                    next_state = S_PROCESSING;
            end

            S_PROCESSING: begin
              
                VGA_SOURCE_SELECT = 1'b0; 
                PROC_ENABLE = 1'b1;
            
                if (PROC_DONE)
                    next_state = S_DONE;
            end

            S_DONE: begin
				
                VGA_SOURCE_SELECT = 1'b1; 
                PROC_ENABLE = 1'b0;
           
                if (START)
                    next_state = S_IDLE;
            end
        endcase
    end
endmodule