`timescale 1ns / 1ps

`define SIMULATION
module peripheral_binary_to_bcd_TB;
   reg clock;
   reg  reset;
   reg  start;
   reg [15:0] data_input;
   reg chip_select;
   reg [4:0] address;
   reg read;
   reg write;
   wire [31:0] data_output;

	peripheral_binary_to_bcd uut (
      .clock(clock),
      .reset(reset),
      .data_input(data_input),
      .chip_select(chip_select),
      .address(address), // 4 LSB from j1_io_addr
      .read(read),
      .write(write),
      .data_output(data_output)
	);

   parameter PERIOD = 20;
   // Initialize Inputs
   initial begin  
      clock = 0; reset = 0; data_input = 0; address = 16'h0000; chip_select=0; read=0; write=0;
   end
   // clock generation
   initial         clock <= 0;
   always #(PERIOD/2) clock <= ~clock;

   initial begin 
    forever begin
     // Reset 
     @ (posedge clock);
	  reset = 1;
	  @ (posedge clock);
	  reset = 0;
     #(PERIOD*4)
     // input_register operator
	  chip_select=1; read=0; write=1;
	  data_input = 16'hCAFE;
	  address = 16'h0004;
     #(PERIOD)
     chip_select=0; read=0; write=0;
     #(PERIOD*4)
     chip_select=0; read=0; write=0;
     #(PERIOD*3)
     // Init signal
	  chip_select=1; read=0; write=1;
	  data_input = 16'h0001;
	  address = 16'h000C;
     #(PERIOD)
     chip_select=0; read=0; write=0;
     @ (posedge peripheral_binary_to_bcd_TB.uut.binary_to_bcd0.conversion_done);
     // read done
     chip_select=1; read=1; write=0;
     address = 16'h0010;
     #(PERIOD)
     chip_select=0; read=0; write=0;
     #(PERIOD)
     // read data	
     chip_select=1; read=1; write=0;
     address = 16'h0014;
     #(PERIOD);
     chip_select=0; read=0; write=0;
     #(PERIOD*30);   
    end
   end
	 
   initial begin: TEST_CASE
     $dumpfile("peripheral_binary_to_bcd_TB.vcd");
     $dumpvars(-1, peripheral_binary_to_bcd_TB);
     #(PERIOD*100) $finish;
   end

endmodule