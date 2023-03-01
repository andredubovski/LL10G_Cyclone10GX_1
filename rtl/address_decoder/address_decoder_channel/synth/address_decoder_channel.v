// address_decoder_channel.v

// Generated using ACDS version 18.1 222

`timescale 1 ps / 1 ps
module address_decoder_channel (
		input  wire        csr_clk_clk,           //       csr_clk.clk
		input  wire        csr_clk_reset_reset_n, // csr_clk_reset.reset_n
		output wire [9:0]  mac_address,           //           mac.address
		output wire        mac_write,             //              .write
		output wire        mac_read,              //              .read
		input  wire [31:0] mac_readdata,          //              .readdata
		output wire [31:0] mac_writedata,         //              .writedata
		input  wire        mac_waitrequest,       //              .waitrequest
		input  wire [15:0] slave_address,         //         slave.address
		output wire        slave_waitrequest,     //              .waitrequest
		input  wire        slave_read,            //              .read
		output wire [31:0] slave_readdata,        //              .readdata
		input  wire        slave_write,           //              .write
		input  wire [31:0] slave_writedata,       //              .writedata
		output wire [10:0] phy_address,           //           phy.address
		output wire        phy_write,             //              .write
		output wire        phy_read,              //              .read
		input  wire [31:0] phy_readdata,          //              .readdata
		output wire [31:0] phy_writedata,         //              .writedata
		input  wire        phy_waitrequest,       //              .waitrequest
		output wire [9:0]  xcvr_rcfg_address,     //     xcvr_rcfg.address
		output wire        xcvr_rcfg_write,       //              .write
		output wire        xcvr_rcfg_read,        //              .read
		input  wire [31:0] xcvr_rcfg_readdata,    //              .readdata
		output wire [31:0] xcvr_rcfg_writedata,   //              .writedata
		input  wire        xcvr_rcfg_waitrequest  //              .waitrequest
	);

	wire         csr_clk_clk_clk;                                                    // csr_clk:clk_out -> [mac:clk, master:clk, mm_interconnect_0:csr_clk_clk_clk, phy:clk, rst_controller:clk, xcvr_rcfg:clk]
	wire         master_avalon_universal_master_0_waitrequest;                       // mm_interconnect_0:master_avalon_universal_master_0_waitrequest -> master:uav_waitrequest
	wire  [31:0] master_avalon_universal_master_0_readdata;                          // mm_interconnect_0:master_avalon_universal_master_0_readdata -> master:uav_readdata
	wire         master_avalon_universal_master_0_debugaccess;                       // master:uav_debugaccess -> mm_interconnect_0:master_avalon_universal_master_0_debugaccess
	wire  [31:0] master_avalon_universal_master_0_address;                           // master:uav_address -> mm_interconnect_0:master_avalon_universal_master_0_address
	wire         master_avalon_universal_master_0_read;                              // master:uav_read -> mm_interconnect_0:master_avalon_universal_master_0_read
	wire   [3:0] master_avalon_universal_master_0_byteenable;                        // master:uav_byteenable -> mm_interconnect_0:master_avalon_universal_master_0_byteenable
	wire         master_avalon_universal_master_0_readdatavalid;                     // mm_interconnect_0:master_avalon_universal_master_0_readdatavalid -> master:uav_readdatavalid
	wire         master_avalon_universal_master_0_lock;                              // master:uav_lock -> mm_interconnect_0:master_avalon_universal_master_0_lock
	wire         master_avalon_universal_master_0_write;                             // master:uav_write -> mm_interconnect_0:master_avalon_universal_master_0_write
	wire  [31:0] master_avalon_universal_master_0_writedata;                         // master:uav_writedata -> mm_interconnect_0:master_avalon_universal_master_0_writedata
	wire   [2:0] master_avalon_universal_master_0_burstcount;                        // master:uav_burstcount -> mm_interconnect_0:master_avalon_universal_master_0_burstcount
	wire  [31:0] mm_interconnect_0_mac_avalon_universal_slave_0_readdata;            // mac:uav_readdata -> mm_interconnect_0:mac_avalon_universal_slave_0_readdata
	wire         mm_interconnect_0_mac_avalon_universal_slave_0_waitrequest;         // mac:uav_waitrequest -> mm_interconnect_0:mac_avalon_universal_slave_0_waitrequest
	wire         mm_interconnect_0_mac_avalon_universal_slave_0_debugaccess;         // mm_interconnect_0:mac_avalon_universal_slave_0_debugaccess -> mac:uav_debugaccess
	wire  [11:0] mm_interconnect_0_mac_avalon_universal_slave_0_address;             // mm_interconnect_0:mac_avalon_universal_slave_0_address -> mac:uav_address
	wire         mm_interconnect_0_mac_avalon_universal_slave_0_read;                // mm_interconnect_0:mac_avalon_universal_slave_0_read -> mac:uav_read
	wire   [3:0] mm_interconnect_0_mac_avalon_universal_slave_0_byteenable;          // mm_interconnect_0:mac_avalon_universal_slave_0_byteenable -> mac:uav_byteenable
	wire         mm_interconnect_0_mac_avalon_universal_slave_0_readdatavalid;       // mac:uav_readdatavalid -> mm_interconnect_0:mac_avalon_universal_slave_0_readdatavalid
	wire         mm_interconnect_0_mac_avalon_universal_slave_0_lock;                // mm_interconnect_0:mac_avalon_universal_slave_0_lock -> mac:uav_lock
	wire         mm_interconnect_0_mac_avalon_universal_slave_0_write;               // mm_interconnect_0:mac_avalon_universal_slave_0_write -> mac:uav_write
	wire  [31:0] mm_interconnect_0_mac_avalon_universal_slave_0_writedata;           // mm_interconnect_0:mac_avalon_universal_slave_0_writedata -> mac:uav_writedata
	wire   [2:0] mm_interconnect_0_mac_avalon_universal_slave_0_burstcount;          // mm_interconnect_0:mac_avalon_universal_slave_0_burstcount -> mac:uav_burstcount
	wire  [31:0] mm_interconnect_0_phy_avalon_universal_slave_0_readdata;            // phy:uav_readdata -> mm_interconnect_0:phy_avalon_universal_slave_0_readdata
	wire         mm_interconnect_0_phy_avalon_universal_slave_0_waitrequest;         // phy:uav_waitrequest -> mm_interconnect_0:phy_avalon_universal_slave_0_waitrequest
	wire         mm_interconnect_0_phy_avalon_universal_slave_0_debugaccess;         // mm_interconnect_0:phy_avalon_universal_slave_0_debugaccess -> phy:uav_debugaccess
	wire  [12:0] mm_interconnect_0_phy_avalon_universal_slave_0_address;             // mm_interconnect_0:phy_avalon_universal_slave_0_address -> phy:uav_address
	wire         mm_interconnect_0_phy_avalon_universal_slave_0_read;                // mm_interconnect_0:phy_avalon_universal_slave_0_read -> phy:uav_read
	wire   [3:0] mm_interconnect_0_phy_avalon_universal_slave_0_byteenable;          // mm_interconnect_0:phy_avalon_universal_slave_0_byteenable -> phy:uav_byteenable
	wire         mm_interconnect_0_phy_avalon_universal_slave_0_readdatavalid;       // phy:uav_readdatavalid -> mm_interconnect_0:phy_avalon_universal_slave_0_readdatavalid
	wire         mm_interconnect_0_phy_avalon_universal_slave_0_lock;                // mm_interconnect_0:phy_avalon_universal_slave_0_lock -> phy:uav_lock
	wire         mm_interconnect_0_phy_avalon_universal_slave_0_write;               // mm_interconnect_0:phy_avalon_universal_slave_0_write -> phy:uav_write
	wire  [31:0] mm_interconnect_0_phy_avalon_universal_slave_0_writedata;           // mm_interconnect_0:phy_avalon_universal_slave_0_writedata -> phy:uav_writedata
	wire   [2:0] mm_interconnect_0_phy_avalon_universal_slave_0_burstcount;          // mm_interconnect_0:phy_avalon_universal_slave_0_burstcount -> phy:uav_burstcount
	wire  [31:0] mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_readdata;      // xcvr_rcfg:uav_readdata -> mm_interconnect_0:xcvr_rcfg_avalon_universal_slave_0_readdata
	wire         mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_waitrequest;   // xcvr_rcfg:uav_waitrequest -> mm_interconnect_0:xcvr_rcfg_avalon_universal_slave_0_waitrequest
	wire         mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_debugaccess;   // mm_interconnect_0:xcvr_rcfg_avalon_universal_slave_0_debugaccess -> xcvr_rcfg:uav_debugaccess
	wire  [11:0] mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_address;       // mm_interconnect_0:xcvr_rcfg_avalon_universal_slave_0_address -> xcvr_rcfg:uav_address
	wire         mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_read;          // mm_interconnect_0:xcvr_rcfg_avalon_universal_slave_0_read -> xcvr_rcfg:uav_read
	wire   [3:0] mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_byteenable;    // mm_interconnect_0:xcvr_rcfg_avalon_universal_slave_0_byteenable -> xcvr_rcfg:uav_byteenable
	wire         mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_readdatavalid; // xcvr_rcfg:uav_readdatavalid -> mm_interconnect_0:xcvr_rcfg_avalon_universal_slave_0_readdatavalid
	wire         mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_lock;          // mm_interconnect_0:xcvr_rcfg_avalon_universal_slave_0_lock -> xcvr_rcfg:uav_lock
	wire         mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_write;         // mm_interconnect_0:xcvr_rcfg_avalon_universal_slave_0_write -> xcvr_rcfg:uav_write
	wire  [31:0] mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_writedata;     // mm_interconnect_0:xcvr_rcfg_avalon_universal_slave_0_writedata -> xcvr_rcfg:uav_writedata
	wire   [2:0] mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_burstcount;    // mm_interconnect_0:xcvr_rcfg_avalon_universal_slave_0_burstcount -> xcvr_rcfg:uav_burstcount
	wire         rst_controller_reset_out_reset;                                     // rst_controller:reset_out -> [mac:reset, master:reset, mm_interconnect_0:master_reset_reset_bridge_in_reset_reset, phy:reset, xcvr_rcfg:reset]
	wire         csr_clk_clk_reset_reset;                                            // csr_clk:reset_n_out -> rst_controller:reset_in0

	address_decoder_channel_csr_clk csr_clk (
		.clk_out     (csr_clk_clk_clk),         //  output,  width = 1,          clk.clk
		.in_clk      (csr_clk_clk),             //   input,  width = 1,       clk_in.clk
		.reset_n     (csr_clk_reset_reset_n),   //   input,  width = 1, clk_in_reset.reset_n
		.reset_n_out (csr_clk_clk_reset_reset)  //  output,  width = 1,    clk_reset.reset_n
	);

	address_decoder_channel_mac mac (
		.av_address        (mac_address),                                                  //  output,  width = 10,      avalon_anti_slave_0.address
		.av_write          (mac_write),                                                    //  output,   width = 1,                         .write
		.av_read           (mac_read),                                                     //  output,   width = 1,                         .read
		.av_readdata       (mac_readdata),                                                 //   input,  width = 32,                         .readdata
		.av_writedata      (mac_writedata),                                                //  output,  width = 32,                         .writedata
		.av_waitrequest    (mac_waitrequest),                                              //   input,   width = 1,                         .waitrequest
		.uav_address       (mm_interconnect_0_mac_avalon_universal_slave_0_address),       //   input,  width = 12, avalon_universal_slave_0.address
		.uav_burstcount    (mm_interconnect_0_mac_avalon_universal_slave_0_burstcount),    //   input,   width = 3,                         .burstcount
		.uav_read          (mm_interconnect_0_mac_avalon_universal_slave_0_read),          //   input,   width = 1,                         .read
		.uav_write         (mm_interconnect_0_mac_avalon_universal_slave_0_write),         //   input,   width = 1,                         .write
		.uav_waitrequest   (mm_interconnect_0_mac_avalon_universal_slave_0_waitrequest),   //  output,   width = 1,                         .waitrequest
		.uav_readdatavalid (mm_interconnect_0_mac_avalon_universal_slave_0_readdatavalid), //  output,   width = 1,                         .readdatavalid
		.uav_byteenable    (mm_interconnect_0_mac_avalon_universal_slave_0_byteenable),    //   input,   width = 4,                         .byteenable
		.uav_readdata      (mm_interconnect_0_mac_avalon_universal_slave_0_readdata),      //  output,  width = 32,                         .readdata
		.uav_writedata     (mm_interconnect_0_mac_avalon_universal_slave_0_writedata),     //   input,  width = 32,                         .writedata
		.uav_lock          (mm_interconnect_0_mac_avalon_universal_slave_0_lock),          //   input,   width = 1,                         .lock
		.uav_debugaccess   (mm_interconnect_0_mac_avalon_universal_slave_0_debugaccess),   //   input,   width = 1,                         .debugaccess
		.clk               (csr_clk_clk_clk),                                              //   input,   width = 1,                      clk.clk
		.reset             (rst_controller_reset_out_reset)                                //   input,   width = 1,                    reset.reset
	);

	address_decoder_channel_master master (
		.av_address        (slave_address),                                  //   input,  width = 16,      avalon_anti_master_0.address
		.av_waitrequest    (slave_waitrequest),                              //  output,   width = 1,                          .waitrequest
		.av_read           (slave_read),                                     //   input,   width = 1,                          .read
		.av_readdata       (slave_readdata),                                 //  output,  width = 32,                          .readdata
		.av_write          (slave_write),                                    //   input,   width = 1,                          .write
		.av_writedata      (slave_writedata),                                //   input,  width = 32,                          .writedata
		.uav_address       (master_avalon_universal_master_0_address),       //  output,  width = 32, avalon_universal_master_0.address
		.uav_burstcount    (master_avalon_universal_master_0_burstcount),    //  output,   width = 3,                          .burstcount
		.uav_read          (master_avalon_universal_master_0_read),          //  output,   width = 1,                          .read
		.uav_write         (master_avalon_universal_master_0_write),         //  output,   width = 1,                          .write
		.uav_waitrequest   (master_avalon_universal_master_0_waitrequest),   //   input,   width = 1,                          .waitrequest
		.uav_readdatavalid (master_avalon_universal_master_0_readdatavalid), //   input,   width = 1,                          .readdatavalid
		.uav_byteenable    (master_avalon_universal_master_0_byteenable),    //  output,   width = 4,                          .byteenable
		.uav_readdata      (master_avalon_universal_master_0_readdata),      //   input,  width = 32,                          .readdata
		.uav_writedata     (master_avalon_universal_master_0_writedata),     //  output,  width = 32,                          .writedata
		.uav_lock          (master_avalon_universal_master_0_lock),          //  output,   width = 1,                          .lock
		.uav_debugaccess   (master_avalon_universal_master_0_debugaccess),   //  output,   width = 1,                          .debugaccess
		.clk               (csr_clk_clk_clk),                                //   input,   width = 1,                       clk.clk
		.reset             (rst_controller_reset_out_reset)                  //   input,   width = 1,                     reset.reset
	);

	address_decoder_channel_phy phy (
		.av_address        (phy_address),                                                  //  output,  width = 11,      avalon_anti_slave_0.address
		.av_write          (phy_write),                                                    //  output,   width = 1,                         .write
		.av_read           (phy_read),                                                     //  output,   width = 1,                         .read
		.av_readdata       (phy_readdata),                                                 //   input,  width = 32,                         .readdata
		.av_writedata      (phy_writedata),                                                //  output,  width = 32,                         .writedata
		.av_waitrequest    (phy_waitrequest),                                              //   input,   width = 1,                         .waitrequest
		.uav_address       (mm_interconnect_0_phy_avalon_universal_slave_0_address),       //   input,  width = 13, avalon_universal_slave_0.address
		.uav_burstcount    (mm_interconnect_0_phy_avalon_universal_slave_0_burstcount),    //   input,   width = 3,                         .burstcount
		.uav_read          (mm_interconnect_0_phy_avalon_universal_slave_0_read),          //   input,   width = 1,                         .read
		.uav_write         (mm_interconnect_0_phy_avalon_universal_slave_0_write),         //   input,   width = 1,                         .write
		.uav_waitrequest   (mm_interconnect_0_phy_avalon_universal_slave_0_waitrequest),   //  output,   width = 1,                         .waitrequest
		.uav_readdatavalid (mm_interconnect_0_phy_avalon_universal_slave_0_readdatavalid), //  output,   width = 1,                         .readdatavalid
		.uav_byteenable    (mm_interconnect_0_phy_avalon_universal_slave_0_byteenable),    //   input,   width = 4,                         .byteenable
		.uav_readdata      (mm_interconnect_0_phy_avalon_universal_slave_0_readdata),      //  output,  width = 32,                         .readdata
		.uav_writedata     (mm_interconnect_0_phy_avalon_universal_slave_0_writedata),     //   input,  width = 32,                         .writedata
		.uav_lock          (mm_interconnect_0_phy_avalon_universal_slave_0_lock),          //   input,   width = 1,                         .lock
		.uav_debugaccess   (mm_interconnect_0_phy_avalon_universal_slave_0_debugaccess),   //   input,   width = 1,                         .debugaccess
		.clk               (csr_clk_clk_clk),                                              //   input,   width = 1,                      clk.clk
		.reset             (rst_controller_reset_out_reset)                                //   input,   width = 1,                    reset.reset
	);

	address_decoder_channel_xcvr_rcfg xcvr_rcfg (
		.av_address        (xcvr_rcfg_address),                                                  //  output,  width = 10,      avalon_anti_slave_0.address
		.av_write          (xcvr_rcfg_write),                                                    //  output,   width = 1,                         .write
		.av_read           (xcvr_rcfg_read),                                                     //  output,   width = 1,                         .read
		.av_readdata       (xcvr_rcfg_readdata),                                                 //   input,  width = 32,                         .readdata
		.av_writedata      (xcvr_rcfg_writedata),                                                //  output,  width = 32,                         .writedata
		.av_waitrequest    (xcvr_rcfg_waitrequest),                                              //   input,   width = 1,                         .waitrequest
		.uav_address       (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_address),       //   input,  width = 12, avalon_universal_slave_0.address
		.uav_burstcount    (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_burstcount),    //   input,   width = 3,                         .burstcount
		.uav_read          (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_read),          //   input,   width = 1,                         .read
		.uav_write         (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_write),         //   input,   width = 1,                         .write
		.uav_waitrequest   (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_waitrequest),   //  output,   width = 1,                         .waitrequest
		.uav_readdatavalid (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_readdatavalid), //  output,   width = 1,                         .readdatavalid
		.uav_byteenable    (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_byteenable),    //   input,   width = 4,                         .byteenable
		.uav_readdata      (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_readdata),      //  output,  width = 32,                         .readdata
		.uav_writedata     (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_writedata),     //   input,  width = 32,                         .writedata
		.uav_lock          (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_lock),          //   input,   width = 1,                         .lock
		.uav_debugaccess   (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_debugaccess),   //   input,   width = 1,                         .debugaccess
		.clk               (csr_clk_clk_clk),                                                    //   input,   width = 1,                      clk.clk
		.reset             (rst_controller_reset_out_reset)                                      //   input,   width = 1,                    reset.reset
	);

	address_decoder_channel_altera_mm_interconnect_181_ua2ricy mm_interconnect_0 (
		.master_avalon_universal_master_0_address         (master_avalon_universal_master_0_address),                           //   input,  width = 32,   master_avalon_universal_master_0.address
		.master_avalon_universal_master_0_waitrequest     (master_avalon_universal_master_0_waitrequest),                       //  output,   width = 1,                                   .waitrequest
		.master_avalon_universal_master_0_burstcount      (master_avalon_universal_master_0_burstcount),                        //   input,   width = 3,                                   .burstcount
		.master_avalon_universal_master_0_byteenable      (master_avalon_universal_master_0_byteenable),                        //   input,   width = 4,                                   .byteenable
		.master_avalon_universal_master_0_read            (master_avalon_universal_master_0_read),                              //   input,   width = 1,                                   .read
		.master_avalon_universal_master_0_readdata        (master_avalon_universal_master_0_readdata),                          //  output,  width = 32,                                   .readdata
		.master_avalon_universal_master_0_readdatavalid   (master_avalon_universal_master_0_readdatavalid),                     //  output,   width = 1,                                   .readdatavalid
		.master_avalon_universal_master_0_write           (master_avalon_universal_master_0_write),                             //   input,   width = 1,                                   .write
		.master_avalon_universal_master_0_writedata       (master_avalon_universal_master_0_writedata),                         //   input,  width = 32,                                   .writedata
		.master_avalon_universal_master_0_lock            (master_avalon_universal_master_0_lock),                              //   input,   width = 1,                                   .lock
		.master_avalon_universal_master_0_debugaccess     (master_avalon_universal_master_0_debugaccess),                       //   input,   width = 1,                                   .debugaccess
		.mac_avalon_universal_slave_0_address             (mm_interconnect_0_mac_avalon_universal_slave_0_address),             //  output,  width = 12,       mac_avalon_universal_slave_0.address
		.mac_avalon_universal_slave_0_write               (mm_interconnect_0_mac_avalon_universal_slave_0_write),               //  output,   width = 1,                                   .write
		.mac_avalon_universal_slave_0_read                (mm_interconnect_0_mac_avalon_universal_slave_0_read),                //  output,   width = 1,                                   .read
		.mac_avalon_universal_slave_0_readdata            (mm_interconnect_0_mac_avalon_universal_slave_0_readdata),            //   input,  width = 32,                                   .readdata
		.mac_avalon_universal_slave_0_writedata           (mm_interconnect_0_mac_avalon_universal_slave_0_writedata),           //  output,  width = 32,                                   .writedata
		.mac_avalon_universal_slave_0_burstcount          (mm_interconnect_0_mac_avalon_universal_slave_0_burstcount),          //  output,   width = 3,                                   .burstcount
		.mac_avalon_universal_slave_0_byteenable          (mm_interconnect_0_mac_avalon_universal_slave_0_byteenable),          //  output,   width = 4,                                   .byteenable
		.mac_avalon_universal_slave_0_readdatavalid       (mm_interconnect_0_mac_avalon_universal_slave_0_readdatavalid),       //   input,   width = 1,                                   .readdatavalid
		.mac_avalon_universal_slave_0_waitrequest         (mm_interconnect_0_mac_avalon_universal_slave_0_waitrequest),         //   input,   width = 1,                                   .waitrequest
		.mac_avalon_universal_slave_0_lock                (mm_interconnect_0_mac_avalon_universal_slave_0_lock),                //  output,   width = 1,                                   .lock
		.mac_avalon_universal_slave_0_debugaccess         (mm_interconnect_0_mac_avalon_universal_slave_0_debugaccess),         //  output,   width = 1,                                   .debugaccess
		.phy_avalon_universal_slave_0_address             (mm_interconnect_0_phy_avalon_universal_slave_0_address),             //  output,  width = 13,       phy_avalon_universal_slave_0.address
		.phy_avalon_universal_slave_0_write               (mm_interconnect_0_phy_avalon_universal_slave_0_write),               //  output,   width = 1,                                   .write
		.phy_avalon_universal_slave_0_read                (mm_interconnect_0_phy_avalon_universal_slave_0_read),                //  output,   width = 1,                                   .read
		.phy_avalon_universal_slave_0_readdata            (mm_interconnect_0_phy_avalon_universal_slave_0_readdata),            //   input,  width = 32,                                   .readdata
		.phy_avalon_universal_slave_0_writedata           (mm_interconnect_0_phy_avalon_universal_slave_0_writedata),           //  output,  width = 32,                                   .writedata
		.phy_avalon_universal_slave_0_burstcount          (mm_interconnect_0_phy_avalon_universal_slave_0_burstcount),          //  output,   width = 3,                                   .burstcount
		.phy_avalon_universal_slave_0_byteenable          (mm_interconnect_0_phy_avalon_universal_slave_0_byteenable),          //  output,   width = 4,                                   .byteenable
		.phy_avalon_universal_slave_0_readdatavalid       (mm_interconnect_0_phy_avalon_universal_slave_0_readdatavalid),       //   input,   width = 1,                                   .readdatavalid
		.phy_avalon_universal_slave_0_waitrequest         (mm_interconnect_0_phy_avalon_universal_slave_0_waitrequest),         //   input,   width = 1,                                   .waitrequest
		.phy_avalon_universal_slave_0_lock                (mm_interconnect_0_phy_avalon_universal_slave_0_lock),                //  output,   width = 1,                                   .lock
		.phy_avalon_universal_slave_0_debugaccess         (mm_interconnect_0_phy_avalon_universal_slave_0_debugaccess),         //  output,   width = 1,                                   .debugaccess
		.xcvr_rcfg_avalon_universal_slave_0_address       (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_address),       //  output,  width = 12, xcvr_rcfg_avalon_universal_slave_0.address
		.xcvr_rcfg_avalon_universal_slave_0_write         (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_write),         //  output,   width = 1,                                   .write
		.xcvr_rcfg_avalon_universal_slave_0_read          (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_read),          //  output,   width = 1,                                   .read
		.xcvr_rcfg_avalon_universal_slave_0_readdata      (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_readdata),      //   input,  width = 32,                                   .readdata
		.xcvr_rcfg_avalon_universal_slave_0_writedata     (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_writedata),     //  output,  width = 32,                                   .writedata
		.xcvr_rcfg_avalon_universal_slave_0_burstcount    (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_burstcount),    //  output,   width = 3,                                   .burstcount
		.xcvr_rcfg_avalon_universal_slave_0_byteenable    (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_byteenable),    //  output,   width = 4,                                   .byteenable
		.xcvr_rcfg_avalon_universal_slave_0_readdatavalid (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_readdatavalid), //   input,   width = 1,                                   .readdatavalid
		.xcvr_rcfg_avalon_universal_slave_0_waitrequest   (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_waitrequest),   //   input,   width = 1,                                   .waitrequest
		.xcvr_rcfg_avalon_universal_slave_0_lock          (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_lock),          //  output,   width = 1,                                   .lock
		.xcvr_rcfg_avalon_universal_slave_0_debugaccess   (mm_interconnect_0_xcvr_rcfg_avalon_universal_slave_0_debugaccess),   //  output,   width = 1,                                   .debugaccess
		.master_reset_reset_bridge_in_reset_reset         (rst_controller_reset_out_reset),                                     //   input,   width = 1, master_reset_reset_bridge_in_reset.reset
		.csr_clk_clk_clk                                  (csr_clk_clk_clk)                                                     //   input,   width = 1,                        csr_clk_clk.clk
	);

	altera_reset_controller #(
		.NUM_RESET_INPUTS          (1),
		.OUTPUT_RESET_SYNC_EDGES   ("deassert"),
		.SYNC_DEPTH                (2),
		.RESET_REQUEST_PRESENT     (0),
		.RESET_REQ_WAIT_TIME       (1),
		.MIN_RST_ASSERTION_TIME    (3),
		.RESET_REQ_EARLY_DSRT_TIME (1),
		.USE_RESET_REQUEST_IN0     (0),
		.USE_RESET_REQUEST_IN1     (0),
		.USE_RESET_REQUEST_IN2     (0),
		.USE_RESET_REQUEST_IN3     (0),
		.USE_RESET_REQUEST_IN4     (0),
		.USE_RESET_REQUEST_IN5     (0),
		.USE_RESET_REQUEST_IN6     (0),
		.USE_RESET_REQUEST_IN7     (0),
		.USE_RESET_REQUEST_IN8     (0),
		.USE_RESET_REQUEST_IN9     (0),
		.USE_RESET_REQUEST_IN10    (0),
		.USE_RESET_REQUEST_IN11    (0),
		.USE_RESET_REQUEST_IN12    (0),
		.USE_RESET_REQUEST_IN13    (0),
		.USE_RESET_REQUEST_IN14    (0),
		.USE_RESET_REQUEST_IN15    (0),
		.ADAPT_RESET_REQUEST       (0)
	) rst_controller (
		.reset_in0      (~csr_clk_clk_reset_reset),       //   input,  width = 1, reset_in0.reset
		.clk            (csr_clk_clk_clk),                //   input,  width = 1,       clk.clk
		.reset_out      (rst_controller_reset_out_reset), //  output,  width = 1, reset_out.reset
		.reset_req      (),                               // (terminated),                       
		.reset_req_in0  (1'b0),                           // (terminated),                       
		.reset_in1      (1'b0),                           // (terminated),                       
		.reset_req_in1  (1'b0),                           // (terminated),                       
		.reset_in2      (1'b0),                           // (terminated),                       
		.reset_req_in2  (1'b0),                           // (terminated),                       
		.reset_in3      (1'b0),                           // (terminated),                       
		.reset_req_in3  (1'b0),                           // (terminated),                       
		.reset_in4      (1'b0),                           // (terminated),                       
		.reset_req_in4  (1'b0),                           // (terminated),                       
		.reset_in5      (1'b0),                           // (terminated),                       
		.reset_req_in5  (1'b0),                           // (terminated),                       
		.reset_in6      (1'b0),                           // (terminated),                       
		.reset_req_in6  (1'b0),                           // (terminated),                       
		.reset_in7      (1'b0),                           // (terminated),                       
		.reset_req_in7  (1'b0),                           // (terminated),                       
		.reset_in8      (1'b0),                           // (terminated),                       
		.reset_req_in8  (1'b0),                           // (terminated),                       
		.reset_in9      (1'b0),                           // (terminated),                       
		.reset_req_in9  (1'b0),                           // (terminated),                       
		.reset_in10     (1'b0),                           // (terminated),                       
		.reset_req_in10 (1'b0),                           // (terminated),                       
		.reset_in11     (1'b0),                           // (terminated),                       
		.reset_req_in11 (1'b0),                           // (terminated),                       
		.reset_in12     (1'b0),                           // (terminated),                       
		.reset_req_in12 (1'b0),                           // (terminated),                       
		.reset_in13     (1'b0),                           // (terminated),                       
		.reset_req_in13 (1'b0),                           // (terminated),                       
		.reset_in14     (1'b0),                           // (terminated),                       
		.reset_req_in14 (1'b0),                           // (terminated),                       
		.reset_in15     (1'b0),                           // (terminated),                       
		.reset_req_in15 (1'b0)                            // (terminated),                       
	);

endmodule
