// (C) 2001-2018 Intel Corporation. All rights reserved.
//Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


module eth_traffic_controller_top  #(
	parameter 	NUM_CHANNELS = 2,					// must set to 2 only
	parameter 	TSTAMP_FP_WIDTH = 4
)(
	input		wire				                     	refclk_10g,
	input 	wire 												clk,
	input 	wire 												reset_n,
	input		wire[31:0]  									fmc_in, // Inputs from FMC
	output   wire[31:0]										fmc_out, // Outputs to the FMC
	input wire fast1_clk,
	input wire fast2_clk,
	                        									
	//Avalon MM             									
	input 	wire														avl_mm_read,
	input 	wire														avl_mm_write,
	output 	reg														avl_mm_waitrequest,
	input 	wire	[13:0]											avl_mm_baddress,
	output 	reg	[31:0]											avl_mm_readdata,
	input 	wire	[31:0]											avl_mm_writedata,
	
	//Avalon ST
	output 	wire	[NUM_CHANNELS-1:0][63:0] 					avl_st_tx_data,
	output 	wire	[NUM_CHANNELS-1:0][2:0]  					avl_st_tx_empty,
	output 	wire	[NUM_CHANNELS-1:0] 							avl_st_tx_eop,
	output 	wire	[NUM_CHANNELS-1:0] 							avl_st_tx_error,
	input 	wire	[NUM_CHANNELS-1:0] 							avl_st_tx_ready,
	output 	wire	[NUM_CHANNELS-1:0] 							avl_st_tx_sop,
	output 	wire	[NUM_CHANNELS-1:0] 							avl_st_tx_val,             
                	                            				
	input 	wire	[NUM_CHANNELS-1:0][63:0] 					avl_st_rx_data,
	input 	wire	[NUM_CHANNELS-1:0][2:0]  					avl_st_rx_empty,
	input 	wire	[NUM_CHANNELS-1:0] 							avl_st_rx_eop,
	input 	wire	[NUM_CHANNELS-1:0][5:0]						avl_st_rx_error,
	output 	wire	[NUM_CHANNELS-1:0] 							avl_st_rx_ready,
	input 	wire	[NUM_CHANNELS-1:0] 							avl_st_rx_sop,
	input 	wire	[NUM_CHANNELS-1:0] 							avl_st_rx_val,
	                                            				
	input 	wire	[NUM_CHANNELS-1:0]							avl_st_tx_status_valid,
	input 	wire	[NUM_CHANNELS-1:0][39:0] 					avl_st_tx_status_data,
	input 	wire	[NUM_CHANNELS-1:0][6:0]						avl_st_tx_status_error,
	                                            				
	input 	wire	[NUM_CHANNELS-1:0]							avl_st_rx_status_valid,
	input 	wire	[NUM_CHANNELS-1:0][39:0] 					avl_st_rx_status_data,
	input 	wire	[NUM_CHANNELS-1:0][6:0]						avl_st_rx_status_error,
	                                            				
	input 	wire  [NUM_CHANNELS-1:0]     								tx_egress_timestamp_96b_valid, 
   input 	wire 	[NUM_CHANNELS-1:0][95:0]  							tx_egress_timestamp_96b_data, 
   input 	wire 	[NUM_CHANNELS-1:0][TSTAMP_FP_WIDTH-1:0]   	tx_egress_timestamp_96b_fingerprint, 

   output 	wire 	[NUM_CHANNELS-1:0][TSTAMP_FP_WIDTH-1:0]  		tx_egress_timestamp_request_fingerprint, 
   output 	wire  [NUM_CHANNELS-1:0]    								tx_egress_timestamp_request_valid,
                                                				
   input 	wire  [NUM_CHANNELS-1:0]     								rx_ingress_timestamp_96b_valid, 
   input 	wire 	[NUM_CHANNELS-1:0][95:0]  							rx_ingress_timestamp_96b_data,
		                                        				
    //eth_std_traffic_controller control port   				
   input   wire	[NUM_CHANNELS-1:0]							eth_std_stop_mon,
	output  wire	[NUM_CHANNELS-1:0]							eth_std_mon_active,
	output  wire	[NUM_CHANNELS-1:0]							eth_std_mon_done,
	output  wire	[NUM_CHANNELS-1:0]							eth_std_mon_error,
                                                				
	//eth_1588_traffic_controller control port  				
   input  wire         												eth_1588_wait_limit,
	output	 wire		[1:0]												eth_1588_start_tod_sync,
	input	 wire   	[1:0]												eth_1588_channel_ready,
	output wire															eth_1588_traffic_controller_error_n
	
	
	,output wire 	 [NUM_CHANNELS-1:0]		  chip_id_out
   ,output wire 	 [NUM_CHANNELS-1:0][3:0]  channel_out
   ,output wire    [NUM_CHANNELS-1:0][11:0] vol_out
   ,output wire    [NUM_CHANNELS-1:0]       change_dac_out
);

wire	mux_sel;

//Avalon MM
wire	[NUM_CHANNELS-1:0]			eth_std_traffic_controller_avl_mm_read;
wire	[NUM_CHANNELS-1:0]			eth_std_traffic_controller_avl_mm_write;
wire	[NUM_CHANNELS-1:0]			eth_std_traffic_controller_avl_mm_waitrequest;
wire	[NUM_CHANNELS-1:0][11:0]	eth_std_traffic_controller_avl_mm_baddress;
wire	[NUM_CHANNELS-1:0][31:0]	eth_std_traffic_controller_avl_mm_readdata;
wire	[NUM_CHANNELS-1:0][31:0]	eth_std_traffic_controller_avl_mm_writedata;

wire										eth_1588_traffic_controller_avl_mm_read;
wire										eth_1588_traffic_controller_avl_mm_write;
wire										eth_1588_traffic_controller_avl_mm_waitrequest;
wire	[7:0]								eth_1588_traffic_controller_avl_mm_baddress;
wire	[31:0]							eth_1588_traffic_controller_avl_mm_readdata;
wire	[31:0]							eth_1588_traffic_controller_avl_mm_writedata;
                    				
wire										eth_traffic_selector_avl_mm_read;
wire										eth_traffic_selector_avl_mm_write;
wire										eth_traffic_selector_avl_mm_waitrequest;
wire	[0:0]								eth_traffic_selector_avl_mm_baddress;
wire	[31:0]							eth_traffic_selector_avl_mm_readdata;
wire	[31:0]							eth_traffic_selector_avl_mm_writedata;

wire	[NUM_CHANNELS-1:0][63:0] 	eth_std_avl_st_tx_data;
wire	[NUM_CHANNELS-1:0][2:0]  	eth_std_avl_st_tx_empty;
wire	[NUM_CHANNELS-1:0] 			eth_std_avl_st_tx_eop;
wire	[NUM_CHANNELS-1:0] 			eth_std_avl_st_tx_error;
wire	[NUM_CHANNELS-1:0] 			eth_std_avl_st_tx_ready;
wire	[NUM_CHANNELS-1:0] 			eth_std_avl_st_tx_sop;
wire	[NUM_CHANNELS-1:0] 			eth_std_avl_st_tx_val;   
    	
wire	[NUM_CHANNELS-1:0][63:0] 	eth_std_avl_st_rx_data;
wire	[NUM_CHANNELS-1:0][2:0]  	eth_std_avl_st_rx_empty;
wire	[NUM_CHANNELS-1:0] 			eth_std_avl_st_rx_eop;
wire	[NUM_CHANNELS-1:0][5:0]		eth_std_avl_st_rx_error;
wire	[NUM_CHANNELS-1:0] 			eth_std_avl_st_rx_ready;
wire	[NUM_CHANNELS-1:0] 			eth_std_avl_st_rx_sop;
wire	[NUM_CHANNELS-1:0] 			eth_std_avl_st_rx_val; 

wire	[NUM_CHANNELS-1:0][63:0] 	eth_1588_avl_st_tx_data;
wire	[NUM_CHANNELS-1:0][2:0]  	eth_1588_avl_st_tx_empty;
wire	[NUM_CHANNELS-1:0] 			eth_1588_avl_st_tx_eop;
wire	[NUM_CHANNELS-1:0] 			eth_1588_avl_st_tx_error;
wire	[NUM_CHANNELS-1:0] 			eth_1588_avl_st_tx_ready;
wire	[NUM_CHANNELS-1:0] 			eth_1588_avl_st_tx_sop;
wire	[NUM_CHANNELS-1:0] 			eth_1588_avl_st_tx_val;   
    	
wire	[NUM_CHANNELS-1:0][63:0] 	eth_1588_avl_st_rx_data;
wire	[NUM_CHANNELS-1:0][2:0]  	eth_1588_avl_st_rx_empty;
wire	[NUM_CHANNELS-1:0] 			eth_1588_avl_st_rx_eop;
wire	[NUM_CHANNELS-1:0][5:0]		eth_1588_avl_st_rx_error;
wire	[NUM_CHANNELS-1:0] 			eth_1588_avl_st_rx_ready;
wire	[NUM_CHANNELS-1:0] 			eth_1588_avl_st_rx_sop;
wire	[NUM_CHANNELS-1:0] 			eth_1588_avl_st_rx_val; 

wire	[NUM_CHANNELS-1:0][63:0] 	ch0_to_mux_avl_st_tx_data;
wire	[NUM_CHANNELS-1:0][2:0]  	ch0_to_mux_avl_st_tx_empty;
wire	[NUM_CHANNELS-1:0] 			ch0_to_mux_avl_st_tx_eop;
wire	[NUM_CHANNELS-1:0] 			ch0_to_mux_avl_st_tx_error;
wire	[NUM_CHANNELS-1:0] 			ch0_to_mux_avl_st_tx_ready;
wire	[NUM_CHANNELS-1:0] 			ch0_to_mux_avl_st_tx_sop;
wire	[NUM_CHANNELS-1:0] 			ch0_to_mux_avl_st_tx_val;   
    	
wire	[NUM_CHANNELS-1:0][63:0] 	ch0_to_mux_avl_st_rx_data;
wire	[NUM_CHANNELS-1:0][2:0]  	ch0_to_mux_avl_st_rx_empty;
wire	[NUM_CHANNELS-1:0] 			ch0_to_mux_avl_st_rx_eop;
wire	[NUM_CHANNELS-1:0][5:0]		ch0_to_mux_avl_st_rx_error;
wire	[NUM_CHANNELS-1:0] 			ch0_to_mux_avl_st_rx_ready;
wire	[NUM_CHANNELS-1:0] 			ch0_to_mux_avl_st_rx_sop;
wire	[NUM_CHANNELS-1:0] 			ch0_to_mux_avl_st_rx_val; 

assign	ch0_to_mux_avl_st_tx_data[0] 	= eth_1588_avl_st_tx_data[0];
assign	ch0_to_mux_avl_st_tx_empty[0]	= eth_1588_avl_st_tx_empty[0];
assign	ch0_to_mux_avl_st_tx_eop[0]	= eth_1588_avl_st_tx_eop[0]; 
assign	ch0_to_mux_avl_st_tx_error[0]	= eth_1588_avl_st_tx_error[0];
assign	eth_1588_avl_st_tx_ready[0]	= ch0_to_mux_avl_st_tx_ready[0]; 
assign	ch0_to_mux_avl_st_tx_sop[0]	= eth_1588_avl_st_tx_sop[0]; 
assign	ch0_to_mux_avl_st_tx_val[0]	= eth_1588_avl_st_tx_val[0]; 

assign	ch0_to_mux_avl_st_tx_data[1] 	= eth_std_avl_st_tx_data[0];
assign	ch0_to_mux_avl_st_tx_empty[1]	= eth_std_avl_st_tx_empty[0];
assign	ch0_to_mux_avl_st_tx_eop[1]	= eth_std_avl_st_tx_eop[0];
assign	ch0_to_mux_avl_st_tx_error[1]	= eth_std_avl_st_tx_error[0];
assign	eth_std_avl_st_tx_ready[0]		= ch0_to_mux_avl_st_tx_ready[1];
assign	ch0_to_mux_avl_st_tx_sop[1]	= eth_std_avl_st_tx_sop[0];
assign	ch0_to_mux_avl_st_tx_val[1]	= eth_std_avl_st_tx_val[0];   

assign	eth_1588_avl_st_rx_data[0]		= ch0_to_mux_avl_st_rx_data[0];	
assign	eth_1588_avl_st_rx_empty[0]	= ch0_to_mux_avl_st_rx_empty[0];	
assign	eth_1588_avl_st_rx_eop[0]		= ch0_to_mux_avl_st_rx_eop[0];		 
assign	eth_1588_avl_st_rx_error[0]	= ch0_to_mux_avl_st_rx_error[0];	
assign	ch0_to_mux_avl_st_rx_ready[0]	= eth_1588_avl_st_rx_ready[0];
assign	eth_1588_avl_st_rx_sop[0]		= ch0_to_mux_avl_st_rx_sop[0];		 
assign	eth_1588_avl_st_rx_val[0]		= ch0_to_mux_avl_st_rx_val[0];	

assign	eth_std_avl_st_rx_data[0]		= ch0_to_mux_avl_st_rx_data[1];
assign	eth_std_avl_st_rx_empty[0]		= ch0_to_mux_avl_st_rx_empty[1];	
assign	eth_std_avl_st_rx_eop[0] 		= ch0_to_mux_avl_st_rx_eop[1];		 
assign	eth_std_avl_st_rx_error[0]		= ch0_to_mux_avl_st_rx_error[1];	
assign	ch0_to_mux_avl_st_rx_ready[1]	= eth_std_avl_st_rx_ready[0];
assign	eth_std_avl_st_rx_sop[0] 		= ch0_to_mux_avl_st_rx_sop[1];		 
assign	eth_std_avl_st_rx_val[0] 		= ch0_to_mux_avl_st_rx_val[1];		   

wire	[NUM_CHANNELS-1:0][63:0] 	ch1_to_mux_avl_st_tx_data;
wire	[NUM_CHANNELS-1:0][2:0]  	ch1_to_mux_avl_st_tx_empty;
wire	[NUM_CHANNELS-1:0] 			ch1_to_mux_avl_st_tx_eop;
wire	[NUM_CHANNELS-1:0] 			ch1_to_mux_avl_st_tx_error;
wire	[NUM_CHANNELS-1:0] 			ch1_to_mux_avl_st_tx_ready;
wire	[NUM_CHANNELS-1:0] 			ch1_to_mux_avl_st_tx_sop;
wire	[NUM_CHANNELS-1:0] 			ch1_to_mux_avl_st_tx_val;   
    	
wire	[NUM_CHANNELS-1:0][63:0] 	ch1_to_mux_avl_st_rx_data;
wire	[NUM_CHANNELS-1:0][2:0]  	ch1_to_mux_avl_st_rx_empty;
wire	[NUM_CHANNELS-1:0] 			ch1_to_mux_avl_st_rx_eop;
wire	[NUM_CHANNELS-1:0][5:0]		ch1_to_mux_avl_st_rx_error;
wire	[NUM_CHANNELS-1:0] 			ch1_to_mux_avl_st_rx_ready;
wire	[NUM_CHANNELS-1:0] 			ch1_to_mux_avl_st_rx_sop;
wire	[NUM_CHANNELS-1:0] 			ch1_to_mux_avl_st_rx_val; 

assign	ch1_to_mux_avl_st_tx_data[0] 	= eth_1588_avl_st_tx_data[1];
assign	ch1_to_mux_avl_st_tx_empty[0]	= eth_1588_avl_st_tx_empty[1];
assign	ch1_to_mux_avl_st_tx_eop[0]	= eth_1588_avl_st_tx_eop[1]; 
assign	ch1_to_mux_avl_st_tx_error[0]	= eth_1588_avl_st_tx_error[1];
assign	eth_1588_avl_st_tx_ready[1]	= ch1_to_mux_avl_st_tx_ready[1]; 
assign	ch1_to_mux_avl_st_tx_sop[0]	= eth_1588_avl_st_tx_sop[1]; 
assign	ch1_to_mux_avl_st_tx_val[0]	= eth_1588_avl_st_tx_val[1]; 

assign	ch1_to_mux_avl_st_tx_data[1] 	= eth_std_avl_st_tx_data[1];
assign	ch1_to_mux_avl_st_tx_empty[1]	= eth_std_avl_st_tx_empty[1];
assign	ch1_to_mux_avl_st_tx_eop[1]	= eth_std_avl_st_tx_eop[1];
assign	ch1_to_mux_avl_st_tx_error[1]	= eth_std_avl_st_tx_error[1];
assign	eth_std_avl_st_tx_ready[1]		= ch1_to_mux_avl_st_tx_ready[1];
assign	ch1_to_mux_avl_st_tx_sop[1]	= eth_std_avl_st_tx_sop[1];
assign	ch1_to_mux_avl_st_tx_val[1]	= eth_std_avl_st_tx_val[1];   

assign	eth_1588_avl_st_rx_data[1]		= ch1_to_mux_avl_st_rx_data[0];	
assign	eth_1588_avl_st_rx_empty[1]	= ch1_to_mux_avl_st_rx_empty[0];	
assign	eth_1588_avl_st_rx_eop[1]		= ch1_to_mux_avl_st_rx_eop[0];		 
assign	eth_1588_avl_st_rx_error[1]	= ch1_to_mux_avl_st_rx_error[0];	
assign	ch1_to_mux_avl_st_rx_ready[0]	= eth_1588_avl_st_rx_ready[1];
assign	eth_1588_avl_st_rx_sop[1]		= ch1_to_mux_avl_st_rx_sop[0];		 
assign	eth_1588_avl_st_rx_val[1]		= ch1_to_mux_avl_st_rx_val[0];	

assign	eth_std_avl_st_rx_data[1]		= ch1_to_mux_avl_st_rx_data[1];
assign	eth_std_avl_st_rx_empty[1]		= ch1_to_mux_avl_st_rx_empty[1];	
assign	eth_std_avl_st_rx_eop[1] 		= ch1_to_mux_avl_st_rx_eop[1];		 
assign	eth_std_avl_st_rx_error[1]		= ch1_to_mux_avl_st_rx_error[1];	
assign	ch1_to_mux_avl_st_rx_ready[1]	= eth_std_avl_st_rx_ready[1];
assign	eth_std_avl_st_rx_sop[1] 		= ch1_to_mux_avl_st_rx_sop[1];		 
assign	eth_std_avl_st_rx_val[1] 		= ch1_to_mux_avl_st_rx_val[1];		   	 

////////////////////////////////////////////////////////////////////////////////////////
//jier added due to not using the qsys address decoder
////////////////////////////////////////////////////////////////////////////////////////

wire								sel_eth_1588_traffic_controller; 	
wire								sel_eth_traffic_controller_selector;	
wire	[NUM_CHANNELS-1:0] 	sel_eth_std_traffic_controller;	

assign  sel_eth_1588_traffic_controller 		= (avl_mm_baddress[13:12] == 2'd0);
assign  sel_eth_traffic_controller_selector	= (avl_mm_baddress[13:12] == 2'd1);
assign  sel_eth_std_traffic_controller[0] 	= (avl_mm_baddress[13:12] == 2'd2);	
assign  sel_eth_std_traffic_controller[1] 	= (avl_mm_baddress[13:12] == 2'd3);

always @*
	if (sel_eth_1588_traffic_controller)
		avl_mm_waitrequest = eth_1588_traffic_controller_avl_mm_waitrequest;
	else if (sel_eth_traffic_controller_selector)
		avl_mm_waitrequest = eth_traffic_selector_avl_mm_waitrequest;
	else if (sel_eth_std_traffic_controller[0])
		avl_mm_waitrequest = eth_std_traffic_controller_avl_mm_waitrequest[0];
	else if (sel_eth_std_traffic_controller[1])
		avl_mm_waitrequest = eth_std_traffic_controller_avl_mm_waitrequest[1];
	else
		avl_mm_waitrequest = 1'b0;
	
always @*
	if (sel_eth_1588_traffic_controller)
		avl_mm_readdata = eth_1588_traffic_controller_avl_mm_readdata;
	else if (sel_eth_traffic_controller_selector)
		avl_mm_readdata = eth_traffic_selector_avl_mm_readdata;
	else if (sel_eth_std_traffic_controller[0])
		avl_mm_readdata = eth_std_traffic_controller_avl_mm_readdata[0];
	else if (sel_eth_std_traffic_controller[1])
		avl_mm_readdata = eth_std_traffic_controller_avl_mm_readdata[1];
	else
		avl_mm_readdata = 32'd0;

assign	eth_std_traffic_controller_avl_mm_read[0] = avl_mm_read & sel_eth_std_traffic_controller[0];
assign	eth_std_traffic_controller_avl_mm_write[0] = avl_mm_write & sel_eth_std_traffic_controller[0];
assign	eth_std_traffic_controller_avl_mm_baddress[0] = avl_mm_baddress[11:0];
assign	eth_std_traffic_controller_avl_mm_writedata[0] = avl_mm_writedata;

assign	eth_std_traffic_controller_avl_mm_read[1] = avl_mm_read & sel_eth_std_traffic_controller[1];
assign	eth_std_traffic_controller_avl_mm_write[1] = avl_mm_write & sel_eth_std_traffic_controller[1];
assign	eth_std_traffic_controller_avl_mm_baddress[1] = avl_mm_baddress[11:0];
assign	eth_std_traffic_controller_avl_mm_writedata[1] = avl_mm_writedata;

assign	eth_1588_traffic_controller_avl_mm_read = avl_mm_read & sel_eth_1588_traffic_controller; 
assign	eth_1588_traffic_controller_avl_mm_write = avl_mm_write & sel_eth_1588_traffic_controller;
assign	eth_1588_traffic_controller_avl_mm_baddress = avl_mm_baddress[7:0];
assign	eth_1588_traffic_controller_avl_mm_writedata = avl_mm_writedata;

assign	eth_traffic_selector_avl_mm_read = avl_mm_read & sel_eth_traffic_controller_selector;
assign	eth_traffic_selector_avl_mm_write = avl_mm_write & sel_eth_traffic_controller_selector;
assign	eth_traffic_selector_avl_mm_baddress = avl_mm_baddress[0];
assign	eth_traffic_selector_avl_mm_writedata = avl_mm_writedata;
		
////////////////////////////////////////////////////////////////////////////////////////
		
//jier remove don;t know why it cause fatal error : Fatal: (vsim-3374)		
//traffic_controller_address_decoder traffic_controller_address_decoder_u0 (
//		.clk_clk																		(clk),                                                             
//		.reset_reset_n																	(reset_n),                                                       
//		.eth_traffic_controller_master_avalon_anti_master_0_address						(avl_mm_baddress),                         
//		.eth_traffic_controller_master_avalon_anti_master_0_waitrequest					(avl_mm_waitrequest),                     
//		.eth_traffic_controller_master_avalon_anti_master_0_read						(avl_mm_read),                            
//		.eth_traffic_controller_master_avalon_anti_master_0_readdata					(avl_mm_readdata),                        
//		.eth_traffic_controller_master_avalon_anti_master_0_write						(avl_mm_write),                           
//		.eth_traffic_controller_master_avalon_anti_master_0_writedata					(avl_mm_writedata),                       
//		.eth_std_traffic_controller_ch1_addr_avalon_anti_slave_0_address				(eth_std_traffic_controller_avl_mm_baddress[1]),                            
//		.eth_std_traffic_controller_ch1_addr_avalon_anti_slave_0_write					(eth_std_traffic_controller_avl_mm_write[1]),                                 
//		.eth_std_traffic_controller_ch1_addr_avalon_anti_slave_0_read					(eth_std_traffic_controller_avl_mm_read[1]),                                   
//		.eth_std_traffic_controller_ch1_addr_avalon_anti_slave_0_readdata				(eth_std_traffic_controller_avl_mm_readdata[1]),                           
//		.eth_std_traffic_controller_ch1_addr_avalon_anti_slave_0_writedata				(eth_std_traffic_controller_avl_mm_writedata[1]),                         
//		.eth_std_traffic_controller_ch1_addr_avalon_anti_slave_0_waitrequest			(eth_std_traffic_controller_avl_mm_waitrequest[1]),                     
//		.eth_traffic_selector_addr_avalon_anti_slave_0_address							(eth_traffic_selector_avl_mm_baddress),                 
//		.eth_traffic_selector_addr_avalon_anti_slave_0_write							(eth_traffic_selector_avl_mm_write),                   
//		.eth_traffic_selector_addr_avalon_anti_slave_0_read								(eth_traffic_selector_avl_mm_read),                    
//		.eth_traffic_selector_addr_avalon_anti_slave_0_readdata							(eth_traffic_selector_avl_mm_readdata),                
//		.eth_traffic_selector_addr_avalon_anti_slave_0_writedata						(eth_traffic_selector_avl_mm_writedata),               
//		.eth_traffic_selector_addr_avalon_anti_slave_0_waitrequest						(eth_traffic_selector_avl_mm_waitrequest),             
//		.eth_std_traffic_controller_ch0_addr_avalon_anti_slave_0_address				(eth_std_traffic_controller_avl_mm_baddress[0]),				     
//		.eth_std_traffic_controller_ch0_addr_avalon_anti_slave_0_write					(eth_std_traffic_controller_avl_mm_write[0]),       
//		.eth_std_traffic_controller_ch0_addr_avalon_anti_slave_0_read					(eth_std_traffic_controller_avl_mm_read[0]),        
//		.eth_std_traffic_controller_ch0_addr_avalon_anti_slave_0_readdata				(eth_std_traffic_controller_avl_mm_readdata[0]),    
//		.eth_std_traffic_controller_ch0_addr_avalon_anti_slave_0_writedata				(eth_std_traffic_controller_avl_mm_writedata[0]),   
//		.eth_std_traffic_controller_ch0_addr_avalon_anti_slave_0_waitrequest			(eth_std_traffic_controller_avl_mm_waitrequest[0]), 
//		.eth_1588_traffic_controller_addr_avalon_anti_slave_0_address					(eth_1588_traffic_controller_avl_mm_baddress),               
//		.eth_1588_traffic_controller_addr_avalon_anti_slave_0_write						(eth_1588_traffic_controller_avl_mm_write),                 
//		.eth_1588_traffic_controller_addr_avalon_anti_slave_0_read						(eth_1588_traffic_controller_avl_mm_read),                  
//		.eth_1588_traffic_controller_addr_avalon_anti_slave_0_readdata					(eth_1588_traffic_controller_avl_mm_readdata),              
//		.eth_1588_traffic_controller_addr_avalon_anti_slave_0_writedata					(eth_1588_traffic_controller_avl_mm_writedata),             
//		.eth_1588_traffic_controller_addr_avalon_anti_slave_0_waitrequest				(eth_1588_traffic_controller_avl_mm_waitrequest)            
//	);

genvar i;
generate
  
	for (i=0; i < NUM_CHANNELS; i = i+1)
	begin: ETH_STD_TRAFFIC_CONTROLLER
		//Ethernet Standard Traffic Controller
		eth_std_traffic_controller_top	eth_std_traffic_controller_u0 (
			.avl_mm_read      		(eth_std_traffic_controller_avl_mm_read[i]),
			.avl_mm_write     		(eth_std_traffic_controller_avl_mm_write[i]),
			.avl_mm_waitrequest		(eth_std_traffic_controller_avl_mm_waitrequest[i]),
			.avl_mm_baddress   		(eth_std_traffic_controller_avl_mm_baddress[i]),
			.avl_mm_readdata  		(eth_std_traffic_controller_avl_mm_readdata[i]),
			.avl_mm_writedata 		(eth_std_traffic_controller_avl_mm_writedata[i]),
		    
			.refclk_10g       (refclk_10g), 
			.clk					(clk),
			.reset_n				(reset_n),
			.fmc_in (fmc_in[16*i+15:16*i]), // first 16 go to generator 1 , next 16 go to generator 2
			.fmc_out (fmc_out[16*i+15:16*i]), // ""
			.fast1_clk (fast1_clk),
			.fast2_clk (fast2_clk),
		    
			.mac_rx_status_data	(avl_st_rx_status_data[i]),
			.mac_rx_status_valid	(avl_st_rx_status_valid[i]),
			.mac_rx_status_error	(avl_st_rx_status_error[i][0]),
			.stop_mon				(eth_std_stop_mon[i]),
			.mon_active				(eth_std_mon_active[i]),
			.mon_done				(eth_std_mon_done[i]),
			.mon_error				(eth_std_mon_error[i]),
		    
			.avl_st_tx_data		(eth_std_avl_st_tx_data[i]),
			.avl_st_tx_empty		(eth_std_avl_st_tx_empty[i]),
			.avl_st_tx_eop			(eth_std_avl_st_tx_eop[i]),
			.avl_st_tx_error		(eth_std_avl_st_tx_error[i]),
			.avl_st_tx_ready		(eth_std_avl_st_tx_ready[i]),
			.avl_st_tx_sop			(eth_std_avl_st_tx_sop[i]),
			.avl_st_tx_val			(eth_std_avl_st_tx_val[i]),             
		    
			.avl_st_rx_data		(eth_std_avl_st_rx_data[i]),
			.avl_st_rx_empty		(eth_std_avl_st_rx_empty[i]),
			.avl_st_rx_eop			(eth_std_avl_st_rx_eop[i]),
			.avl_st_rx_error		(eth_std_avl_st_rx_error[i]),
			.avl_st_rx_ready		(eth_std_avl_st_rx_ready[i]),
			.avl_st_rx_sop			(eth_std_avl_st_rx_sop[i]),
			.avl_st_rx_val       (eth_std_avl_st_rx_val[i]),
			
			.chip_id_out         (chip_id_out[i]),
	      .channel_out         (channel_out[i]),
	      .vol_out             (vol_out[i]),
	      .change_dac_out      (change_dac_out[i])
		);
	end        
endgenerate

//Ethernet 1588 Traffic Controller
eth_1588_traffic_controller #(4) eth_1588_traffic_controller_u0 (
	.clk													(clk),
	.reset_n												(1'b0), // this variant does not support 1588 in 17.1

	//Avalon MM
	.avl_mm_read											(eth_1588_traffic_controller_avl_mm_read),
	.avl_mm_write											(eth_1588_traffic_controller_avl_mm_write),
	.avl_mm_waitrequest									(eth_1588_traffic_controller_avl_mm_waitrequest),
	.avl_mm_baddress										(eth_1588_traffic_controller_avl_mm_baddress),
	.avl_mm_readdata										(eth_1588_traffic_controller_avl_mm_readdata),
	.avl_mm_writedata										(eth_1588_traffic_controller_avl_mm_writedata),
	            	
	//Master Avalon ST          	
	.master_avl_st_tx_data									(eth_1588_avl_st_tx_data[0]),
	.master_avl_st_tx_empty									(eth_1588_avl_st_tx_empty[0]),
	.master_avl_st_tx_eop									(eth_1588_avl_st_tx_eop[0]),
	.master_avl_st_tx_error									(eth_1588_avl_st_tx_error[0]),
	.master_avl_st_tx_ready									(eth_1588_avl_st_tx_ready[0]),
	.master_avl_st_tx_sop									(eth_1588_avl_st_tx_sop[0]),
	.master_avl_st_tx_val									(eth_1588_avl_st_tx_val[0]),    
	            	
	.master_avl_st_rx_data									(eth_1588_avl_st_rx_data[0]),
	.master_avl_st_rx_empty									(eth_1588_avl_st_rx_empty[0]),
	.master_avl_st_rx_eop									(eth_1588_avl_st_rx_eop[0]),
	.master_avl_st_rx_error									(eth_1588_avl_st_rx_error[0]),
	.master_avl_st_rx_ready									(eth_1588_avl_st_rx_ready[0]),
	.master_avl_st_rx_sop									(eth_1588_avl_st_rx_sop[0]),
	.master_avl_st_rx_val									(eth_1588_avl_st_rx_val[0]),
	
	
	.master_mac_tx_status_valid							(avl_st_tx_status_valid[0]),
	.master_mac_tx_status_data								(avl_st_tx_status_data[0]),
	.master_mac_tx_status_error							(avl_st_tx_status_error[0]),
	
	.master_mac_rx_status_valid							(avl_st_rx_status_valid[0]),
	.master_mac_rx_status_data								(avl_st_rx_status_data[0]),
	.master_mac_rx_status_error							(avl_st_rx_status_error[0]),
	
	
	//Slave Avalon ST  
	.slave_avl_st_tx_data									(eth_1588_avl_st_tx_data[1]), 
	.slave_avl_st_tx_empty									(eth_1588_avl_st_tx_empty[1]),
	.slave_avl_st_tx_eop										(eth_1588_avl_st_tx_eop[1]),  
	.slave_avl_st_tx_error									(eth_1588_avl_st_tx_error[1]),
	.slave_avl_st_tx_ready									(eth_1588_avl_st_tx_ready[1]),
	.slave_avl_st_tx_sop										(eth_1588_avl_st_tx_sop[1]),  
	.slave_avl_st_tx_val										(eth_1588_avl_st_tx_val[1]),     
	            	
	.slave_avl_st_rx_data									(eth_1588_avl_st_rx_data[1]), 
	.slave_avl_st_rx_empty									(eth_1588_avl_st_rx_empty[1]),
	.slave_avl_st_rx_eop										(eth_1588_avl_st_rx_eop[1]),  
	.slave_avl_st_rx_error									(eth_1588_avl_st_rx_error[1]),
	.slave_avl_st_rx_ready									(eth_1588_avl_st_rx_ready[1]),
	.slave_avl_st_rx_sop										(eth_1588_avl_st_rx_sop[1]),  
	.slave_avl_st_rx_val										(eth_1588_avl_st_rx_val[1]),  
	
	//Master 1588 Signals    
    .master_tx_egress_timestamp_96b_valid					(tx_egress_timestamp_96b_valid[0]), 
    .master_tx_egress_timestamp_96b_data					(tx_egress_timestamp_96b_data[0]), 
    .master_tx_egress_timestamp_96b_fingerprint			(tx_egress_timestamp_96b_fingerprint[0]), 

    .master_tx_egress_timestamp_request_fingerprint	(tx_egress_timestamp_request_fingerprint[0]), 
    .master_tx_egress_timestamp_request_valid			(tx_egress_timestamp_request_valid[0]),

    .master_rx_ingress_timestamp_96b_valid				(rx_ingress_timestamp_96b_valid[0]), 
    .master_rx_ingress_timestamp_96b_data					(rx_ingress_timestamp_96b_data[0]),
    
	//Slave 1588 Signals
	.slave_tx_egress_timestamp_request_valid				(tx_egress_timestamp_request_valid[1]), 
	.slave_tx_egress_timestamp_request_fingerprint		(tx_egress_timestamp_request_fingerprint[1]), 
	
	.slave_tx_egress_timestamp_96b_valid					(tx_egress_timestamp_96b_valid[1]),	 
	.slave_tx_egress_timestamp_96b_data						(tx_egress_timestamp_96b_data[1]), 
	.slave_tx_egress_timestamp_96b_fingerprint			(tx_egress_timestamp_96b_fingerprint[1]), 
	
	.slave_rx_ingress_timestamp_96b_valid					(rx_ingress_timestamp_96b_valid[1]), 
	.slave_rx_ingress_timestamp_96b_data					(rx_ingress_timestamp_96b_data[1]), 
	
	//Eth 1588 Traffic Controller Control	
	.wait_limit														(eth_1588_wait_limit),		
	.start_tod_sync												(eth_1588_start_tod_sync),
	.channel_ready													(eth_1588_channel_ready),
	.eth_1588_traffic_controller_error_n					(eth_1588_traffic_controller_error_n)
);	

avl_st_sel_csr	mux_sel_csr_u0 (
	.avl_mm_clk														(clk),
	.avl_mm_reset_n												(reset_n),
	
	.avl_mm_read											(eth_traffic_selector_avl_mm_read),
	.avl_mm_write											(eth_traffic_selector_avl_mm_write),
	.avl_mm_waitrequest									(eth_traffic_selector_avl_mm_waitrequest),
	.avl_mm_baddress										(eth_traffic_selector_avl_mm_baddress),
	.avl_mm_readdata										(eth_traffic_selector_avl_mm_readdata),
	.avl_mm_writedata										(eth_traffic_selector_avl_mm_writedata),
    
	.eth_traffic_ctrl_sel								(mux_sel)
);
	
avl_st_mux avl_st_mux_for_ch0_u0 (
	.avl_st_clk												(clk),
	.avl_st_reset_n										(reset_n),
	
	.mux_sel													(mux_sel),
	
	//Avalon ST From Traffic Controller
	.mux_in_avl_st_tx_data									(ch0_to_mux_avl_st_tx_data),
	.mux_in_avl_st_tx_empty									(ch0_to_mux_avl_st_tx_empty),
	.mux_in_avl_st_tx_eop									(ch0_to_mux_avl_st_tx_eop), 									
	.mux_in_avl_st_tx_error									(ch0_to_mux_avl_st_tx_error),
	.mux_in_avl_st_tx_ready									(ch0_to_mux_avl_st_tx_ready),
	.mux_in_avl_st_tx_sop									(ch0_to_mux_avl_st_tx_sop),
	.mux_in_avl_st_tx_val									(ch0_to_mux_avl_st_tx_val),
	
	.demux_out_avl_st_rx_data								(ch0_to_mux_avl_st_rx_data),
	.demux_out_avl_st_rx_empty								(ch0_to_mux_avl_st_rx_empty),
	.demux_out_avl_st_rx_eop								(ch0_to_mux_avl_st_rx_eop), 							
	.demux_out_avl_st_rx_error								(ch0_to_mux_avl_st_rx_error),
	.demux_out_avl_st_rx_ready								(ch0_to_mux_avl_st_rx_ready),
	.demux_out_avl_st_rx_sop								(ch0_to_mux_avl_st_rx_sop),
	.demux_out_avl_st_rx_val								(ch0_to_mux_avl_st_rx_val),
	
	//Avalon ST To MAC
	.mux_out_avl_st_tx_data									(avl_st_tx_data[0]),
	.mux_out_avl_st_tx_empty								(avl_st_tx_empty[0]),
	.mux_out_avl_st_tx_eop									(avl_st_tx_eop[0]), 								
	.mux_out_avl_st_tx_error								(avl_st_tx_error[0]),
	.mux_out_avl_st_tx_ready								(avl_st_tx_ready[0]),
	.mux_out_avl_st_tx_sop									(avl_st_tx_sop[0]),
	.mux_out_avl_st_tx_val									(avl_st_tx_val[0]),             
                	
	.demux_in_avl_st_rx_data								(avl_st_rx_data[0]),
	.demux_in_avl_st_rx_empty								(avl_st_rx_empty[0]),
	.demux_in_avl_st_rx_eop									(avl_st_rx_eop[0]), 								
	.demux_in_avl_st_rx_error								(avl_st_rx_error[0]),
	.demux_in_avl_st_rx_ready								(avl_st_rx_ready[0]),
	.demux_in_avl_st_rx_sop									(avl_st_rx_sop[0]),
	.demux_in_avl_st_rx_val									(avl_st_rx_val[0])	
);

avl_st_mux avl_st_mux_for_ch1_u1 (
	.avl_st_clk												(clk),
	.avl_st_reset_n										(reset_n),
	
	.mux_sel													(mux_sel),
	
	//Avalon ST From Traffic Controller
	.mux_in_avl_st_tx_data									(ch1_to_mux_avl_st_tx_data),
	.mux_in_avl_st_tx_empty									(ch1_to_mux_avl_st_tx_empty),
	.mux_in_avl_st_tx_eop									(ch1_to_mux_avl_st_tx_eop), 									
	.mux_in_avl_st_tx_error									(ch1_to_mux_avl_st_tx_error),
	.mux_in_avl_st_tx_ready									(ch1_to_mux_avl_st_tx_ready),
	.mux_in_avl_st_tx_sop									(ch1_to_mux_avl_st_tx_sop),
	.mux_in_avl_st_tx_val									(ch1_to_mux_avl_st_tx_val),
	
	.demux_out_avl_st_rx_data								(ch1_to_mux_avl_st_rx_data),
	.demux_out_avl_st_rx_empty								(ch1_to_mux_avl_st_rx_empty),
	.demux_out_avl_st_rx_eop								(ch1_to_mux_avl_st_rx_eop), 							
	.demux_out_avl_st_rx_error								(ch1_to_mux_avl_st_rx_error),
	.demux_out_avl_st_rx_ready								(ch1_to_mux_avl_st_rx_ready),
	.demux_out_avl_st_rx_sop								(ch1_to_mux_avl_st_rx_sop),
	.demux_out_avl_st_rx_val								(ch1_to_mux_avl_st_rx_val),
	
	//Avalon ST To MAC
	.mux_out_avl_st_tx_data									(avl_st_tx_data[1]),
	.mux_out_avl_st_tx_empty								(avl_st_tx_empty[1]),
	.mux_out_avl_st_tx_eop									(avl_st_tx_eop[1]), 								
	.mux_out_avl_st_tx_error								(avl_st_tx_error[1]),
	.mux_out_avl_st_tx_ready								(avl_st_tx_ready[1]),
	.mux_out_avl_st_tx_sop									(avl_st_tx_sop[1]),
	.mux_out_avl_st_tx_val									(avl_st_tx_val[1]),             
                	
	.demux_in_avl_st_rx_data								(avl_st_rx_data[1]),
	.demux_in_avl_st_rx_empty								(avl_st_rx_empty[1]),
	.demux_in_avl_st_rx_eop									(avl_st_rx_eop[1]), 								
	.demux_in_avl_st_rx_error								(avl_st_rx_error[1]),
	.demux_in_avl_st_rx_ready								(avl_st_rx_ready[1]),
	.demux_in_avl_st_rx_sop									(avl_st_rx_sop[1]),
	.demux_in_avl_st_rx_val									(avl_st_rx_val[1])	
);

endmodule
