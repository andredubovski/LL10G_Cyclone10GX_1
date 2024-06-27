# (C) 2001-2018 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


#!/usr/bin/tclsh8.4
##==============================================================================
##        Generator Registers Map
##==============================================================================
source traffic_controller/gen/gen_reg_map.tcl
source basic/basic.tcl
source system_base_addr_map.tcl

proc SETGEN_DO_TEST_COUNTER_DATA {value} {
    global GEN_BASE_ADDR
    global GEN_DO_TEST_COUNTER_DATA
    puts "\t GEN_DO_TEST_COUNTER_DATA $value "
    reg_write $GEN_BASE_ADDR $GEN_DO_TEST_COUNTER_DATA $value
}

proc SETGEN_fifo_clk_prescale {value} {
    global GEN_BASE_ADDR
    global GEN_fifo_clk_prescale
    puts "\t GEN_fifo_clk_prescale $value "
    reg_write $GEN_BASE_ADDR $GEN_fifo_clk_prescale $value
}

proc SETGEN_destip {value} {
    global GEN_BASE_ADDR
    global GEN_destip
    puts "\t GEN_destip $value "
    reg_write $GEN_BASE_ADDR $GEN_destip $value
}

###PULSES

#commands for positive sequence
#1+
proc PULSES_pos1dur {value} {
    global GEN_BASE_ADDR
    global GEN_pos1dur
    puts "\t GEN_pos1dur $value "
    reg_write $GEN_BASE_ADDR $GEN_pos1dur $value
}

proc PULSES_pos1pausedur {value} {
    global GEN_BASE_ADDR
    global GEN_pos1pausedur
    puts "\t GEN_pos1pausedur $value "
    reg_write $GEN_BASE_ADDR $GEN_pos1pausedur $value
}

#2+
proc PULSES_pos2dur {value} {
    global GEN_BASE_ADDR
    global GEN_pos2dur
    puts "\t GEN_pos2dur $value "
    reg_write $GEN_BASE_ADDR $GEN_pos2dur $value
}

proc PULSES_pos2pausedur {value} {
    global GEN_BASE_ADDR
    global GEN_pos2pausedur
    puts "\t GEN_pos2pausedur $value "
    reg_write $GEN_BASE_ADDR $GEN_pos2pausedur $value
}

#3+
proc PULSES_pos3dur {value} {
    global GEN_BASE_ADDR
    global GEN_pos3dur
    puts "\t GEN_pos3dur $value "
    reg_write $GEN_BASE_ADDR $GEN_pos3dur $value
}

proc PULSES_pos3pausedur {value} {
    global GEN_BASE_ADDR
    global GEN_pos3pausedur
    puts "\t GEN_pos3pausedur $value "
    reg_write $GEN_BASE_ADDR $GEN_pos3pausedur $value
}

#4+
proc PULSES_pos4dur {value} {
    global GEN_BASE_ADDR
    global GEN_pos4dur
    puts "\t GEN_pos4dur $value "
    reg_write $GEN_BASE_ADDR $GEN_pos4dur $value
}

proc PULSES_pos4pausedur {value} {
    global GEN_BASE_ADDR
    global GEN_pos4pausedur
    puts "\t GEN_pos4pausedur $value "
    reg_write $GEN_BASE_ADDR $GEN_pos4pausedur $value
}


#commands for negative sequence
#1-
proc PULSES_neg1dur {value} {
    global GEN_BASE_ADDR
    global GEN_neg1dur
    puts "\t GEN_neg1dur $value "
    reg_write $GEN_BASE_ADDR $GEN_neg1dur $value
}

proc PULSES_neg1pausedur {value} {
    global GEN_BASE_ADDR
    global GEN_neg1pausedur
    puts "\t GEN_neg1pausedur $value "
    reg_write $GEN_BASE_ADDR $GEN_neg1pausedur $value
}

#2-
proc PULSES_neg2dur {value} {
    global GEN_BASE_ADDR
    global GEN_neg2dur
    puts "\t GEN_neg2dur $value "
    reg_write $GEN_BASE_ADDR $GEN_neg2dur $value
}

proc PULSES_neg2pausedur {value} {
    global GEN_BASE_ADDR
    global GEN_neg2pausedur
    puts "\t GEN_neg2pausedur $value "
    reg_write $GEN_BASE_ADDR $GEN_neg2pausedur $value
}

#3-
proc PULSES_neg3dur {value} {
    global GEN_BASE_ADDR
    global GEN_neg3dur
    puts "\t GEN_neg3dur $value "
    reg_write $GEN_BASE_ADDR $GEN_neg3dur $value
}

proc PULSES_neg3pausedur {value} {
    global GEN_BASE_ADDR
    global GEN_neg3pausedur
    puts "\t GEN_neg3pausedur $value "
    reg_write $GEN_BASE_ADDR $GEN_neg3pausedur $value
}

#4-
proc PULSES_neg4dur {value} {
    global GEN_BASE_ADDR
    global GEN_neg4dur
    puts "\t GEN_neg4dur $value "
    reg_write $GEN_BASE_ADDR $GEN_neg4dur $value
}

proc PULSES_neg4pausedur {value} {
    global GEN_BASE_ADDR
    global GEN_neg4pausedur
    puts "\t GEN_neg4pausedur $value "
    reg_write $GEN_BASE_ADDR $GEN_neg4pausedur $value
}

#trigger offset
proc offset {value} {
    global GEN_BASE_ADDR
    global GEN_offset
    puts "\t GEN_offset $value "
    reg_write $GEN_BASE_ADDR $GEN_offset $value
}

#mode command (to turn off xor)
proc xor {value} {
    global GEN_BASE_ADDR
    global GEN_mode
    puts "\t GEN_mode $value "
    reg_write $GEN_BASE_ADDR $GEN_mode $value
}

#########

proc dacwrite {chip_id channel vol} {
	global GEN_BASE_ADDR
	global GEN_chip_id
	global GEN_channel
	global GEN_vol
	puts "\t dacwrite channel $channel to voltage $vol "
	reg_write $GEN_BASE_ADDR $GEN_chip_id $chip_id
	reg_write $GEN_BASE_ADDR $GEN_channel $channel
	reg_write $GEN_BASE_ADDR $GEN_vol $vol
}

##proc button {value} {
##	global GEN_BASE_ADDR
##	global GEN_button
##	puts "\t button set to $value " 
##	reg_write $GEN_BASE_ADDR $GEN_button $value
##}


proc SET_1588_GO_MASTER {} {
    global TRAFFIC_CONTROLLER_BASE_ADDR
    global GO_MASTER
    puts "\t Master 1588 start 1 step operation "
    puts "TRAFFIC_CONTROLLER_BASE_ADDR: $TRAFFIC_CONTROLLER_BASE_ADDR   "
    reg_write $TRAFFIC_CONTROLLER_BASE_ADDR $GO_MASTER 0x00000003
}

proc SET_1588_START_TOD_SYNC {} {
    global TRAFFIC_CONTROLLER_BASE_ADDR
    global START_TOD_SYNC
    puts "\t Start TOD synchronization "
    reg_write $TRAFFIC_CONTROLLER_BASE_ADDR $START_TOD_SYNC 0xFF
}

proc RESET_1588_GO_MASTER {} {
    global TRAFFIC_CONTROLLER_BASE_ADDR
    global GO_MASTER
    puts "\t Reset Master 1588 start 1 step operation "
    reg_write $TRAFFIC_CONTROLLER_BASE_ADDR $GO_MASTER 0x00000000
}

proc RESET_1588_START_TOD_SYNC {} {
    global TRAFFIC_CONTROLLER_BASE_ADDR
    global START_TOD_SYNC
    puts "\t Reset Start TOD synchronization "
    reg_write $TRAFFIC_CONTROLLER_BASE_ADDR $START_TOD_SYNC 0x00000000
}

proc SETGEN_PAYLOADRANDOM {} {
    global GEN_BASE_ADDR
    global GEN_RANDOMPAYLOAD
    puts "\t payload bytes = random bytes .... "
    reg_write $GEN_BASE_ADDR $GEN_RANDOMPAYLOAD 0x00000001
}

proc SETGEN_PAYLOADFIXED {} {
    global GEN_BASE_ADDR
    global GEN_RANDOMPAYLOAD
    puts "\t payload bytes = fixed incremental bytes .... "
    reg_write $GEN_BASE_ADDR $GEN_RANDOMPAYLOAD 0x00000000
}

proc SETGEN_LENGTHRANDOM {} {
    global GEN_BASE_ADDR
    global GEN_RANDOMLENGTH
    puts "\t payload length = variable (random) .... "
    reg_write $GEN_BASE_ADDR $GEN_RANDOMLENGTH 0x00000001
}

proc SETGEN_LENGTHFIXED {} {
    global GEN_BASE_ADDR
    global GEN_RANDOMLENGTH
    puts "\t payload length = fixed .... "
    reg_write $GEN_BASE_ADDR $GEN_RANDOMLENGTH 0x00000000
}

proc SETGEN_PKTLENGTH {value} {
    global GEN_BASE_ADDR
    global GEN_PKTLENGTH
    puts "\t payload length =  $value .... "
    reg_write $GEN_BASE_ADDR $GEN_PKTLENGTH $value
}
proc SETGEN_START {} {
    global GEN_BASE_ADDR
    global GEN_START
    puts "\t burst being injected into device ...."
    reg_write $GEN_BASE_ADDR $GEN_START  0x00000001
}

proc SETGEN_STOP {} {
    global GEN_BASE_ADDR
    global GEN_STOP
    puts "\t burst generation stopped ..."
    reg_write $GEN_BASE_ADDR $GEN_STOP 0x00000001
}

proc SETGEN_NUMPKTS {value} {
    global GEN_BASE_ADDR
    global GEN_NUMPKTS
    puts "\t burst size =  $value ...."
    reg_write $GEN_BASE_ADDR $GEN_NUMPKTS $value
}

proc SETGEN_MACDA {value} {
    global GEN_BASE_ADDR
    global GEN_MACDA0
    global GEN_MACDA1
    set gen_dst_addr1 0x[string range $value 0 3]
    set gen_dst_addr0 0x[string range $value 4 11]
    puts "\t frame destination addres field = $value ...."
    reg_write $GEN_BASE_ADDR $GEN_MACDA1 $gen_dst_addr1
    reg_write $GEN_BASE_ADDR $GEN_MACDA0 $gen_dst_addr0
}

proc SETGEN_MACSA {value} {
    global GEN_BASE_ADDR
    global GEN_MACSA0
    global GEN_MACSA1
    set gen_src_addr1 0x[string range $value 0 3]
    set gen_src_addr0 0x[string range $value 4 11]
    puts "\t frame source addres field = $value ...."
    reg_write $GEN_BASE_ADDR $GEN_MACSA1 $gen_src_addr1
    reg_write $GEN_BASE_ADDR $GEN_MACSA0 $gen_src_addr0
}

proc CONFIG_BURST {burst_type burst_size pkt_type pkt_size } {
    if {$burst_type == "RANDOM"} {SETGEN_LENGTHRANDOM} else {SETGEN_LENGTHFIXED}
    if {$pkt_type == "RANDOM"} {SETGEN_PAYLOADRANDOM} else {SETGEN_PAYLOADFIXED}
    SETGEN_NUMPKTS $burst_size
    SETGEN_PKTLENGTH $pkt_size
}

proc CHKGEN_CONFIG {} {
    
    global GEN_BASE_ADDR
    global GEN_NUMPKTS
    global GEN_RANDOMLENGTH
    global GEN_RANDOMPAYLOAD
    global GEN_START
    global GEN_STOP
    global GEN_MACSA0
    global GEN_MACSA1
    global GEN_MACDA0
    global GEN_MACDA1
    global GEN_TXPKTCNT
    global GEN_RNDSEED0
    global GEN_RNDSEED1
    global GEN_RNDSEED2
    global GEN_PKTLENGTH
    
    puts "\t             ================================================================="
    puts "\t             | GENERATOR CONFIGURATION AND STATUS                             "
    puts "\t             ================================================================="
    puts "\t             | NUM OF FRAMES_CONFIGURED             = [format %u [reg_read $GEN_BASE_ADDR $GEN_NUMPKTS]] "
    puts "\t             | NUM OF FRAMES_TRANSMITTED            = [format %u [reg_read $GEN_BASE_ADDR $GEN_TXPKTCNT]] "
    puts "\t             | FRAME_LENGTH_CONFIGURED              = [format %u [reg_read $GEN_BASE_ADDR $GEN_PKTLENGTH]] "
    puts "\t             | RANDOM_LENGTH_CONFIGURATION          = [format %u [reg_read $GEN_BASE_ADDR $GEN_RANDOMLENGTH]] "
    puts "\t             | RANDOM_PAYLOAD_CONFIGURATION         = [format %u [reg_read $GEN_BASE_ADDR $GEN_RANDOMPAYLOAD]] "
    puts "\t             | FRAME_SOURCE_ADDRESS_CONFIGURED      = [reg_read $GEN_BASE_ADDR $GEN_MACSA1] "
    puts "\t             | FRAME_DESTINATION_ADDRESS_CONFIGURED = [reg_read $GEN_BASE_ADDR $GEN_MACDA1] "
    puts "\t             | Generator Start value                = [reg_read $GEN_BASE_ADDR $GEN_START] "

}

proc PROCESS_GEN {} {
    CHKGEN_CONFIG
}
