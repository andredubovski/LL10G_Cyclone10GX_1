// (C) 2001-2018 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1 ps / 1 ps

module altera_eth_top # (
    parameter NUM_OF_CHANNEL = 2
 )(
    
    // Clock
    input                               clk_125,
    input                               refclk_10g,
	 output										 clk_out,
    
    // Reset
    input                               reset_n,
    
    // Serial Interface
    input       [NUM_OF_CHANNEL-1:0]    rx_serial_data,
    output      [NUM_OF_CHANNEL-1:0]    tx_serial_data,
    
    // LED
    output      [NUM_OF_CHANNEL-1:0]    channel_ready_n,
	 output										 led_heartbeat,
	 output										 led_other,
	 
	 // Pushbutton
	 input etheron_button,
	 input dac_button,
    
	 // I2C interface
	 output          sfp_scl_0,
	 output          sfp_scl_1,
    output          sfp_sda_0,
    output          sfp_sda_1,
	 input           sfp_int_0,
	 input           sfp_int_1,
	 output arduino_scl,
	 output arduino_sda,
	 
	 //FMC inputs / outputs
	 input fmc_in[31:0], // only 15:0 used by first eth port, next 16 used by second eth port
	 output fmc_out[31:0] // ""

);

	 
	 // Heartbeat
	 reg [31:0] cnt = 32'd0;
	 reg led_clk_reg;
	 assign led_heartbeat = led_clk_reg;
	 always @(posedge clk_125) begin
		if (cnt == 32'h7735940) // 125000000
		begin
			cnt <= 32'd0;
			led_clk_reg <= ~led_clk_reg;
		end
		else cnt <= cnt + 32'd1;
	 end

    // Maximum number of channels defined in address decoder
    localparam MAX_NUM_OF_CHANNEL = 12;
    
    localparam ODD_NUM_CHANNEL = (NUM_OF_CHANNEL % 2 > 0) ? 1 : 0;
    localparam LAST_TRAFIIC_CTRL_PAIR = (divceil(NUM_OF_CHANNEL, 2) - 1);
    
    // Loop Control Variable
    genvar i;
    
    // Clock
    wire                                csr_clk;    // 125 MHz
    wire                                mac64b_clk; // 156.25 MHz via pll
    wire                                mac32b_clk; // 312.5  MHz via pll   (156.25 MHz *2)
	 wire   										 fast1_clk;  // 9.765625 MHz via pll (156.25 MHz /16)
	 wire   										 fast2_clk;  // 468.75 MHz  via pll  (156.25 MHz *3)
	 assign clk_out = fast1_clk; // output for sync
	 
	 // Heartbeat fast
	 reg [31:0] cnt_fast = 32'd0;
	 reg led_clk_reg_fast;
	 assign led_other = led_clk_reg_fast;
	 always @(posedge fast1_clk) begin
		if (cnt_fast == 32'h773594) // 12500000 (so should go at 9.765625*16/125 = 156.25/125 times other heartbeat)
		begin
			cnt_fast <= 32'd0;
			led_clk_reg_fast <= ~led_clk_reg_fast;
		end
		else cnt_fast <= cnt_fast + 32'd1;
	 end
    
    // Reset
    wire [NUM_OF_CHANNEL-1:0]           tx_digitalreset;
    wire [NUM_OF_CHANNEL-1:0]           rx_digitalreset;
    wire                                reset_mac64b_clk;
    
    // JTAG CSR
    wire                     [31:0]     jtag_if_address;
    wire                                jtag_if_read;
    wire                                jtag_if_write;
    wire                     [31:0]     jtag_if_writedata;
    wire                     [31:0]     jtag_if_readdata;
    wire                                jtag_if_readdatavalid;
    wire                                jtag_if_waitrequest;
    
    // Multi-channel CSR
    wire                     [19:0]     csr_mch_address;
    wire                                csr_mch_read;
    wire                                csr_mch_write;
    wire                     [31:0]     csr_mch_writedata;
    wire                     [31:0]     csr_mch_readdata;
    wire                                csr_mch_waitrequest;
    
    // MAC TX User Frame
    wire [NUM_OF_CHANNEL-1:0]           avalon_st_tx_valid;
    wire [NUM_OF_CHANNEL-1:0]           avalon_st_tx_ready;
    wire [NUM_OF_CHANNEL-1:0]           avalon_st_tx_startofpacket;
    wire [NUM_OF_CHANNEL-1:0]           avalon_st_tx_endofpacket;
    wire [NUM_OF_CHANNEL-1:0][63:0]     avalon_st_tx_data;
    wire [NUM_OF_CHANNEL-1:0][ 2:0]     avalon_st_tx_empty;
    wire [NUM_OF_CHANNEL-1:0]           avalon_st_tx_error;
    
    // MAC RX User Frame
    wire [NUM_OF_CHANNEL-1:0]           avalon_st_rx_valid;
    wire [NUM_OF_CHANNEL-1:0]           avalon_st_rx_ready;
    wire [NUM_OF_CHANNEL-1:0]           avalon_st_rx_startofpacket;
    wire [NUM_OF_CHANNEL-1:0]           avalon_st_rx_endofpacket;
    wire [NUM_OF_CHANNEL-1:0][63:0]     avalon_st_rx_data;
    wire [NUM_OF_CHANNEL-1:0][ 2:0]     avalon_st_rx_empty;
    wire [NUM_OF_CHANNEL-1:0][ 5:0]     avalon_st_rx_error;
    
    // MAC Status
    wire [NUM_OF_CHANNEL-1:0][ 1:0]     avalon_st_pause_data;
    wire [NUM_OF_CHANNEL-1:0]           avalon_st_rxstatus_valid;
    wire [NUM_OF_CHANNEL-1:0][39:0]     avalon_st_rxstatus_data;
    wire [NUM_OF_CHANNEL-1:0][ 6:0]     avalon_st_rxstatus_error;
    
    // Data Path Readiness
    wire [NUM_OF_CHANNEL-1:0]           channel_tx_ready;
    wire [NUM_OF_CHANNEL-1:0]           channel_rx_ready;
    
    // Traffic Controller CSR
    wire [MAX_NUM_OF_CHANNEL/2-1:0][13:0]csr_traffic_controller_address;
    wire [MAX_NUM_OF_CHANNEL/2-1:0]      csr_traffic_controller_read;
    wire [MAX_NUM_OF_CHANNEL/2-1:0]      csr_traffic_controller_write;
    wire [MAX_NUM_OF_CHANNEL/2-1:0][31:0]csr_traffic_controller_writedata;
    wire [MAX_NUM_OF_CHANNEL/2-1:0][31:0]csr_traffic_controller_readdata;
    wire [MAX_NUM_OF_CHANNEL/2-1:0]      csr_traffic_controller_waitrequest;
    
    // Clock
    assign csr_clk = clk_125;
    
    // Channel Ready
    assign channel_ready_n = ~(channel_tx_ready & channel_rx_ready);
    
    // Unused ports
    reg  [NUM_OF_CHANNEL-1:0][ 1:0]     avalon_st_pause_data_reg                /* synthesis noprune */;
    reg  [NUM_OF_CHANNEL-1:0]           avalon_st_rxstatus_valid_reg            /* synthesis noprune */;
    reg  [NUM_OF_CHANNEL-1:0][39:0]     avalon_st_rxstatus_data_reg             /* synthesis noprune */;
    reg  [NUM_OF_CHANNEL-1:0][ 6:0]     avalon_st_rxstatus_error_reg            /* synthesis noprune */;
    
    genvar j;
    generate
    for(j = 0; j < NUM_OF_CHANNEL; j = j + 1)
    begin : UNUSED_PORTS
        always @(posedge mac64b_clk) begin
            avalon_st_pause_data_reg[j]                <= 2'd0;
            avalon_st_rxstatus_valid_reg[j]            <= avalon_st_rxstatus_valid[j];
            avalon_st_rxstatus_data_reg[j]             <= avalon_st_rxstatus_data[j];
            avalon_st_rxstatus_error_reg[j]            <= avalon_st_rxstatus_error[j];
        end
        assign avalon_st_pause_data[j] = avalon_st_pause_data_reg[j];
    end
    endgenerate
    
    // Reset
    alt_mge_reset_synchronizer #(
        .DEPTH      (2),
        .ASYNC_RESET(1)
    ) lb_fifo_reset_sync (
        .clk        (mac64b_clk),
        .reset_in   (~reset_n),
        .reset_out  (reset_mac64b_clk)
    );
	 
	 wire i2c_etheron_trigger; //pushbutton 1 (PB1 on the Dev Kit PCB)
	 wire i2c_dac_trigger;
	 wire i2c_slow_clk_out;			//don't need this
	 wire i2c_slow_clk_ether_out;			//don't need this
	 wire etheron_scl;
	 wire etheron_sda;
	 wire dac_scl;
	 wire dac_sda;
	 wire i2c_reset_led;			//don't need this
	 wire dac_sequence_switch;
	 
	 
	 // I2C interface
	 assign      sfp_scl_0 = etheron_scl;
	 assign      sfp_scl_1 = etheron_scl;
	 assign      sfp_sda_0 = etheron_sda;
	 assign      sfp_sda_1 = etheron_sda;
	 assign		 arduino_scl = dac_scl;
	 assign      arduino_sda = dac_sda;
	 
	 assign		 i2c_etheron_trigger = etheron_button;
	 assign		 i2c_dac_trigger = dac_button && dac_change;
	 assign      dac_sequence_switch = led_heartbeat;
	 
	 // I2C console command interface
	 wire chip_id_out;
	 wire [3:0] channel_out;
	 wire [11:0] vol_out;
	 wire dac_change_out;
	 
	 //direct console command interface
	 wire chip_id;
	 wire [3:0] channel;
	 wire [11:0] vol;
	 wire dac_change;
	 reg chip_id_reg = 1'b0;
	 reg [3:0] channel_reg = 4'b0;
	 reg [11:0] vol_reg = 12'd2000;
	 reg dac_change_reg = 1'b1;
	 assign chip_id = chip_id_reg;
	 assign channel = channel_reg;
	 assign vol = vol_reg;
	 assign dac_change = dac_change_reg;
	 
	 wire console_write;
	 wire [31:0] console_writedata;
	 
	 assign console_write = csr_traffic_controller_write[0];
	 assign console_writedata = csr_traffic_controller_writedata[0];
	 assign console_address = csr_traffic_controller_address[0][9:2];
	 
	 parameter ADDR_chip_id = 8'h25;
	 parameter ADDR_channel = 8'h26;
	 parameter ADDR_vol = 8'h27;
	 parameter ADDR_button = 8'h28;
	 
	 always @ (posedge mac64b_clk)
    begin
		if (console_write & console_address == ADDR_chip_id) chip_id_reg <= console_writedata[0];
		else if (console_write & console_address == ADDR_channel) channel_reg <= console_writedata[3:0];
		else if (console_write & console_address == ADDR_vol) vol_reg <= console_writedata[11:0]; 
		else if (console_write & console_address == ADDR_button) dac_change_reg <= console_writedata[0];
    end
	 
	 
	 //I2C
	 i2c_generator i2c_generator (
	     .clk_in 							(fast1_clk),
		  .reset_in 						(reset_n),
		  .button_in						(i2c_dac_trigger),
		  .button_ether_in				(i2c_etheron_trigger),
		  .slow_clk_out					(i2c_slow_clk_out),
		  .slow_clk_stgr_out				(dac_scl),
		  .slow_clk_ether_out			(i2c_slow_clk_ether_out),
		  .slow_clk_ether_stgr_out		(etheron_scl),
		  .pulse_out						(dac_sda),
		  .pulse_ether_out				(etheron_sda),
		  .reset_led						(i2c_reset_led),
		  .sequence_switch				(dac_sequence_switch),
		  
		  .chip_id 							(chip_id),
	     .dac_id		               (dac_id),
	     .vol				            (vol)
	 );
    
    // DUT
    alt_mge_multi_channel #(
        .NUM_OF_CHANNEL                 (NUM_OF_CHANNEL)
    ) DUT (
        
        // Reference Clock
        .refclk_10g                     (refclk_10g),
        
        // CSR Clock
        .csr_clk                        (csr_clk),
        
        // MAC Clock
        .mac32b_clk                     (mac32b_clk),
        
        // XGMII Clock
        .mac64b_clk                     (mac64b_clk),
		  
		  // more clocks
		  .fast1_clk (fast1_clk),
		  .fast2_clk (fast2_clk),
        
        // Reset
        .reset                          (~reset_n),
        .tx_digitalreset                (tx_digitalreset),
        .rx_digitalreset                (rx_digitalreset),
        
        // CSR
        .csr_mch_address                (csr_mch_address),
        .csr_mch_read                   (csr_mch_read),
        .csr_mch_write                  (csr_mch_write),
        .csr_mch_writedata              (csr_mch_writedata),
        .csr_mch_readdata               (csr_mch_readdata),
        .csr_mch_waitrequest            (csr_mch_waitrequest),
        
        // MAC TX User Frame
        .avalon_st_tx_valid             (avalon_st_tx_valid),
        .avalon_st_tx_ready             (avalon_st_tx_ready),
        .avalon_st_tx_startofpacket     (avalon_st_tx_startofpacket),
        .avalon_st_tx_endofpacket       (avalon_st_tx_endofpacket),
        .avalon_st_tx_data              (avalon_st_tx_data),
        .avalon_st_tx_empty             (avalon_st_tx_empty),
        .avalon_st_tx_error             (avalon_st_tx_error),
        
        // MAC RX User Frame
        .avalon_st_rx_valid             (avalon_st_rx_valid),
        .avalon_st_rx_ready             (avalon_st_rx_ready),
        .avalon_st_rx_startofpacket     (avalon_st_rx_startofpacket),
        .avalon_st_rx_endofpacket       (avalon_st_rx_endofpacket),
        .avalon_st_rx_data              (avalon_st_rx_data),
        .avalon_st_rx_empty             (avalon_st_rx_empty),
        .avalon_st_rx_error             (avalon_st_rx_error),
        
        // MAC TX Frame Status
        .avalon_st_txstatus_valid       (),
        .avalon_st_txstatus_data        (),
        .avalon_st_txstatus_error       (),
        
        // MAC RX Frame Status
        .avalon_st_rxstatus_valid       (avalon_st_rxstatus_valid),
        .avalon_st_rxstatus_data        (avalon_st_rxstatus_data),
        .avalon_st_rxstatus_error       (avalon_st_rxstatus_error),
        
        // MAC TX Pause Frame Generation Command
        .avalon_st_pause_data           (avalon_st_pause_data),
        
        // MAC Status
        .xgmii_rx_link_fault_status     (),
        
        // PHY Status
        .led_an                         (),
        .rx_block_lock                  (),
        
        // Transceiver Serial Interface
        .tx_serial_data                 (tx_serial_data),
        .rx_serial_data                 (rx_serial_data),
        .rx_pma_clkout                  (),
        
        // Data Path Readiness
        .channel_tx_ready               (channel_tx_ready),
        .channel_rx_ready               (channel_rx_ready)
        
    );
    
    generate for (i = 0; i < MAX_NUM_OF_CHANNEL/2; i = i + 1)
        begin: ETH_TRAFFIC_CTRL_PAIR_CHANNEL
            if(i < (divceil(NUM_OF_CHANNEL, 2))) begin
                
                if((ODD_NUM_CHANNEL == 1) && (i == LAST_TRAFIIC_CTRL_PAIR)) begin
                    
                    eth_traffic_controller_top #(
                        .NUM_CHANNELS       (2),
                        .TSTAMP_FP_WIDTH    (4)
                    ) eth_traffic_controller (
								.refclk_10g                     				  (refclk_10g),
                        .clk                                        (mac64b_clk),
                        .reset_n                                    (~reset_mac64b_clk),
								.fmc_in (fmc_in),
								.fmc_out (fmc_out),
								.fast1_clk (fast1_clk),
								.fast2_clk (fast2_clk),
                        
                        .avl_mm_baddress                            (csr_traffic_controller_address[i]),
                        .avl_mm_read                                (csr_traffic_controller_read[i]),
                        .avl_mm_write                               (csr_traffic_controller_write[i]),
                        .avl_mm_writedata                           (csr_traffic_controller_writedata[i]),
                        .avl_mm_readdata                            (csr_traffic_controller_readdata[i]),
                        .avl_mm_waitrequest                         (csr_traffic_controller_waitrequest[i]),
                        
                        .avl_st_tx_val                              ( {       avalon_st_tx_valid        [2*i] } ),
                        .avl_st_tx_ready                            ( { 1'b0, avalon_st_tx_ready        [2*i] } ),
                        .avl_st_tx_sop                              ( {       avalon_st_tx_startofpacket[2*i] } ),
                        .avl_st_tx_eop                              ( {       avalon_st_tx_endofpacket  [2*i] } ),
                        .avl_st_tx_data                             ( {       avalon_st_tx_data         [2*i] } ),
                        .avl_st_tx_empty                            ( {       avalon_st_tx_empty        [2*i] } ),
                        .avl_st_tx_error                            ( {       avalon_st_tx_error        [2*i] } ),
                        
                        .avl_st_rx_val                              ( { 1'b0, avalon_st_rx_valid        [2*i] } ),
                        .avl_st_rx_ready                            ( {       avalon_st_rx_ready        [2*i] } ),
                        .avl_st_rx_sop                              ( { 1'b0, avalon_st_rx_startofpacket[2*i] } ),
                        .avl_st_rx_eop                              ( { 1'b0, avalon_st_rx_endofpacket  [2*i] } ),
                        .avl_st_rx_data                             ( {64'h0, avalon_st_rx_data         [2*i] } ),
                        .avl_st_rx_empty                            ( { 3'h0, avalon_st_rx_empty        [2*i] } ),
                        .avl_st_rx_error                            ( { 1'b0, avalon_st_rx_error        [2*i] } ),
                        
                        .avl_st_tx_status_valid                     ({2{1'b0}}),
                        .avl_st_tx_status_data                      ({2{40'h0}}),
                        .avl_st_tx_status_error                     ({2{7'h0}}),
                        
                        .avl_st_rx_status_valid                     ({2{1'b0}}),
                        .avl_st_rx_status_data                      ({2{40'h0}}),
                        .avl_st_rx_status_error                     ({2{7'h0}}),
                        
                        .tx_egress_timestamp_96b_valid              ({2{1'b0}}),
                        .tx_egress_timestamp_96b_data               ({2{96'h0}}),
                        .tx_egress_timestamp_96b_fingerprint        ({2{4'h0}}),
                        
                        .tx_egress_timestamp_request_fingerprint    (),
                        .tx_egress_timestamp_request_valid          (),
                        
                        .rx_ingress_timestamp_96b_valid             ({2{1'b0}}),
                        .rx_ingress_timestamp_96b_data              ({2{96'h0}}),
                        
                        .eth_std_stop_mon                           (2'b00),
                        .eth_std_mon_active                         (),
                        .eth_std_mon_done                           (),
                        .eth_std_mon_error                          (),
                        
                        .eth_1588_wait_limit                        (1'b1),
                        .eth_1588_start_tod_sync                    (),
                        .eth_1588_channel_ready                     (2'b11),
                        .eth_1588_traffic_controller_error_n        (),
								
								.chip_id_out         (chip_id_out),
								.channel_out         (channel_out),
								.vol_out             (vol_out),
								.change_dac_out      (change_dac_out)
                    );
                    
                end
                else begin
                    
                    eth_traffic_controller_top #(
                        .NUM_CHANNELS       (2),
                        .TSTAMP_FP_WIDTH    (4)
                    ) eth_traffic_controller (
                        .clk                                        (mac64b_clk),
                        .reset_n                                    (~reset_mac64b_clk),
								.fmc_in (fmc_in),
								.fmc_out (fmc_out),
								.fast1_clk (fast1_clk),
								.fast2_clk (fast2_clk),
                        
                        .avl_mm_baddress                            (csr_traffic_controller_address[i]),
                        .avl_mm_read                                (csr_traffic_controller_read[i]),
                        .avl_mm_write                               (csr_traffic_controller_write[i]),
                        .avl_mm_writedata                           (csr_traffic_controller_writedata[i]),
                        .avl_mm_readdata                            (csr_traffic_controller_readdata[i]),
                        .avl_mm_waitrequest                         (csr_traffic_controller_waitrequest[i]),
                        
                        .avl_st_tx_val                              (avalon_st_tx_valid         [2*(i+1)-1: 2*i]),
                        .avl_st_tx_ready                            (avalon_st_tx_ready         [2*(i+1)-1: 2*i]),
                        .avl_st_tx_sop                              (avalon_st_tx_startofpacket [2*(i+1)-1: 2*i]),
                        .avl_st_tx_eop                              (avalon_st_tx_endofpacket   [2*(i+1)-1: 2*i]),
                        .avl_st_tx_data                             (avalon_st_tx_data          [2*(i+1)-1: 2*i]),
                        .avl_st_tx_empty                            (avalon_st_tx_empty         [2*(i+1)-1: 2*i]),
                        .avl_st_tx_error                            (avalon_st_tx_error         [2*(i+1)-1: 2*i]),
                        
                        .avl_st_rx_val                              (avalon_st_rx_valid         [2*(i+1)-1: 2*i]),
                        .avl_st_rx_ready                            (avalon_st_rx_ready         [2*(i+1)-1: 2*i]),
                        .avl_st_rx_sop                              (avalon_st_rx_startofpacket [2*(i+1)-1: 2*i]),
                        .avl_st_rx_eop                              (avalon_st_rx_endofpacket   [2*(i+1)-1: 2*i]),
                        .avl_st_rx_data                             (avalon_st_rx_data          [2*(i+1)-1: 2*i]),
                        .avl_st_rx_empty                            (avalon_st_rx_empty         [2*(i+1)-1: 2*i]),
                        .avl_st_rx_error                            (avalon_st_rx_error         [2*(i+1)-1: 2*i]),
                        
                        .avl_st_tx_status_valid                     ({2{1'b0}}),
                        .avl_st_tx_status_data                      ({2{40'h0}}),
                        .avl_st_tx_status_error                     ({2{7'h0}}),
                        
                        .avl_st_rx_status_valid                     ({2{1'b0}}),
                        .avl_st_rx_status_data                      ({2{40'h0}}),
                        .avl_st_rx_status_error                     ({2{7'h0}}),
                        
                        .tx_egress_timestamp_96b_valid              ({2{1'b0}}),
                        .tx_egress_timestamp_96b_data               ({2{96'h0}}),
                        .tx_egress_timestamp_96b_fingerprint        ({2{4'h0}}),
                        
                        .tx_egress_timestamp_request_fingerprint    (),
                        .tx_egress_timestamp_request_valid          (),
                        
                        .rx_ingress_timestamp_96b_valid             ({2{1'b0}}),
                        .rx_ingress_timestamp_96b_data              ({2{96'h0}}),
                        
                        .eth_std_stop_mon                           (2'b00),
                        .eth_std_mon_active                         (),
                        .eth_std_mon_done                           (),
                        .eth_std_mon_error                          (),
                        
                        .eth_1588_wait_limit                        (1'b1),
                        .eth_1588_start_tod_sync                    (),
                        .eth_1588_channel_ready                     (2'b11),
                        .eth_1588_traffic_controller_error_n        (),
								
								.chip_id_out         (chip_id_out),
								.channel_out         (channel_out),
								.vol_out             (vol_out),
								.change_dac_out      (change_dac_out)
                    );
                    
                end
                
            end
            
            else begin
                assign csr_traffic_controller_readdata[i] = 32'h0;
                assign csr_traffic_controller_waitrequest[i] = 1'b0;
            end
        end
    endgenerate 
    
    // JTAG Master
    alt_jtag_csr_master jtag_master (
        .clk_clk                           (csr_clk),
        .clk_reset_reset                   (~reset_n),
        .master_address                    (jtag_if_address),
        .master_write                      (jtag_if_write),
        .master_read                       (jtag_if_read),
        .master_writedata                  (jtag_if_writedata),
        .master_readdata                   (jtag_if_readdata),
        .master_readdatavalid              (jtag_if_readdatavalid),
        .master_waitrequest                (jtag_if_waitrequest)
    );
	 
    
    // Avalon-MM Address Decoder
    address_decoder_top address_decoder_top (
        .csr_clk_clk                            (csr_clk),
        .csr_clk_reset_reset_n                  (reset_n),
        
        .mac_clk_clk                            (mac64b_clk),
        .mac_clk_reset_reset_n                  (reset_n),
        
        // Byte addressing
        .slave_address                          (jtag_if_address[25:0]),
        .slave_write                            (jtag_if_write),
        .slave_read                             (jtag_if_read),
        .slave_writedata                        (jtag_if_writedata),
        .slave_readdata                         (jtag_if_readdata),
        .slave_readdatavalid                    (jtag_if_readdatavalid),
        .slave_waitrequest                      (jtag_if_waitrequest),
        
        // Byte addressing
        .multi_channel_address                  (csr_mch_address),
        .multi_channel_read                     (csr_mch_read),
        .multi_channel_write                    (csr_mch_write),
        .multi_channel_writedata                (csr_mch_writedata),
        .multi_channel_readdata                 (csr_mch_readdata),
        .multi_channel_waitrequest              (csr_mch_waitrequest),
        
        // Byte addressing
        .traffic_controller_ch_0_1_address      (csr_traffic_controller_address     [0]),
        .traffic_controller_ch_0_1_read         (csr_traffic_controller_read        [0]),
        .traffic_controller_ch_0_1_write        (csr_traffic_controller_write       [0]),
        .traffic_controller_ch_0_1_writedata    (csr_traffic_controller_writedata   [0]),
        .traffic_controller_ch_0_1_readdata     (csr_traffic_controller_readdata    [0]),
        .traffic_controller_ch_0_1_waitrequest  (csr_traffic_controller_waitrequest [0]),
        
        // Byte addressing
        .traffic_controller_ch_2_3_address      (csr_traffic_controller_address     [1]),
        .traffic_controller_ch_2_3_read         (csr_traffic_controller_read        [1]),
        .traffic_controller_ch_2_3_write        (csr_traffic_controller_write       [1]),
        .traffic_controller_ch_2_3_writedata    (csr_traffic_controller_writedata   [1]),
        .traffic_controller_ch_2_3_readdata     (csr_traffic_controller_readdata    [1]),
        .traffic_controller_ch_2_3_waitrequest  (csr_traffic_controller_waitrequest [1]),
        
        // Byte addressing
        .traffic_controller_ch_4_5_address      (csr_traffic_controller_address     [2]),
        .traffic_controller_ch_4_5_read         (csr_traffic_controller_read        [2]),
        .traffic_controller_ch_4_5_write        (csr_traffic_controller_write       [2]),
        .traffic_controller_ch_4_5_writedata    (csr_traffic_controller_writedata   [2]),
        .traffic_controller_ch_4_5_readdata     (csr_traffic_controller_readdata    [2]),
        .traffic_controller_ch_4_5_waitrequest  (csr_traffic_controller_waitrequest [2]),
        
        // Byte addressing
        .traffic_controller_ch_6_7_address      (csr_traffic_controller_address     [3]),
        .traffic_controller_ch_6_7_read         (csr_traffic_controller_read        [3]),
        .traffic_controller_ch_6_7_write        (csr_traffic_controller_write       [3]),
        .traffic_controller_ch_6_7_writedata    (csr_traffic_controller_writedata   [3]),
        .traffic_controller_ch_6_7_readdata     (csr_traffic_controller_readdata    [3]),
        .traffic_controller_ch_6_7_waitrequest  (csr_traffic_controller_waitrequest [3]),
        
        // Byte addressing
        .traffic_controller_ch_8_9_address      (csr_traffic_controller_address     [4]),
        .traffic_controller_ch_8_9_read         (csr_traffic_controller_read        [4]),
        .traffic_controller_ch_8_9_write        (csr_traffic_controller_write       [4]),
        .traffic_controller_ch_8_9_writedata    (csr_traffic_controller_writedata   [4]),
        .traffic_controller_ch_8_9_readdata     (csr_traffic_controller_readdata    [4]),
        .traffic_controller_ch_8_9_waitrequest  (csr_traffic_controller_waitrequest [4]),
        
        // Byte addressing
        .traffic_controller_ch_10_11_address    (csr_traffic_controller_address     [5]),
        .traffic_controller_ch_10_11_read       (csr_traffic_controller_read        [5]),
        .traffic_controller_ch_10_11_write      (csr_traffic_controller_write       [5]),
        .traffic_controller_ch_10_11_writedata  (csr_traffic_controller_writedata   [5]),
        .traffic_controller_ch_10_11_readdata   (csr_traffic_controller_readdata    [5]),
        .traffic_controller_ch_10_11_waitrequest(csr_traffic_controller_waitrequest [5])
    );
    
    // --------------------------------------------------
    // Calculates the divceil of the input value (m/n)
    // --------------------------------------------------
    function integer divceil;
        input integer m;
        input integer n;
        integer i;
        
        begin
            i = m % n;
            divceil = (m/n);
            if (i > 0) begin
                divceil = divceil + 1;
            end
        end
    endfunction
    
endmodule

