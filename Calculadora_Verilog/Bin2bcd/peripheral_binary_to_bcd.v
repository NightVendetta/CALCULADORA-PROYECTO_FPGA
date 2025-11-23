module peripheral_binary_to_bcd(clock, reset, data_input, chip_select, address, read, write, data_output);
  input clock;
  input reset;
  input [15:0] data_input;
  input chip_select;
  input [4:0]  address; // 4 LSB from j1_io_addr
  input read;
  input write;
  output reg [31:0] data_output;

//------------------------------------ regs and wires-------------------------------
reg [4:0] select_signal; 	//selector for mux and write registers
reg [15:0] input_register; // input register for binary number
reg start_conversion;
wire [19:0] bcd_result;	// binary_to_bcd output Regs
wire conversion_done;
//------------------------------------ regs and wires-------------------------------

//------address_decoder------------------------------
always @(*) begin
  if (chip_select) begin
    case (address)
      5'h04: select_signal =  5'b00001; // input_register 
      5'h0C: select_signal =  5'b00100; // start_conversion
      5'h10: select_signal =  5'b01000; // bcd_result
      5'h14: select_signal =  5'b10000; // conversion_done
      default: select_signal = 5'b00000;
    endcase
  end
  else 
    select_signal = 5'b00000;
end//------------------address_decoder--------------------------------

//-------------------- escritura de registros 
always @(posedge clock) begin
  if(reset) begin
    start_conversion = 0;
    input_register    = 0;
  end
  else begin
    if (chip_select && write) begin
      input_register    = select_signal[0] ? data_input    : input_register;	//Write Registers
      start_conversion = select_signal[2] ? data_input[0] : start_conversion;
    end
  end
end//------------------------------------------- escritura de registros

//-----------------------mux_4 :  multiplexa salidas del periferico
always @(posedge clock) begin
  if(reset)
    data_output = 0;
  else if (chip_select) begin
    case (select_signal[4:0])
      5'b01000: data_output =  {12'b0, bcd_result};
      5'b10000: data_output =  {31'b0, conversion_done};
    endcase
  end
end//-----------------------------------------------mux_4

binary_to_bcd binary_to_bcd0 (
  .reset(reset),
  .clock(clock),
  .start(start_conversion),
  .conversion_done(conversion_done),
  .binary_input(input_register),
  .bcd_output(bcd_result)
);

endmodule