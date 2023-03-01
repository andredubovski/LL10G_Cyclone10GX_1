// alt_usxgmii_phy.v

// Generated using ACDS version 18.1 222

`timescale 1 ps / 1 ps
module alt_usxgmii_phy (
		input  wire        csr_clk,              //            csr_clk.clk
		input  wire        xgmii_rx_coreclkin,   // xgmii_rx_coreclkin.clk
		input  wire        xgmii_tx_coreclkin,   // xgmii_tx_coreclkin.clk
		input  wire        reset,                //              reset.reset
		input  wire        rx_digitalreset,      //    rx_digitalreset.rx_digitalreset
		input  wire        tx_digitalreset,      //    tx_digitalreset.tx_digitalreset
		output wire [31:0] csr_readdata,         //      avalon_mm_csr.readdata
		input  wire [31:0] csr_writedata,        //                   .writedata
		input  wire [10:0] csr_address,          //                   .address
		output wire        csr_waitrequest,      //                   .waitrequest
		input  wire        csr_read,             //                   .read
		input  wire        csr_write,            //                   .write
		input  wire        xgmii_tx_valid,       //     xgmii_tx_valid.export
		input  wire [3:0]  xgmii_tx_control,     //   xgmii_tx_control.export
		input  wire [31:0] xgmii_tx_data,        //      xgmii_tx_data.export
		output wire        xgmii_rx_valid,       //     xgmii_rx_valid.export
		output wire [3:0]  xgmii_rx_control,     //   xgmii_rx_control.export
		output wire [31:0] xgmii_rx_data,        //      xgmii_rx_data.export
		output wire        led_an,               //             led_an.export
		output wire        rx_block_lock,        //      rx_block_lock.rx_enh_blk_lock
		output wire [2:0]  operating_speed,      //    operating_speed.export
		input  wire [0:0]  tx_serial_clk,        //      tx_serial_clk.clk
		input  wire        rx_cdr_refclk_1,      //    rx_cdr_refclk_1.clk
		output wire        rx_pma_clkout,        //      rx_pma_clkout.clk
		input  wire [0:0]  tx_analogreset,       //     tx_analogreset.tx_analogreset
		input  wire [0:0]  rx_analogreset,       //     rx_analogreset.rx_analogreset
		output wire [0:0]  tx_cal_busy,          //        tx_cal_busy.tx_cal_busy
		output wire [0:0]  rx_cal_busy,          //        rx_cal_busy.rx_cal_busy
		output wire [0:0]  tx_serial_data,       //     tx_serial_data.tx_serial_data
		input  wire [0:0]  rx_serial_data,       //     rx_serial_data.rx_serial_data
		output wire [0:0]  rx_is_lockedtodata,   // rx_is_lockedtodata.rx_is_lockedtodata
		input  wire [0:0]  reconfig_clk,         //       reconfig_clk.clk
		input  wire [0:0]  reconfig_reset,       //     reconfig_reset.reset
		input  wire [0:0]  reconfig_write,       //      reconfig_avmm.write
		input  wire [0:0]  reconfig_read,        //                   .read
		input  wire [9:0]  reconfig_address,     //                   .address
		input  wire [31:0] reconfig_writedata,   //                   .writedata
		output wire [31:0] reconfig_readdata,    //                   .readdata
		output wire [0:0]  reconfig_waitrequest  //                   .waitrequest
	);

	alt_usxgmii_phy_alt_mge_phy_181_ofhxqti alt_mge_phy_0 (
		.csr_clk              (csr_clk),              //   input,   width = 1,            csr_clk.clk
		.xgmii_rx_coreclkin   (xgmii_rx_coreclkin),   //   input,   width = 1, xgmii_rx_coreclkin.clk
		.xgmii_tx_coreclkin   (xgmii_tx_coreclkin),   //   input,   width = 1, xgmii_tx_coreclkin.clk
		.reset                (reset),                //   input,   width = 1,              reset.reset
		.rx_digitalreset      (rx_digitalreset),      //   input,   width = 1,    rx_digitalreset.rx_digitalreset
		.tx_digitalreset      (tx_digitalreset),      //   input,   width = 1,    tx_digitalreset.tx_digitalreset
		.csr_readdata         (csr_readdata),         //  output,  width = 32,      avalon_mm_csr.readdata
		.csr_writedata        (csr_writedata),        //   input,  width = 32,                   .writedata
		.csr_address          (csr_address),          //   input,  width = 11,                   .address
		.csr_waitrequest      (csr_waitrequest),      //  output,   width = 1,                   .waitrequest
		.csr_read             (csr_read),             //   input,   width = 1,                   .read
		.csr_write            (csr_write),            //   input,   width = 1,                   .write
		.xgmii_tx_valid       (xgmii_tx_valid),       //   input,   width = 1,     xgmii_tx_valid.export
		.xgmii_tx_control     (xgmii_tx_control),     //   input,   width = 4,   xgmii_tx_control.export
		.xgmii_tx_data        (xgmii_tx_data),        //   input,  width = 32,      xgmii_tx_data.export
		.xgmii_rx_valid       (xgmii_rx_valid),       //  output,   width = 1,     xgmii_rx_valid.export
		.xgmii_rx_control     (xgmii_rx_control),     //  output,   width = 4,   xgmii_rx_control.export
		.xgmii_rx_data        (xgmii_rx_data),        //  output,  width = 32,      xgmii_rx_data.export
		.led_an               (led_an),               //  output,   width = 1,             led_an.export
		.rx_block_lock        (rx_block_lock),        //  output,   width = 1,      rx_block_lock.rx_enh_blk_lock
		.operating_speed      (operating_speed),      //  output,   width = 3,    operating_speed.export
		.tx_serial_clk        (tx_serial_clk),        //   input,   width = 1,      tx_serial_clk.clk
		.rx_cdr_refclk_1      (rx_cdr_refclk_1),      //   input,   width = 1,    rx_cdr_refclk_1.clk
		.rx_pma_clkout        (rx_pma_clkout),        //  output,   width = 1,      rx_pma_clkout.clk
		.tx_analogreset       (tx_analogreset),       //   input,   width = 1,     tx_analogreset.tx_analogreset
		.rx_analogreset       (rx_analogreset),       //   input,   width = 1,     rx_analogreset.rx_analogreset
		.tx_cal_busy          (tx_cal_busy),          //  output,   width = 1,        tx_cal_busy.tx_cal_busy
		.rx_cal_busy          (rx_cal_busy),          //  output,   width = 1,        rx_cal_busy.rx_cal_busy
		.tx_serial_data       (tx_serial_data),       //  output,   width = 1,     tx_serial_data.tx_serial_data
		.rx_serial_data       (rx_serial_data),       //   input,   width = 1,     rx_serial_data.rx_serial_data
		.rx_is_lockedtodata   (rx_is_lockedtodata),   //  output,   width = 1, rx_is_lockedtodata.rx_is_lockedtodata
		.reconfig_clk         (reconfig_clk),         //   input,   width = 1,       reconfig_clk.clk
		.reconfig_reset       (reconfig_reset),       //   input,   width = 1,     reconfig_reset.reset
		.reconfig_write       (reconfig_write),       //   input,   width = 1,      reconfig_avmm.write
		.reconfig_read        (reconfig_read),        //   input,   width = 1,                   .read
		.reconfig_address     (reconfig_address),     //   input,  width = 10,                   .address
		.reconfig_writedata   (reconfig_writedata),   //   input,  width = 32,                   .writedata
		.reconfig_readdata    (reconfig_readdata),    //  output,  width = 32,                   .readdata
		.reconfig_waitrequest (reconfig_waitrequest)  //  output,   width = 1,                   .waitrequest
	);

endmodule
