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


`ifndef DEFAULT_TEST_PARAMS_PKT__SV
`define DEFAULT_TEST_PARAMS_PKT__SV

// Package defines Avalon-MM and Avalon-ST interface parameters for BFM
package default_test_params_pkt;
    
    // Number of channels
    // Support only 2 channels by default
    parameter NUM_OF_CHANNEL            = 2;
    
    // Length/Type
    parameter LENGTH_TYPE_VLAN          = 16'h8100;
    
    // VLAN info
    parameter NO_VLAN                   = 0;
    parameter VLAN                      = 1;
    parameter STACK_VLAN                = 2;
    
    // Parameter definition for MAC configuration
    parameter INVALID_ADDR              = 48'h00_00_00_00_00_00;    
    parameter MAC_ADDR                  = 48'hEE_CC_88_CC_AA_EE;
    
    parameter INSERT_PAD                = 1;
    parameter NO_INSERT_PAD             = 0;
    parameter INSERT_CRC                = 1;
    parameter NO_INSERT_CRC             = 0;
    
    // Running Speed
    parameter ETH_SPEED_10G             = 3'b011;
    parameter ETH_SPEED_5G              = 3'b101;
    parameter ETH_SPEED_2P5G            = 3'b100;
    parameter ETH_SPEED_1G              = 3'b010;
    parameter ETH_SPEED_100M            = 3'b001;
    parameter ETH_SPEED_10M             = 3'b000;

endpackage

`endif

