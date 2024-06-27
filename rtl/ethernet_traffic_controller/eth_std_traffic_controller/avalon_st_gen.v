// (C) 2001-2018 Intel Corporation. All rights reserved.
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


// turn off bogus verilog processor warnings
// altera message_off 10034 10035 10036 10037 10230

module avalon_st_gen
(
 input wire 				refclk_10g     // Fastest clock
,input                 	clk            // TX FIFO Interface clock
,input                 	reset          // Reset signal

,input			 [15:0]  fmc_in         // Inputs from FMC (14-15 are from arduino)
													// fmc_in 0 is H10, 1 is H11
,output         [15:0]  fmc_out			// Outputs to FMC (8-15 are for pulses)
,output						trigger
,output			 			verify_trigger

,input fast1_clk // 
,input fast2_clk // 

,input          [7:0]  address         // Register Address
,input                 write           // Register Write Strobe
,input                 read            // Register Read Strobe
,output wire           waitrequest  
,input          [31:0] writedata       // Register Write Data
,output reg     [31:0] readdata        // Register Read Data

,input                 tx_ready        // Avalon-ST Ready Input
,output reg     [63:0] tx_data         // Avalon-ST TX Data
,output reg            tx_valid        // Avalon-ST TX Valid
,output reg            tx_sop          // Avalon-ST TX StartOfPacket
,output reg            tx_eop          // Avalon-ST TX EndOfPacket
,output reg     [2:0]  tx_empty        // Avalon-ST TX Empty
,output wire           tx_error        // Avalon-ST TX Error

,output wire 	 		  chip_id_out
,output wire 	 [3:0]  channel_out
,output wire    [11:0] vol_out
,output wire           change_dac_out
);


 // ___________________________________________________________
 //	    address parameters
 // ___________________________________________________________
 parameter ADDR_NUMPKTS 	= 8'h0;
 parameter ADDR_RANDOMLENGTH 	= 8'h1;
 parameter ADDR_RANDOMPAYLOAD 	= 8'h2;
 parameter ADDR_START 		= 8'h3;
 parameter ADDR_STOP 		= 8'h4;
 parameter ADDR_MACSA0 		= 8'h5;
 parameter ADDR_MACSA1 		= 8'h6;
 parameter ADDR_MACDA0 		= 8'h7;
 parameter ADDR_MACDA1 		= 8'h8;
 parameter ADDR_TXPKTCNT 	= 8'h9;
 parameter ADDR_RNDSEED0 	= 8'ha;
 parameter ADDR_RNDSEED1 	= 8'hb;
 parameter ADDR_RNDSEED2 	= 8'hc;
 parameter ADDR_PKTLENGTH 	= 8'hd;
 
 //Andre/Andy variables
 parameter ADDR_do_test_counter_data = 8'h10;
 parameter ADDR_fifo_clk_prescale = 8'h11;
 parameter ADDR_destip = 8'h12;

 parameter ADDR_pos1dur = 8'h13;
 parameter ADDR_pos1pausedur = 8'h14;
 parameter ADDR_pos2dur = 8'h15;
 parameter ADDR_pos2pausedur = 8'h16;
 parameter ADDR_pos3dur = 8'h17;
 parameter ADDR_pos3pausedur = 8'h18;
 parameter ADDR_pos4dur = 8'h19;
 parameter ADDR_pos4pausedur = 8'h1A;
 parameter ADDR_neg1dur = 8'h1B;
 parameter ADDR_neg1pausedur = 8'h1C;
 parameter ADDR_neg2dur = 8'h1D;
 parameter ADDR_neg2pausedur = 8'h1E;
 parameter ADDR_neg3dur = 8'h1F;
 parameter ADDR_neg3pausedur = 8'h20;
 parameter ADDR_neg4dur = 8'h21;
 parameter ADDR_neg4pausedur = 8'h22;
 
 parameter ADDR_offset = 8'h23;
 
 parameter ADDR_mode = 8'h24;
 
 parameter ADDR_chip_id = 8'h25;
 parameter ADDR_channel = 8'h26;
 parameter ADDR_vol = 8'h27;
 parameter ADDR_button = 8'h28;
 
 parameter ADDR_CNTDASA		= 8'hf0;
 parameter ADDR_CNTSATLEN	= 8'hf1;
 parameter ADDR_CNTDATA		= 8'hf2;
 parameter ADDR_CNTTRNSTN	= 8'hf3;

// 10G Ethernet Control Registers
reg	start_reg;
wire    start;                                  // Start operation of packet generator
reg     stop;                                   // Stop operation of packet generator
reg     [31:0] number_packet;                   // Register to store number of packets to be transmitted
reg     [31:0] config_setting;                  // Register to configure settings: data pattern type, length
reg     [31:0] source_addr0;                    // Register to program the MAC source address [31:0]
reg     [31:0] source_addr1;                    // Register to program the MAC source address [47:32]
reg     [31:0] destination_addr0;               // Register to program the MAC destination address [31:0]
reg     [31:0] destination_addr1;               // Register to program the MAC destination address [47:32]
reg     [31:0] packet_tx_count;                 // Register to count the number of succesfully transmitted packets
reg     [31:0] rand_seed0;                      // Register to program seed number for prbs generator [31:0]
reg     [31:0] rand_seed1;                      // Register to program seed number for prbs generator [63:32]
reg     [31:0] rand_seed2;                      // Register to program seed number for prbs generator [91:64]


//dacwrite command registers
reg chip_id;
reg [3:0] channel;
reg [11:0] vol;
reg change_dac=1'b1; //start flag
assign chip_id_out = chip_id;
assign channel_out = channel;
assign vol_out = vol;
assign change_dac_out = change_dac;


reg    random_payload;                            // Select what type of data pattern:0=incremental, 1=random
reg    random_length;                             // Select what type of packet length:0=fixed, 1=random
reg    [13:0] pkt_length;                      // Fixed payload length for every packet
wire    [7:0] DA5,DA4,DA3,DA2,DA1,DA0; 
wire    [7:0] SA5,SA4,SA3,SA2,SA1,SA0;  
wire    [91:0] random_seed;                     // Random seed number for PRBS generator

wire    S_IDLE;
wire 	  S_FIFO_WAIT;
wire    S_DEST_SRC;
wire    S_SRC_LEN_SEQ;
wire    S_SRC_LEN_IP1;
wire    S_SRC_LEN_IP2;
wire    S_SRC_LEN_IP3;
wire    S_SRC_LEN_IP4;
wire    S_DATA;
wire    S_TRANSITION;

reg[31:0] cnt_dasa, cnt_satlen, cnt_data, cnt_trnstn;

reg     [3:0] ns;
reg     [3:0] ps;

reg do_IP = 1'b1; // whether to add IP header

// State machine parameters
// --------------------------
localparam state_idle         = 4'h0;         // Idle State
localparam state_dest_src     = 4'h1;         // Dest(47:0) & Src(47:32) State
localparam state_src_len_seq  = 4'h2;         // Src(31:0) & Length(15:0) & SeqNr(15:0) State
localparam state_src_len_ip1  = 4'h3;
localparam state_src_len_ip2  = 4'h4;
localparam state_src_len_ip3  = 4'h5;
localparam state_data         = 4'h6;         // Data Pattern State
localparam state_transition   = 4'h7;         // Transition State
localparam state_fifo_wait    = 4'h8;         // Waiting for data to be in the fifo
localparam state_src_len_ip4  = 4'h9;
localparam state_fifo_start   = 4'ha;

wire    [91:0] tx_prbs;
reg     [15:0] byte_count;
reg     [63:0] data_pattern;
reg     [15:0] length;
reg     [15:0] seq_num;

// Avalon-ST signals to CRC generator
// -----------------------------------

wire    [3:0] empty;
reg     [63:0] tx_data_reg;
reg     tx_valid_reg;
reg     tx_sop_reg;
reg     tx_eop_reg;
reg     [2:0] tx_empty_reg;

wire    crc_valid;
wire    [31:0] crc;
reg     [31:0] crc_l1;
reg     [31:0] crc_l2;
reg     [31:0] crc_l3;
reg     [31:0] crc_l4;
reg     [2:0] crc_valid_count;
wire    [31:0] checksum;

wire    [63:0] tx_data_out;
wire    [5:0] tx_ctrl_out;

reg     add_extra_qword;
reg     valid_extended;
reg     eop_extended;
reg     [2:0] empty_extended;
reg 	  [31:0] destip=32'hC0A80A0b;

//FIFO for reading in input data
reg [63:0] fifo_datain;
reg fifo_wrreq=1'b0;
reg fifo_rdreq=1'b0;
reg fifo_aclr=1'b0;
wire [63:0] fifo_dataout;
wire [9:0] fifo_rdusedw;//number of entries (out of 1024)
wire fifo_rdfull; //full synced to read clk
wire fifo_rdempty; //empty synced to read clk
wire fifo_wrfull; //full synced to write clk
wire fifo_clk;//fifo_clk is what is used for writing


//trigger for fifo
//reg trigger = 1'b0;

	myfifo fifo1 (
		.data    (fifo_datain),    //   input,  width = 64,  fifo_input.datain
		.wrreq   (fifo_wrreq),   //   input,   width = 1,            .wrreq
		.rdreq   (fifo_rdreq),   //   input,   width = 1,            .rdreq
		.wrclk   (fifo_clk),   //   input,   width = 1,            .wrclk
		.rdclk   (clk),   //   input,   width = 1,            .rdclk
		.aclr    (fifo_aclr),    //   input,   width = 1,            .aclr
		.q       (fifo_dataout),       //  output,  width = 64, fifo_output.dataout
		.rdusedw (fifo_rdusedw), //  output,   width = 10,            .rdusedw
		.rdfull  (fifo_rdfull),  //  output,   width = 1,            .rdfull
		.rdempty (fifo_rdempty), //  output,   width = 1,            .rdempty
		.wrfull  (fifo_wrfull)   //  output,   width = 1,            .wrfull
	);
	
	reg fifo_p_clk;
	reg [31:0] fifo_clk_counter=0;
	reg [31:0] fifo_clk_prescale=0;
	wire fifo_base_clk;
	always @ (posedge fifo_base_clk)
   begin
		if (fifo_clk_counter>=fifo_clk_prescale) begin
			fifo_p_clk<= ~fifo_p_clk;
			fifo_clk_counter<=0;
		end
		else fifo_clk_counter<=fifo_clk_counter+1;
	end
	
	assign fifo_clk=fifo_base_clk;
	//assign fifo_clk=fifo_p_clk; // to use prescale logic
	
	//assign fifo_base_clk=clk;//156.25
	//assign fifo_base_clk=fast1_clk;//out2 from pll
	assign fifo_base_clk=fast2_clk;//out3 from pll
	
	reg do_test_counter_data=1'b0;
	reg do_selected_data_bit = 1'b1;
	reg do_selected_verify_bit = 1'b1;
	reg do_full_data=1'b0;

	reg [7:0] do_xor = 8'h01;
	reg [63:0] datain_memory; // memory to xor
	reg [1:0] xor_state; // state variable for xoring
	reg [7:0] xor_counter; // keep track of bit to xor
	reg verified = 1'b0;
  reg [15:0] zeros_count = 16'h0000;
  reg [15:0] all_count = 16'h0000;
  reg [15:0] zeros_in_216 = 16'h0000;
  parameter [15:0] INT_216 = 16'hFFFF;
	reg [7:0] test_counter_data=8'h00;
	reg [7:0] counter_datain=8'h00;
	reg [7:0] counter_datain_max=8'h40;
	parameter nbitstosample=6'd1; // should be a power of 2, to fit into 64 bit word!
	always @ (posedge reset or posedge fifo_clk)
   begin
      if (reset) begin
			  fifo_datain <= 64'h0;
			  counter_datain <= 8'h00;
			  xor_state <= 2'b00;
			  xor_counter <= 8'h00;
		  end
      else if ((do_full_data || do_test_counter_data || (do_selected_data_bit && verified)) && do_xor[0]) begin
			if (do_test_counter_data) begin
				counter_datain_max <= 8'h40-8'h08;
				test_counter_data<=test_counter_data+8'h01;
				fifo_datain <= {fifo_datain[55:0],test_counter_data};
			end
			else if (do_full_data) begin
				fifo_datain <= {fifo_datain[63-nbitstosample:0],fmc_in[nbitstosample-1:1],trigger}; // take nbitstosample more bits of input and shift into fifo_datain
				counter_datain_max <= 8'h40-nbitstosample;
			end
			else begin //assuming nbitstosample is 1 when do_full_data is set to false
			    if (xor_state == 2'b00) begin
    				fifo_datain <= {fifo_datain[63-nbitstosample:0],fmc_in[nbitstosample:1]}; // take nbitstosample more bits of input and shift into fifo_datain
	    			counter_datain_max <= 8'h40-nbitstosample;
	    		end
	    		else if (xor_state == 2'b01) begin
				    fifo_datain <= {fifo_datain[63-nbitstosample:0],fmc_in[nbitstosample:1] ^ datain_memory[63-xor_counter]};	// xor with previous 64 bits
				    counter_datain_max <= 8'h40-nbitstosample;
				    xor_counter <= xor_counter + 8'h01;
		      end
          if (~fmc_in[nbitstosample:1])begin
                    zeros_count <= zeros_count + 16'h0001;
             end
             all_count <= all_count + 16'h0001;
          if (all_count == INT_216)begin
					   zeros_in_216 <= zeros_count;
             all_count <= 16'h0000;
             zeros_count <= 16'h0000;
          end
			end
			if (counter_datain >= counter_datain_max) begin // ready to write it to the fifo
				counter_datain <= 8'h00;
				xor_counter <= 8'h00;
				if (xor_state == 2'b00) begin // was taking data into fifo_datain, but not actually storing it
             fifo_wrreq<=1'b0;
             datain_memory <= fifo_datain;
             xor_state <= 2'b01;
        end
        else if (xor_state == 2'b01) begin // was taking XORed data into fifo_datain, and storing it
             fifo_wrreq<=1'b1;
             xor_state <= 2'b00;
        end
			end
			else begin
				if (do_test_counter_data) counter_datain <= counter_datain+8'h08; // remember we stored 8 more bits
				else counter_datain <= counter_datain+nbitstosample; // remember we stored nbitstosample more bits
				fifo_wrreq<=1'b0;
			end
		end else
		//if not doing xor
		if(~do_xor[0] && ((do_full_data || do_test_counter_data || (do_selected_data_bit && verified)))) begin
			if (do_test_counter_data) begin
				counter_datain_max <= 8'h40-8'h08;
				test_counter_data<=test_counter_data+8'h01;
				fifo_datain <= {fifo_datain[55:0],test_counter_data};
			end
			else if (do_full_data) begin
				fifo_datain <= {fifo_datain[63-nbitstosample:0],fmc_in[nbitstosample-1:1],trigger}; // take nbitstosample more bits of input and shift into fifo_datain
				counter_datain_max <= 8'h40-nbitstosample;
			end
			else begin //assuming nbitstosample is 1 when do_full_data is set to false
				fifo_datain <= {fifo_datain[63-nbitstosample:0],fmc_in[nbitstosample:1]}; // take nbitstosample more bits of input and shift into fifo_datain
				counter_datain_max <= 8'h40-nbitstosample;
            if (~fmc_in[nbitstosample:1])begin
					     zeros_count <= zeros_count + 16'h0001;
            end
            all_count <= all_count + 16'h0001;
            if (all_count == INT_216)begin
					     zeros_in_216 <= zeros_count;
               all_count <= 16'h0000;
               zeros_count <= 16'h0000;
            end
			end
			
			if (counter_datain >= counter_datain_max) begin // ready to write it to the fifo
				counter_datain <= 8'h00;
				fifo_wrreq<=1'b1;
			end
			else begin
				if (do_test_counter_data) counter_datain <= counter_datain+8'h08; // remember we stored 8 more bits
				else counter_datain <= counter_datain+nbitstosample; // remember we stored nbitstosample more bits
				fifo_wrreq<=1'b0;
			end
		end else begin
			fifo_wrreq<=1'b0;
		end
   end
	
	reg [7:0] trigger_offset = 8'd100;
	reg [7:0] random_bit_timer = 8'b0;
	always @ (posedge fifo_clk)
	begin
		if(trigger_offset == random_bit_timer) do_selected_data_bit <= 1'b1;
		else do_selected_data_bit <= 1'b0;
		if(trigger) random_bit_timer <= 8'd0;
		else random_bit_timer <= random_bit_timer + 1'b1;
	end
	
	reg [7:0] verify_bit_timer = 8'b0;
	reg [15:0] verify_error_count = 16'd0;
	
	always @ (posedge fifo_clk)
	begin
		if(trigger_offset == verify_bit_timer) begin //same trigger_offset variable as for random trigger
			if(fmc_in[1] == 1'h1) begin
				do_selected_verify_bit <= 1'b1;
				verified <= 1'b1;
			end else begin
				if (verify_error_count!=16'hffff) verify_error_count <= verify_error_count + 1'b1;
				do_selected_verify_bit <= 1'b0;
				verified <= 1'b0;
			end
		end
		else do_selected_verify_bit <= 1'b0;
		
		if(verify_trigger) verify_bit_timer <= 0;
		else verify_bit_timer <= verify_bit_timer + 1'b1;
		
		if(S_TRANSITION) verify_error_count <= 16'b0;
	end
	
	//debugging outputs
	assign fmc_out[7:4] = {trigger, verify_trigger, do_selected_data_bit, do_selected_verify_bit};
	assign fmc_out[3:0] = fmc_in[3:0];
	
	//pulse outputs and pauses
	reg [31:0] pos1dur = 10;
	reg [31:0] pos1pausedur = 10;
	
	reg [31:0] pos2dur = 10;
	reg [31:0] pos2pausedur = 10;
	
	reg [31:0] pos3dur = 10;
	reg [31:0] pos3pausedur = 10;
	
	reg [31:0] pos4dur = 10;
	reg [31:0] pos4pausedur = 10;
	
	reg [31:0] neg1dur = 10;
	reg [31:0] neg1pausedur = 10;
	
	reg [31:0] neg2dur = 10;
	reg [31:0] neg2pausedur = 10;
	
	reg [31:0] neg3dur = 10;
	reg [31:0] neg3pausedur = 10;
	
	reg [31:0] neg4dur = 10;
	reg [31:0] neg4pausedur = 10;
	
	
	PulseController pulser (
		.clk_in(fast2_clk),
		
		.pos1dur(pos1dur),
		.pos1pausedur(pos1pausedur),
		.pos2dur(pos2dur),
		.pos2pausedur(pos2pausedur),
		.pos3dur(pos3dur),
		.pos3pausedur(pos3pausedur),
		.pos4dur(pos4dur),
		.pos4pausedur(pos4pausedur),
		
		.neg1dur(neg1dur),
		.neg1pausedur(neg1pausedur),
		.neg2dur(neg2dur),
		.neg2pausedur(neg2pausedur),
		.neg3dur(neg3dur),
		.neg3pausedur(neg3pausedur),
		.neg4dur(neg4dur),
		.neg4pausedur(neg4pausedur),
		
		.signal_out(fmc_out[15:8]),
		.trigger(trigger),
		.verify_trigger(verify_trigger)
	);

	//Read registers
	reg [12:0] change_dac_counter = 0;
	parameter DAC_CHANGE_DELAY = 5000;
	always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
			do_test_counter_data <= 1'b0;
			fifo_clk_prescale <= 32'h0;
			destip <= 32'hC0A80A0b;
			
			pos1dur <= 0;
			pos1pausedur <= 0;
			pos2dur <= 0;
			pos2pausedur <= 0;
			pos3dur <= 0;
			pos3pausedur <= 0;
			pos4dur <= 0;
			pos4pausedur <= 0;
			
			neg1dur <= 0;
			neg1pausedur <= 0;
			neg2dur <= 0;
			neg2pausedur <= 0;
			neg3dur <= 0;
			neg3pausedur <= 0;
			neg4dur <= 0;
			neg4pausedur <= 0;
		end
		
		else if (write & address == ADDR_do_test_counter_data) do_test_counter_data <= writedata[0];
		else if (write & address == ADDR_fifo_clk_prescale) fifo_clk_prescale <= writedata;
		else if (write & address == ADDR_destip) destip <= writedata;
		
		else if (write & address == ADDR_pos1dur) pos1dur<= writedata;
		else if (write & address == ADDR_pos1pausedur) pos1pausedur<= writedata;
		else if (write & address == ADDR_pos2dur) pos2dur<= writedata;
		else if (write & address == ADDR_pos2pausedur) pos2pausedur<= writedata;
		else if (write & address == ADDR_pos3dur) pos3dur<= writedata;
		else if (write & address == ADDR_pos3pausedur) pos3pausedur<= writedata;
		else if (write & address == ADDR_pos4dur) pos4dur<= writedata;
		else if (write & address == ADDR_pos4pausedur) pos4pausedur<= writedata;
		
		else if (write & address == ADDR_neg1dur) neg1dur<= writedata;
		else if (write & address == ADDR_neg1pausedur) neg1pausedur<= writedata;
		else if (write & address == ADDR_neg2dur) neg2dur<= writedata;
		else if (write & address == ADDR_neg2pausedur) neg2pausedur<= writedata;
		else if (write & address == ADDR_neg3dur) neg3dur<= writedata;
		else if (write & address == ADDR_neg3pausedur) neg3pausedur<= writedata;
		else if (write & address == ADDR_neg4dur) neg4dur<= writedata;
		else if (write & address == ADDR_neg4pausedur) neg4pausedur<= writedata;
		
		else if (write & address == ADDR_offset) trigger_offset<= writedata[7:0];
		else if (write & address == ADDR_mode) do_xor<= writedata[7:0];
		else if (write & address == ADDR_chip_id) chip_id <= writedata[0];
		else if (write & address == ADDR_channel) channel <= writedata[3:0];
		else if (write & address == ADDR_vol) begin
			vol <= writedata[11:0];
			change_dac <= 1'b0;
		//else if (write & address == ADDR_button) change_dac <= writedata[0];
		end
		
		else if (~change_dac && (change_dac_counter < DAC_CHANGE_DELAY)) begin
				change_dac_counter <= change_dac_counter +1;
		end else if (~change_dac && (change_dac_counter >= DAC_CHANGE_DELAY)) begin
				change_dac <= 1'b1;
				change_dac_counter <= 0;
		end
   end
	
// ____________________________________________________________________________
// number packet register
// ____________________________________________________________________________
always @ (posedge reset or posedge clk)
   begin
      if (reset) number_packet <= 32'h0;
      else if (write & address == ADDR_NUMPKTS) number_packet <= writedata;
   end

// ____________________________________________________________________________
// packet length setting register
// ____________________________________________________________________________
always @ (posedge reset or posedge clk)
   begin
      if (reset) pkt_length <= 14'd0;
      else if (write & address == ADDR_PKTLENGTH) pkt_length[13:0] <= writedata[13:0];
   end

// ____________________________________________________________________________
// payload pattern setting register
// ____________________________________________________________________________
always @ (posedge reset or posedge clk)
   begin
      if (reset) random_payload <= 1'h0;
      else if (write & address == ADDR_RANDOMPAYLOAD) random_payload <= writedata[0];
   end

// ____________________________________________________________________________
// packet length type (fixed or random) setting register
// ____________________________________________________________________________
always @ (posedge reset or posedge clk)
   begin
      if (reset) random_length <= 1'h0;
      else if (write & address == ADDR_RANDOMLENGTH) random_length <= writedata[0];
   end

// ____________________________________________________________________________
// start register
// ____________________________________________________________________________
always @ (posedge reset or posedge clk)
   begin
      if (reset) start_reg <= 1'h0;
      else if (write & address == ADDR_START) start_reg <= writedata[0];
      else if (start_reg) start_reg <= 1'b0; // clear itself
   end

// used for edge detection because start_reg[0] assertion maybe > 1 clk long 
reg start_d;

always @ (posedge reset or posedge clk)
   begin
      if (reset) start_d<= 1'd0;
      else start_d<= start_reg; 
   end

assign start = start_reg & ~start_d; 

// ____________________________________________________________________________
// stop register
// ____________________________________________________________________________
always @ (posedge reset or posedge clk)
   begin
      if (reset) stop <= 1'h0;
      else if (write & address == ADDR_STOP) stop <= writedata[0];
   end

// ____________________________________________________________________________
// MAC source_addr0 register
// ____________________________________________________________________________
always @ (posedge reset or posedge clk)
   begin
      if (reset) source_addr0 <= 32'h0;
      else if (write & address == ADDR_MACSA0) source_addr0 <= writedata;
   end

// ____________________________________________________________________________
// MAC dest_addr1 register
// ____________________________________________________________________________
always @ (posedge reset or posedge clk)
   begin
      if (reset) source_addr1 <= 32'h0;
      else if (write & address == ADDR_MACSA1) source_addr1 <= {16'h0, writedata[15:0]};
   end

// ____________________________________________________________________________
// MAC dest_addr0 register
// ____________________________________________________________________________
always @ (posedge reset or posedge clk)
   begin
      if (reset) destination_addr0 <= 32'h0;
      else if (write & address == ADDR_MACDA0) destination_addr0 <= writedata;
   end

// ____________________________________________________________________________
// MAC dest_addr1 register
// ____________________________________________________________________________
always @ (posedge reset or posedge clk)
   begin
      if (reset) destination_addr1 <= 32'h0;
      else if (write & address == ADDR_MACDA1) destination_addr1 <= {16'h0, writedata[15:0]};
   end

assign {DA5,DA4,DA3,DA2,DA1,DA0} = {destination_addr1[15:0], destination_addr0[31:0]};
assign {SA5,SA4,SA3,SA2,SA1,SA0} = {source_addr1[15:0], source_addr0[31:0]};

// ____________________________________________________________________________
// packet_tx_count register
// ____________________________________________________________________________
always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         packet_tx_count <= 32'h0;
      end else begin
         if (start) begin
            packet_tx_count <= 32'h0;
         end else if (tx_ready & S_SRC_LEN_SEQ) begin
            packet_tx_count <= packet_tx_count + 32'h1;
         end
      end
   end

// ____________________________________________________________________________
// rand_seed0 register
// ____________________________________________________________________________
always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         // rand_seed0 <= 32'h0;
	 // initialize with non zero seed so that 
	 // prbs works even when no random seed is 
	 // provided by the user - ajay dubey
         rand_seed0 <= 32'h5EED_0000; 
      end else begin
         if (write & address == ADDR_RNDSEED0) begin
            rand_seed0 <= writedata;
         end
      end
   end

// ____________________________________________________________________________
// rand_seed1 register
// ____________________________________________________________________________
always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         // rand_seed1 <= 32'h0;
	 // initialize with non zero seed so that 
	 // prbs works even when no random seed is 
	 // provided by the user - ajay dubey
         rand_seed1 <= 32'h5EED_0001; 
      end else begin
         if (write & address == ADDR_RNDSEED1) begin
            rand_seed1 <= writedata;
         end
      end
   end

// ____________________________________________________________________________
// rand_seed2 register
// ____________________________________________________________________________
always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         //rand_seed2 <= 32'h0;
	 // initialize with non zero seed so that 
	 // prbs works even when no random seed is 
	 // provided by the user - ajay dubey
         rand_seed2 <= 32'h0002_5EED; 
      end else begin
         if (write & address == ADDR_RNDSEED2) begin
            rand_seed2 <= {4'd0,writedata[27:0]};
         end
      end
   end

assign random_seed = {rand_seed2[27:0], rand_seed1[31:0], rand_seed0[31:0]};
// Output MUX of registers into readdata bus
   always@(posedge clk or posedge reset)
   begin
      if(reset) readdata <= 32'h0;
      else if (read) begin
         case (address)
            ADDR_NUMPKTS: readdata <= number_packet;
            ADDR_RANDOMLENGTH: readdata <= random_length;
            ADDR_RANDOMPAYLOAD: readdata <= random_payload;
            ADDR_START: readdata <= start;
            ADDR_STOP: readdata <= stop;
            ADDR_MACSA0: readdata <= source_addr0;
            ADDR_MACSA1: readdata <= source_addr1;
            ADDR_MACDA0: readdata <= destination_addr0;
            ADDR_MACDA1: readdata <= destination_addr1;
            ADDR_TXPKTCNT: readdata <= packet_tx_count;
            ADDR_RNDSEED0: readdata <= rand_seed0;
            ADDR_RNDSEED1: readdata <= rand_seed1;
            ADDR_RNDSEED2: readdata <= rand_seed2;

            ADDR_CNTDASA: readdata <= cnt_dasa;
            ADDR_CNTSATLEN: readdata <= cnt_satlen;
            ADDR_CNTDATA: readdata <= cnt_data;
            ADDR_CNTTRNSTN: readdata <= cnt_trnstn;
            default: readdata <=32'h0;
         endcase
      end
   end

 // ____________________________________________________________
 //
   reg rddly, wrdly;
   always@(posedge clk or posedge reset)
   begin
      if(reset) 
	 begin 
	      wrdly <= 1'b0; 
	      rddly <= 1'b0; 
	 end 
      else 
	 begin 
	      wrdly <= write; 
	      rddly <= read; 
	 end 
   end
  
   wire wredge = write& ~wrdly;
   wire rdedge = read & ~rddly;

   assign waitrequest = (wredge|rdedge); // your design is done with transaction when this goes down
// __________________________________________________________________________________



// PRBS Pattern Generator
// --------------------------------
prbs23 prbs_tx0
(
   .clk        (clk),
   .rst_n      (~reset),
   .load       (S_IDLE),
   .enable     (tx_ready & ( S_SRC_LEN_SEQ|S_SRC_LEN_IP1|S_SRC_LEN_IP2|S_SRC_LEN_IP3|S_SRC_LEN_IP4| S_DATA)),
   .seed       (random_seed[22:0]),
   .d          (tx_prbs[22:0]),
   .m          (tx_prbs[22:0])
);

prbs23 prbs_tx1
(
   .clk        (clk),
   .rst_n      (~reset),
   .load       (S_IDLE),
   .enable     (tx_ready & ( S_SRC_LEN_SEQ|S_SRC_LEN_IP1|S_SRC_LEN_IP2|S_SRC_LEN_IP3|S_SRC_LEN_IP4| S_DATA)),
   .seed       (random_seed[45:23]),
   .d          (tx_prbs[45:23]),
   .m          (tx_prbs[45:23])
);

prbs23 prbs_tx2
(
   .clk        (clk),
   .rst_n      (~reset),
   .load       (S_IDLE),
   .enable     (tx_ready & ( S_SRC_LEN_SEQ|S_SRC_LEN_IP1|S_SRC_LEN_IP2|S_SRC_LEN_IP3|S_SRC_LEN_IP4| S_DATA)),
   .seed       (random_seed[68:46]),
   .d          (tx_prbs[68:46]),
   .m          (tx_prbs[68:46])
);

prbs23 prbs_tx3
(
   .clk        (clk),
   .rst_n      (~reset),
   .load       (S_IDLE),
   .enable     (tx_ready & ( S_SRC_LEN_SEQ|S_SRC_LEN_IP1|S_SRC_LEN_IP2|S_SRC_LEN_IP3|S_SRC_LEN_IP4| S_DATA)),
   .seed       (random_seed[91:69]),
   .d          (tx_prbs[91:69]),
   .m          (tx_prbs[91:69])
);

// FSM State Machine for Generator
// --------------------------------
always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         ps <= state_idle;
      end else begin
         if (start) begin
            ps <= state_fifo_start;
         end else begin
            ps <= ns;
         end
      end
   end

always @ (*)
   begin
      ns = ps;
		fifo_rdreq=1'b0;//not reading from fifo by default
		fifo_aclr=1'b0;//not clearing fifo
      case (ps)
         state_idle:begin
            if (start) begin					
               ns = state_fifo_start;
            end
         end
			state_fifo_start:begin
            if (tx_ready) begin
					fifo_aclr=1'b1;//clear fifo
               ns = state_fifo_wait;
            end
         end
			state_fifo_wait:begin
            if ( (fifo_rdusedw > 10'h00C8) || fifo_rdfull) begin // wait until fifo has enough in it to make a packet (200)
               ns = state_dest_src;
            end
         end
         state_dest_src:begin
            if (tx_ready) begin
               ns = state_src_len_seq;
					if (~do_IP) fifo_rdreq=1'b1;//read from fifo
            end
         end
         state_src_len_seq:begin
            if (tx_ready & (length == 16'h0)) begin
               ns = state_transition;
            end else if (tx_ready) begin
               if (do_IP) ns = state_src_len_ip1;
					else begin
						fifo_rdreq=1'b1;//read from fifo (starting in the next clk tick)
						ns = state_data;
					end
            end
         end
			state_src_len_ip1:begin
            if (tx_ready & (length == 16'h0)) begin
               ns = state_transition;
            end else if (tx_ready) begin
               ns = state_src_len_ip2;
            end
         end
			state_src_len_ip2:begin
            if (tx_ready & (length == 16'h0)) begin
               ns = state_transition;
            end else if (tx_ready) begin
					if (seq_num==16'h0) fifo_rdreq=1'b1; // read one extra early?
               ns = state_src_len_ip3;
            end
         end
			state_src_len_ip3:begin
            if (tx_ready & (length == 16'h0)) begin
               ns = state_transition;
            end else if (tx_ready) begin
					fifo_rdreq=1'b1;//read from fifo (starting in the next clk tick)
               ns = state_src_len_ip4;
            end
         end
			state_src_len_ip4:begin
            if (tx_ready & (length == 16'h0)) begin
               ns = state_transition;
            end else if (tx_ready) begin
					fifo_rdreq=1'b1;//read from fifo
               ns = state_data;
            end
         end
         state_data:begin
            if (tx_ready & (byte_count[15] | byte_count == 16'h0)) begin
               ns = state_transition;
            end
				else if (tx_ready & (byte_count == 16'h10)) begin
               fifo_rdreq=1'b0;//stop reading from fifo
            end
				else fifo_rdreq=1'b1;//read from fifo
         end
         state_transition:begin
            if (stop | packet_tx_count == number_packet) begin
               ns = state_idle;
            end else if (tx_ready) begin
               ns = state_fifo_wait;
            end      
         end
         default: begin
				ns = state_idle;
				fifo_rdreq=1'b0;
			end
      endcase
   end

 assign S_IDLE        = (ns == state_idle)        ? 1'b1 : 1'b0;
 assign S_FIFO_START  = (ns == state_fifo_start)  ? 1'b1 : 1'b0;
 assign S_FIFO_WAIT   = (ns == state_fifo_wait)   ? 1'b1 : 1'b0;
 assign S_DEST_SRC    = (ns == state_dest_src)    ? 1'b1 : 1'b0;
 assign S_SRC_LEN_SEQ = (ns == state_src_len_seq) ? 1'b1 : 1'b0;
 assign S_SRC_LEN_IP1 = (ns == state_src_len_ip1) ? 1'b1 : 1'b0;
 assign S_SRC_LEN_IP2 = (ns == state_src_len_ip2) ? 1'b1 : 1'b0;
 assign S_SRC_LEN_IP3 = (ns == state_src_len_ip3) ? 1'b1 : 1'b0;
 assign S_SRC_LEN_IP4 = (ns == state_src_len_ip4) ? 1'b1 : 1'b0;
 assign S_DATA        = (ns == state_data)        ? 1'b1 : 1'b0;
 assign S_TRANSITION  = (ns == state_transition)  ? 1'b1 : 1'b0;

// Length is used to store the payload length size. Payload length smaller than 46 will have zeros data padded
// Allowable fixed payload length: 6 -> 9582
// Allowable random payload length: 6 -> 1500
// --------------------------------------------------

always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         length <= 16'h0;
      end else begin
         if (S_IDLE | S_FIFO_WAIT | S_TRANSITION) begin
            if (~random_length & (pkt_length < 14'h0018)) begin
               length <= 16'h0;
            end else if (~random_length & (pkt_length > 14'h2580)) begin
               length <= 16'h2568;
            end else if (~random_length) begin
               length <= {2'b00, pkt_length - 14'h18}; // 18 B are reserved for the header (14 B) and trailer checksum (4 B)
            end else if (random_length) begin
               length <= (tx_prbs[74:64] % 16'h05D7);
            end
         end
      end
   end

// Byte_count is used to keep track of how many bytes of data payload being generated out
// --------------------------------------------------------------------------------------

always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         byte_count <= 16'h0;
      end else begin
         if (S_DEST_SRC) begin
            byte_count <= length;
         end else if ( (S_DATA|S_SRC_LEN_IP1|S_SRC_LEN_IP2|S_SRC_LEN_IP3|S_SRC_LEN_IP4) & tx_ready) begin
            byte_count <= byte_count - 16'h8;
         end
      end
   end

// Seq_num is inserted into the first 2 bytes of data payload of every packet
// ---------------------------------------------------------------------------

always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         seq_num <= 16'h0;
      end else begin
         if (start) begin
            seq_num <= 16'h0;
         end else if (S_TRANSITION & tx_ready) begin
            seq_num <= seq_num + 16'h1;
         end
      end
   end

// Generation of incremental data or pseudo random data
// -----------------------------------------------------
always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         data_pattern <= 64'h0;
      end else begin
         if (S_IDLE & ~random_payload) begin
            data_pattern <= 64'hd0000c0000b0000a; //64'h0000000000000000; //64'h0001020304050607;
         //end else if (S_DATA & ~random_payload & tx_ready & data_pattern == 64'hF8F9FAFBFCFDFEFF) begin
         //   data_pattern <= 64'h0001020304050607;
         end else if ((S_DATA|S_SRC_LEN_SEQ|S_SRC_LEN_IP1|S_SRC_LEN_IP2|S_SRC_LEN_IP3|S_SRC_LEN_IP4) & ~random_payload & tx_ready) begin
				//data_pattern <= data_pattern + 64'h0808080808080808;
            //data_pattern <= {56'h0000000000000000,fmc_in};
				data_pattern <= fifo_dataout;
         end else if ((S_SRC_LEN_SEQ | S_DATA) & random_payload & tx_ready) begin
            data_pattern <= tx_prbs[63:0];
         end
      end
   end

// Avalon-ST tx_data interface to CRC generator
// ---------------------------------------------


always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         tx_data_reg <= 64'h0;
      end else begin
         if (S_DEST_SRC) begin
            tx_data_reg[63:32] <= {DA5,DA4,DA3,DA2};
            tx_data_reg[31: 0] <= {DA1,DA0,SA5,SA4};
         end else if (S_SRC_LEN_SEQ) begin
            tx_data_reg[63:32] <= {SA3,SA2,SA1,SA0};
            if (do_IP) tx_data_reg[31: 0] <= {16'h0800, 16'h4500}; // Eth type (ipv4) , IP version IHL DSCP ECN
				else tx_data_reg[31: 0] <= {length + 16'h6, seq_num};
			end else if (S_SRC_LEN_IP1) begin
            tx_data_reg[63:32] <= {length + 16'h02, 16'h0}; // IP length , blank (don't want to mess up checksum)
            tx_data_reg[31: 0] <= {16'h4000, 16'h3011}; // Don't fragment, TTL and UDP
			end else if (S_SRC_LEN_IP2) begin
            tx_data_reg[63:32] <= {16'hAFB5, 16'hC0A8}; // Header chksum (for PACKET_SIZE 1512), src ip
            tx_data_reg[31: 0] <= {16'h0A0A, destip[31:16]}; // src ip , dest ip
			end else if (S_SRC_LEN_IP3) begin
            tx_data_reg[63:32] <= {destip[15:0], 16'h07E6}; // dest ip , src port
            tx_data_reg[31: 0] <= {16'h07E7, length - 16'h12}; // dest port , UDP length (20 less than IP length (header))
			end else if (S_SRC_LEN_IP4) begin
            tx_data_reg[63:32] <= {16'h0, seq_num}; // UDP dummy checksum , seq_num
            //tx_data_reg[31: 0] <= {packet_tx_count[15:0], {6'h0,fifo_rdusedw}}; // padding , padding
            tx_data_reg[31: 0] <= {zeros_in_216, verify_error_count}; // add count of verify errors
         end else if (S_DATA & tx_ready) begin
            tx_data_reg <= data_pattern;
         end
      end
   end

// Avalon-ST tx_valid interface to CRC generator
// ----------------------------------------------
always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         tx_valid_reg <= 1'b0;
      end else begin
         if (S_IDLE | S_FIFO_START |S_FIFO_WAIT | S_TRANSITION) begin
            tx_valid_reg <= 1'b0;
         end else begin
            tx_valid_reg <= 1'b1;
         end
      end
   end

   // Avalon-ST tx_sop interface to CRC generator
// --------------------------------------------
always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         tx_sop_reg <= 1'b0;
      end else begin
         if (S_DEST_SRC) begin
            tx_sop_reg <= 1'b1;
         end else begin
            tx_sop_reg <= 1'b0;
         end
      end
   end

// Avalon-ST tx_eop interface to CRC generator
// --------------------------------------------
always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         tx_eop_reg <= 1'b0;
      end else begin
         if (S_SRC_LEN_SEQ & (length == 0)) begin
            tx_eop_reg <= 1'b1;
         end else if (S_DATA & tx_ready & (byte_count <= 8)) begin
            tx_eop_reg <= 1'b1;
         end else if (S_TRANSITION) begin
            tx_eop_reg <= 1'b0;
         end
      end
   end

// Avalon-ST tx_empty interface to CRC generator
// ----------------------------------------------

assign empty = 4'h8 - length[2:0];

always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         tx_empty_reg <= 3'b000;
      end else begin
         if (S_DATA & tx_ready & (byte_count <= 8)) begin
            tx_empty_reg <= empty[2:0];
         end else if (S_TRANSITION) begin
            tx_empty_reg <= 3'b000;
         end
      end
   end

// Using CRC Compiler to generate checksum and append it to EOP
// -------------------------------------------------------------



crc32_gen  #(64,3)
//	.DATA_WIDTH (64),
//	.EMPTY_WIDTH (3),
//	.CRC_WIDTH	(32),
//	.REVERSE_DATA (1),
//	.OPERATION_MODE (1)
//)

crc32_gen_inst(
   .CLK    (clk),
	.RESET_N    (~reset),
	.AVST_VALID   (tx_valid_reg & tx_ready),
	.AVST_SOP      (tx_sop_reg),
	.AVST_DATA    (tx_data_reg),
	.AVST_EOP      (tx_eop_reg),
	.AVST_EMPTY     (tx_empty_reg),
	.CRC_VALID   (crc_valid),
	.CRC_CHECKSUM	(crc));



//crcgen_dat32 crcgen_inst
//(
//	.clk 		(clk),
//	.data 		(tx_data_reg),
//	.datavalid 	(tx_valid_reg & tx_rdy),
//	.empty 		(tx_empty_reg),
//	.endofpacket 	(tx_eop_reg),
//	.reset_n 	(~reset),
//	.startofpacket 	(tx_sop_reg),
//	.checksum 	(crc),
//	.crcvalid 	(crc_valid)
//);








// Using RAM based shift register to delay packet payload sending to TSE TX FIFO
// interface for CRC checksum merging at EOP
// -------------------------------------------------------------------------------

shiftreg_data shiftreg_data_inst
(
        .aclr           (reset),
        .clken          (tx_ready),
        .clock          (clk),
        .shiftin        (tx_data_reg),
        .shiftout       (tx_data_out),
        .taps           ()
);

// Using RAM based shift register to store and delay control signals
// ------------------------------------------------------------------

shiftreg_ctrl shiftreg_ctrl_inst
(
        .aclr           (reset),
        .clken          (tx_ready),
        .clock          (clk),
        .shiftin        ({tx_valid_reg, tx_sop_reg, tx_eop_reg, tx_empty_reg}),
        .shiftout       (tx_ctrl_out),
        .taps           ()
);

reg [2:0] start_cnt;

always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         crc_valid_count <= 3'b000;
		 start_cnt <= 0;
      end else begin
		 if (start_cnt < 4)
			start_cnt = start_cnt + 3'b001;
		 else
			crc_valid_count <= crc_valid_count + (crc_valid) - (tx_ready & tx_eop);
      end
   end

always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         crc_l1 <= 32'h0;
         crc_l2 <= 32'h0;
      end else begin
         if (crc_valid) begin
            crc_l1 <= crc;
            crc_l2 <= crc_l1;
            crc_l3 <= crc_l2;
            crc_l4 <= crc_l3;
         end
      end
   end

assign checksum = (crc_valid_count == 3'b001) ? crc_l1 :
                  (crc_valid_count == 3'b010) ? crc_l2 :
                  (crc_valid_count == 3'b011) ? crc_l3 :
                  (crc_valid_count == 3'b100) ? crc_l4 :
                  32'h0;

// Extend packet by one cycle when not enough
// space in last word to add in checksum
// -------------------------------------------

always @ (*)
   begin
      add_extra_qword <= 1'b0;
      if (tx_ctrl_out[5] & tx_ctrl_out[3]) begin // valid eop
         if (tx_ctrl_out[2] == 1'b0) begin // Less than 4 empty bytes
            add_extra_qword <= 1'b1;
         end
      end
   end

always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         valid_extended <= 1'b0;
         eop_extended   <= 1'b0;
         empty_extended <= 3'b000;
      end else begin
         if (tx_ready) begin
            if (add_extra_qword) begin
               valid_extended <= 1'b1;
               eop_extended   <= 1'b1;
               empty_extended[2]   <= 1'b1;
               empty_extended[1:0] <= tx_ctrl_out[1:0];
            end else begin
               valid_extended <= 1'b0;
               eop_extended   <= 1'b0;
               empty_extended[2]   <= 1'b0;
               empty_extended[1:0] <= 3'b000;
            end
         end
      end
   end

always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         tx_valid <= 1'b0;
         tx_sop   <= 1'b0;
         tx_eop   <= 1'b0;
         tx_empty <= 1'b0;
      end else begin
         if (tx_ready) begin
            tx_valid <= tx_ctrl_out[5] | valid_extended;
         end else begin
            //tx_valid <= 1'b0 ;
            tx_valid <= tx_valid ; // ajay: remain unchanged
         end    

         if (tx_ready) begin
            //tx_valid <= tx_ctrl_out[5] | valid_extended; // ajay: unnecessary: already defined above
            tx_sop   <= tx_ctrl_out[4];
            if (tx_ctrl_out[5] & tx_ctrl_out[3]) begin // valid eop
               tx_eop <= !add_extra_qword; // keep original
            end else begin
               tx_eop <= eop_extended;
            end
            if (tx_ctrl_out[5] & tx_ctrl_out[3]) begin // valid eop
               if (add_extra_qword) begin
                  tx_empty <= 3'b000;
               end else begin
                  tx_empty <= tx_ctrl_out[2:0] - 3'h4;
               end
            end else begin
               tx_empty <= empty_extended[2:0];
            end
         end
      end
   end

 always @ (posedge reset or posedge clk)
   begin
      if (reset) begin
         tx_data <= 64'h0;
      end else begin
         if (tx_ready) begin
            tx_data <= tx_data_out; // By default

            if (tx_ctrl_out[3]) begin // Normal EOP field
               case (tx_ctrl_out[2:0])
                  3'b000: tx_data <=  tx_data_out[63:0];
                  3'b001: tx_data <= {tx_data_out[63:8],  checksum[31:24]};
                  3'b010: tx_data <= {tx_data_out[63:16], checksum[31:16]};
                  3'b011: tx_data <= {tx_data_out[63:24], checksum[31: 8]};
                  3'b100: tx_data <= {tx_data_out[63:32], checksum[31: 0]};
                  3'b101: tx_data <= {tx_data_out[63:40], checksum[31: 0],  8'h0};
                  3'b110: tx_data <= {tx_data_out[63:48], checksum[31: 0], 16'h0};
                  3'b111: tx_data <= {tx_data_out[63:56], checksum[31: 0], 24'h0};
                  default: tx_data <= tx_data_out;
               endcase
            end else if (eop_extended) begin
               case (empty_extended)
                  3'b100: tx_data <= {checksum[31:0], 32'h0};
                  3'b101: tx_data <= {checksum[23:0], 40'h0};
                  3'b110: tx_data <= {checksum[15:0], 48'h0};
                  3'b111: tx_data <= {checksum[ 7:0], 56'h0};
                  default: tx_data <= 64'h0;
               endcase
            end
         end
      end
   end

assign tx_error = 1'b0;

 // ___________________________________________________________________________________________
 //		Debug Logic
 // ___________________________________________________________________________________________

 reg ppln_dasa, ppln_satlen, ppln_data, ppln_trnstn;
 always @ (posedge reset or posedge clk)
   begin
      if (reset) 
	 begin
             ppln_dasa <= 1'b0;
             ppln_satlen <= 1'b0;
             ppln_data <= 1'b0;
             ppln_trnstn <= 1'b0;
	 end
      else
	begin
             ppln_dasa <= S_DEST_SRC;
             ppln_satlen <= S_SRC_LEN_SEQ;
             ppln_data <= S_DATA;
             ppln_trnstn <= S_TRANSITION;
	end
   end
 
 wire ena_dasa = S_DEST_SRC & ~ppln_dasa;
 wire ena_satlen = S_SRC_LEN_SEQ & ~ppln_satlen;
 wire ena_data = S_DATA & ~ppln_data;
 wire ena_trnstn = S_TRANSITION & ~ppln_trnstn;
 
 always @ (posedge reset or posedge clk)
   begin
      if (reset) 
	 begin
	    cnt_dasa <= 32'd0;
	    cnt_satlen <= 32'd0;
	    cnt_data <= 32'd0;
	    cnt_trnstn <= 32'd0;
	 end
      else
	 begin
	    if (ena_dasa) cnt_dasa <= cnt_dasa + 32'd1;
	    if (ena_satlen) cnt_satlen <= cnt_satlen + 32'd1;
	    if (ena_data) cnt_data <= cnt_data + 32'd1;
	    if (ena_trnstn) cnt_trnstn <= cnt_trnstn + 32'd1;
	 end
    end

endmodule

 // ___________________________________________________________________________________________________
 //	PRBS23 GENERATOR
 // ___________________________________________________________________________________________________

//-----------------------------------------------------------------------------
// Functional Description:
// This module is the Pseudo-Random Bit Sequence 23 Block
// where g(x) = x^23 + x^18 + x^0
//
// use lsb of m 1st first
// k can be > N, but part of the sequence will be skipped
//
//-------------------------------------------------------------------------------

// turn off bogus verilog processor warnings
// altera message_off 10034 10035 10036 10037 10230


module prbs23 ( clk, rst_n, load, enable, seed, d, m);

	parameter k = 23;       //step value = a^k
	parameter N = 23;

	input   clk;
	input   rst_n;
	input   load;
	input   enable;
	input   [N-1:0] seed;
	input   [N-1:0] d;
	output  [N-1:0] m;
	
	reg     [N-1:0] m;
	reg     [N-1:0] tmpa;
	reg     [N-1:0] tmpb;
	integer i,j;


	always @ (d)
	begin
   	    tmpa = d;
   	    for (i=0; i<k; i=i+1) 
 	       begin
                 for (j=0; j<(N-1); j=j+1) begin tmpb[j] = tmpa[j+1]; end
      		 tmpb[N-1] = tmpa[18] ^ tmpa[0];      //x^23 + x[18] + x[0]
      		 tmpa = tmpb;
   	       end
	end

	always @(posedge clk or negedge rst_n)
        begin
	    begin
    		if (!rst_n) m <= 0;
    		else if (load) m <= seed;
    		else if (enable) m <= tmpb;
    	    end
	end


	
	
	
	
	
	
	
 endmodule