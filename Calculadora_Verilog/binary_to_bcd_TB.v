`timescale 1ns / 1ps
`define SIMULATION
module binary_to_bcd_TB;
   reg  clock;
   reg  reset;
   reg  start;
   reg  [15:0] binary_input;
   wire [19:0] bcd_output;
   wire done;

   binary_to_bcd uut (
      .clock(clock),
      .reset(reset),
      .start(start),
      .binary_input(binary_input),
      .bcd_output(bcd_output),
      .conversion_done(done)
   );

   parameter PERIOD          = 20;
   parameter real DUTY_CYCLE = 0.5;
   parameter OFFSET          = 0;
   reg [20:0] i;

   initial begin  // Initialize Inputs
      clock = 0; reset = 0; start = 0; binary_input = 16'h7771;
   end

   initial  begin  // Process for clock
     #OFFSET;
     forever
       begin
         clock = 1'b0;
         #(PERIOD-(PERIOD*DUTY_CYCLE)) clock = 1'b1;
         #(PERIOD*DUTY_CYCLE);
       end
   end

   initial begin // Reset the system, Start the image capture process
        @ (negedge clock);
        reset = 1;
        @ (negedge clock);
        reset = 0;
        @ (posedge clock);
        start = 0;
        @ (posedge clock);
        start = 1;
       for(i=0; i<2; i=i+1) begin
         @ (posedge clock);
       end
          start = 0;
       for(i=0; i<17; i=i+1) begin
         @ (posedge clock);
       end
   end	 

   initial begin: TEST_CASE
     $dumpfile("binary_to_bcd_TB.vcd");
     $dumpvars(-1, uut);
     #((PERIOD*DUTY_CYCLE)*200) $finish;
   end

endmodule