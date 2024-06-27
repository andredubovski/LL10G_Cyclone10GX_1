module ether_on (
	 input wire clk_in,         // Input clock (fast clock)
    input wire reset_in,       // Reset signal
    input wire ether_button_in,      // Button input
    output wire slow_clk_out,  // Slowed down clock output
	 output wire slow_clk_stgr_out,
    output wire ether_pulse_out     // Pulse sequence output
);

	 parameter SLOW_DIV = 160;	 // Clock division factor for slow clock (adjust as needed)
	 parameter SLOW_STR_DIV = 320;
    parameter SEQ_LEN = 58;    // Length of the pulse sequence
    
    // Pulse sequence (example: 01110101110101)
   // reg [SEQ_LEN-1:0] pulse_sequence = //40'b0_10011000_0_10011000_0_01111110_0_01001000_0_010;
	 reg [SEQ_LEN-1:0] send_out_command = 58'b00011000000000000_11_0000000000001111_11_0000000000000000_11000;
	 reg [SEQ_LEN-1:0] command_off = 58'b00011000000000000_11_0000000000000011_11_1111111111111100_11000;
	 reg [SEQ_LEN-1:0] command_on = 58'b00011000000000000_11_0000000000000011_11_1111111111000011_11000;
	 
	 reg [10:0] clk_div_counter = 0;
	 reg [10:0] clk_div_stgr_counter = 160;
    reg slow_clk = 0;
	 reg slow_clk_stgr = 1;
    reg [5:0] pulse_index_1 = 0;
	 reg [5:0] pulse_index_2 = 0;
	 reg [5:0] pulse_index_3 = 0;
	 reg [5:0] pulse_index_gen = 0;
	 reg [31:0] slow_clk_counter = 0;
    reg pulse_gen = 1;
	 reg reset_btn;
	 reg button_state = 1'b0;
	 reg button_d;
	 wire button_chg;
	 reg [19:0] button_counter = 20'b0;
	 
	 always @(posedge clk_in) begin
	     reset_btn = ~reset_in;
    end
	 
	 initial begin
	     
	 end
	 
	 
    // Clock Divider
    always @(posedge clk_in or negedge reset_in) begin
        if (~reset_in) begin
            clk_div_counter <= 0;
            slow_clk <= 0;
        end else begin
		      if (~button_state
				|| pulse_index_1 == 0
				|| (pulse_index_1 == SEQ_LEN && pulse_index_2 == 0)
				|| (pulse_index_1 == SEQ_LEN && pulse_index_2 == SEQ_LEN && pulse_index_3 == 0)) begin
				   slow_clk_stgr <= 1;
					
					if (clk_div_counter >= (SLOW_DIV - 1)) begin
						 clk_div_counter <= 0;
						 slow_clk = ~slow_clk;
					end else begin
						 clk_div_counter <= clk_div_counter + 1;
					end
				end else begin
					if ((clk_div_stgr_counter >= (SLOW_STR_DIV - 1))) begin
						 clk_div_stgr_counter <= 0;
						 slow_clk_stgr = ~slow_clk_stgr;
					end else begin
						 clk_div_stgr_counter <= clk_div_stgr_counter + 1;
					end
					if (clk_div_counter >= (SLOW_DIV - 1)) begin
						 clk_div_counter <= 0;
						 slow_clk = ~slow_clk;
					end else begin
						 clk_div_counter <= clk_div_counter + 1;
					end
				end
        end
    end
	     // Pulse Sequence Generation State Machine
    always @(posedge slow_clk or negedge reset_in) begin
        if (~reset_in) begin
            pulse_index_1 <= 0;
				pulse_index_2 <= 0;
				pulse_index_3 <= 0;
				pulse_index_gen <= 0;

            pulse_gen <= 1;
				button_d <= 0;
        end else begin
		      button_d <= ether_button_in;
		      if (button_counter <= 20'd200_001) begin
				    button_counter <= button_counter + 1;
				end
		      if ((~ether_button_in && ~button_state && button_chg) || (button_counter == 20'd200_000)) begin
				    button_state <= 1'b1;
		      end else if(button_state)begin
					 slow_clk_counter = slow_clk_counter +1;
					 if (slow_clk_counter < SEQ_LEN+2)begin
						 if (pulse_index_1 < SEQ_LEN) begin
							  pulse_gen <= send_out_command[SEQ_LEN - pulse_index_1 - 1];  // Corrected indexing
							  pulse_index_1 <= pulse_index_1 + 1;
							  pulse_index_gen <= pulse_index_gen + 1;
						 end else begin
							  pulse_index_gen <= 0;
							  pulse_gen <= 1;
							  //button_state <= 1'b0;
						 end
					 end else if (slow_clk_counter > 10000+SEQ_LEN && slow_clk_counter < 100_000)begin
						 //slow_clk_counter = slow_clk_counter +1;
						 if (pulse_index_2 < SEQ_LEN) begin
							  pulse_gen <= command_off[SEQ_LEN - pulse_index_2 - 1];  // Corrected indexing
							  pulse_index_2 <= pulse_index_2 + 1;
						 end else begin
							  pulse_index_gen <= 0;
							  pulse_gen <= 1;
							  //button_state <= 1'b0;
						 end
					end else if (slow_clk_counter > 110000)begin
						 //slow_clk_counter = slow_clk_counter +1;
						 if (pulse_index_3 < SEQ_LEN) begin
							  pulse_gen <= command_on[SEQ_LEN - pulse_index_3 - 1];  // Corrected indexing
							  pulse_index_3 <= pulse_index_3 + 1;
							  pulse_index_gen <= pulse_index_gen + 1;
						 end else begin
							  pulse_index_3 <= 0;
							  pulse_index_gen <= 0;
							  pulse_gen <= 1;
							  button_state <= 1'b0;
							  slow_clk_counter <= 0;
							  pulse_index_2 <= 0;
							  pulse_index_1 <= 0;
						 end
					 end

            end else begin
                pulse_index_1 <= 0;
					 pulse_index_2 <= 0;
					 pulse_index_3 <= 0;
					 pulse_index_gen <= 0;
                pulse_gen <= 1;
					 slow_clk_counter <= 0;
				
            end
        end
	 end

    // Assign outputs
    assign slow_clk_out = ~slow_clk;
	 assign slow_clk_stgr_out = slow_clk_stgr;
    assign ether_pulse_out = pulse_gen;
	 assign button_chg = (ether_button_in != button_d);


endmodule