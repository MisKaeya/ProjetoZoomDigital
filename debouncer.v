module debouncer (
    input CLK,
    input RESET,
    input button_in,
    output reg button_out
);

    parameter DEBOUNCE_TIME = 25_000_000;
    reg [25:0] counter = 0;
    reg button_sync1 = 1'b0;
    reg button_sync2 = 1'b0;

    always @(posedge CLK or posedge RESET) begin
	 
        if (RESET) begin
		  
            button_sync1 <= 1'b0;
            button_sync2 <= 1'b0;
				
        end else begin
		  
            button_sync1 <= button_in;
            button_sync2 <= button_sync1;
        end
    end

    always @(posedge CLK or posedge RESET) begin
	 
        if (RESET) begin
		  
            counter    <= 0;
            button_out <= 1'b0;
				
        end else begin
		  
            if (button_sync2 == button_out) begin
				
                counter <= 0;
					 
            end else begin
				
                counter <= counter + 1;
					 
                if (counter == DEBOUNCE_TIME) begin
                    button_out <= button_sync2;
                    counter <= 0;
						  
                end
            end
        end
    end

endmodule