module coprocessor (

	input          CLK,
	input          RUN,
	input          RESET,
	input          ALGORITHM_SELECTOR,
	
   output  [7:0]  VGA_R,
   output  [7:0]  VGA_G,
   output  [7:0]  VGA_B,
   output         VGA_HS,
   output         VGA_VS,
   output         VGA_CLK,
   output         VGA_BLANK,
   output         VGA_SYNC,
	
	output  [6:0]  HEX0,
	output  [6:0]  HEX1,
	output  [6:0]  HEX2,
	output  [6:0]  HEX3,
	output  [6:0]  HEX4,
	output  [6:0]  HEX5
);

	// -- RESET LOGIC
	
	wire RESET_N;
	assign RESET_N = ~RESET;

	// -- INTERMEDIATE WIRES

	wire        CLK25;
	wire [7:0]  PIXEL_IN, PIXEL_OUT, RAM_PIXEL_DATA, ROM_PIXEL_DATA, PIXEL_DATA;
	wire [14:0] ROM_ADDRESS;
	wire [16:0] RAM_W_ADDR, VGAR_ADDR;
	wire [1:0]  IMAGE_STATE, ALGORITHM;
	wire [9:0]  NEXT_X, NEXT_Y;
	wire        CUR_COORD_STATE;
	wire        VGA_SOURCE_SELECT;
	
	// -- FLAGS
	
	wire wren_signal;
	wire processing_done;
	wire enable;
	
	// -- MODULES
	
	controller controller_inst (
		.CLK(CLK),
		.RESET(RESET_N),
		.START(!RUN),
		.PROC_DONE(processing_done),
		.PROC_ENABLE(enable),
		.VGA_SOURCE_SELECT(VGA_SOURCE_SELECT)
	);
	
	vga_clock vga_clock_inst (
		.CLK_IN(CLK),
		.RESET(RESET_N),
		.CLK_OUT_25(CLK25)
	);
	
	vga_module vga_module_inst (
		.clock(!CLK25),
		.reset(RESET_N),
      .color_in(COLOR_INFO),
      .red(VGA_R),
      .green(VGA_G),
      .blue(VGA_B),
      .hsync(VGA_HS),
      .vsync(VGA_VS),
      .clk(VGA_CLK),
      .sync(VGA_SYNC),
      .blank(VGA_BLANK),
      .next_x(NEXT_X),
      .next_y(NEXT_Y)
	);
	
	wire [7:0] COLOR_INFO;
	wire [7:0] VGA_SOURCE;
	assign VGA_SOURCE = VGA_SOURCE_SELECT ? RAM_PIXEL_DATA : ROM_PIXEL_DATA;
	assign COLOR_INFO = CUR_COORD_STATE   ? VGA_SOURCE : 8'b0;
	
	vga_controller vga_controller_inst (
		.IMAGE_STATE(IMAGE_STATE),
		.X_CUR_COORD(NEXT_X),
		.Y_CUR_COORD(NEXT_Y),
		.CUR_COORD_STATE(CUR_COORD_STATE),
		.R_ADDR(VGAR_ADDR)
	);
	
	wire SELECT_DBC;
	
	debouncer debouncer_inst (
		.CLK(CLK),
		.RESET(RESET_N),
		.button_in(!ALGORITHM_SELECTOR),
		.button_out(SELECT_DBC)
	);
	
	wire CLK1;
	
	zoom_controller zoom_controller_inst (
		.CLK(CLK),
		.RESET(RESET_N),
		.SELECT(SELECT_DBC),
		.zoom_requested(enable),
		.ALGORITHM(ALGORITHM),
		.IMAGE_STATE(IMAGE_STATE)
	);
	
	// test a single ROM block

	ROMInit ROMInit_inst (
		.address(ROM_ADDRESS),
		.clock(CLK),
		.q(PIXEL_IN)
	);
	
	// test a single ROM block
	
	ROMInit ROM_to_VGA (
		.clock(CLK),
		.address(VGAR_ADDR[14:0]),
		.q(ROM_PIXEL_DATA)
	);
	
	wire CLK100;
	
	PLL100MHz_0002 pll100mhz_inst (
		.refclk   (CLK),   //  refclk.clk
		.rst      (RESET_N),      //   reset.reset
		.outclk_0 (CLK100), // outclk0.clk
		.locked   ()    //  locked.export
	);
	
	RAMProc RAMProc_inst (
		.clock(CLK),
		.wren(wren_signal),
		.wraddress(RAM_W_ADDR),
		.data(PIXEL_OUT),
		.rdaddress(VGAR_ADDR),
		.q(RAM_PIXEL_DATA)
	);
	
	data_processing data_manager_inst (
       .CLK(CLK),
       .RESET(RESET_N),
       .enable(enable),
       .ALGORITHM(ALGORITHM),
       .PIXEL_IN(PIXEL_IN),
       .IMAGE_STATE(IMAGE_STATE),
       
       .PIXEL_OUT(PIXEL_OUT),
       .W_ADDR(RAM_W_ADDR),
		 .R_ADDR(ROM_ADDRESS),
		 .wren_out(wren_signal),
       .done(processing_done)
    );
	
	display display_inst(
		.ALGORITHM(ALGORITHM),
		.HEX0(HEX0),
		.HEX1(HEX1),
		.HEX2(HEX2),
		.HEX3(HEX3),
		.HEX4(HEX4),
		.HEX5(HEX5)
	);

endmodule