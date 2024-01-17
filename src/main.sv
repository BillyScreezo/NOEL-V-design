/***********************************************************************************
 * Copyright (C) 2024 Kirill Turintsev <billiscreezo228@gmail.com>
 * See LICENSE file for licensing details.
 *
 * This file contains main module with NOEL-V and gen's
 *
 ***********************************************************************************/

module main 
#(
	int GPIO_WIDTH = 16
)(
	
	input sys_clk,

	// Flash ROM:
	output 	logic			rom_fcs_b_o,
	inout  	logic 			rom_mosi_io,
	inout  	logic 			rom_din_io,
	inout  	logic 			rom_do2_io,
	inout  	logic 			rom_do3_io,
	
	// UART (ADM3202):
	output 	logic 			txd_o,
	input  	logic 			rxd_i,

	// DEBUG (OUT):
	output 	logic 	[15:0] 	led,
	input  	logic   [15:0] 	sw
);

	// startup
	logic cpu_rstn, usrcclko;

	logic [3:0] cclk_ct;
	logic cclk_dummy;

	// Uart:
	logic uart_rxd, uart_txd;

	// GPIO:
	logic [GPIO_WIDTH - 1 : 0] gpioi, gpioo;
	logic [GPIO_WIDTH - 1 : 0] gpio_oen;


	logic rst, rstraw;

	rstgen #(.ACTIVE_HIGH(0)) 
		rst_inst (
			.rstin(1'b1),   .clk(sys_clk),
			.clklock(1'b1), .rstout(rst), .rstoutraw(rstraw)
		);

	logic spi_rom_cs_n;
	logic spi_rom_sclk;

	logic spi_rom_mosi_i;
	logic spi_rom_mosi_o;
	logic spi_rom_mosi_oen;

	logic spi_rom_din_i;
	logic spi_rom_din_o;
	logic spi_rom_din_oen;

	logic spi_rom_do2_i;
	logic spi_rom_do2_o;
	logic spi_rom_do2_oen;

	logic spi_rom_do3_i;
	logic spi_rom_do3_o;
	logic spi_rom_do3_oen;

	OBUF  rom_fcs_b_o_obuf 	(.I(spi_rom_cs_n),  .O(rom_fcs_b_o));

	IOBUF rom_mosi_io_iobuf	(.IO(rom_mosi_io), 	.O(spi_rom_mosi_i), .I(spi_rom_mosi_o), .T(spi_rom_mosi_oen));
	IOBUF rom_din_io_iobuf	(.IO(rom_din_io), 	.O(spi_rom_din_i),  .I(spi_rom_din_o),  .T(spi_rom_din_oen));
	IOBUF rom_do2_io_iobuf	(.IO(rom_do2_io), 	.O(spi_rom_do2_i),  .I(spi_rom_do2_o),  .T(spi_rom_do2_oen));
	IOBUF rom_do3_io_iobuf	(.IO(rom_do3_io), 	.O(spi_rom_do3_i),  .I(spi_rom_do3_o),  .T(spi_rom_do3_oen));

	noelvcore noelvcore_inst (
		// Clock & reset
		.clkm(sys_clk),
		.rstn(cpu_rstn),

		// SPI ROM
		.spi_rom_cs_n(spi_rom_cs_n),
	    .spi_rom_clk(spi_rom_sclk),

	    .spi_rom_mosi_i(spi_rom_mosi_i),
		.spi_rom_mosi_o(spi_rom_mosi_o),
		.spi_rom_mosi_oen(spi_rom_mosi_oen),

		.spi_rom_din_i(spi_rom_din_i),
		.spi_rom_din_o(spi_rom_din_o),
		.spi_rom_din_oen(spi_rom_din_oen),

		.spi_rom_do2_i(spi_rom_do2_i),
		.spi_rom_do2_o(spi_rom_do2_o),
		.spi_rom_do2_oen(spi_rom_do2_oen),

		.spi_rom_do3_i(spi_rom_do3_i),
		.spi_rom_do3_o(spi_rom_do3_o),
		.spi_rom_do3_oen(spi_rom_do3_oen),

	    // GPIO
	    .gpio_i(gpioi),
	    .gpio_o(gpioo),
	    .gpio_oe(gpio_oen),

	    // UART
	    .uart_rx(uart_rxd),
	    .uart_tx(uart_txd)

	);

	assign led[15:8]  = sw[15:8];
	assign gpioi[7:0] = sw[7:0];
	assign led[7:0]   = gpioo[15:8];

	OBUF txd_o_obuf (.I(uart_txd), .O(txd_o));
	IBUF rxd_i_ibuf (.I(rxd_i), .O(uart_rxd));

	always_ff @(posedge sys_clk) begin : cclk_delay
		if (~rst) begin
			cclk_ct 	<= '0;
			cclk_dummy 	<= '0;
			cpu_rstn 	<= '0;
		end else if (cclk_ct < 4'b1111) begin
			cclk_ct 	<= cclk_ct + 1'b1;
			cclk_dummy 	<= ~cclk_dummy;
			cpu_rstn 	<= '0;
		end else
			cpu_rstn    <= 1'b1;
	end

	assign usrcclko = cpu_rstn ? spi_rom_sclk : cclk_dummy;

	STARTUPE2 #(.PROG_USR("FALSE"), .SIM_CCLK_FREQ(10.0)) STARTUPE2_inst (
		.CFGCLK(), .CFGMCLK(), .EOS(), .PREQ(), .CLK(1'b0), .GSR(1'b0), .GTS(1'b0),
		.KEYCLEARB(1'b0), .PACK(1'b0), .USRCCLKO(usrcclko), .USRCCLKTS(1'b0),
		.USRDONEO(1'b1), .USRDONETS(1'b1));

endmodule : main