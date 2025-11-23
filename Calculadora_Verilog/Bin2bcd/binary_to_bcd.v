module binary_to_bcd(clock, reset, start, binary_input, bcd_output, conversion_done);

  input         reset;
  input         clock;
  input         start;
  input  [15:0] binary_input;
  output [19:0] bcd_output;
  output        conversion_done;

  wire shift_enable;
  wire load_enable;
  wire select_signal;
  wire load_msb;
  wire add_enable;
  wire zero_flag;
  wire [4:0] load_signal;
  wire [4:0] msb_bits;

  wire [3:0] units;
  wire [3:0] tens;
  wire [3:0] hundreds;
  wire [3:0] thousands;
  wire [3:0] ten_thousands;
  wire [19:0] adder_output;
  wire [19:0] mux_output;

  assign msb_bits = { adder_output[19], adder_output[15], adder_output[11], adder_output[7], adder_output[3] };
  assign bcd_output = {ten_thousands, thousands, hundreds, tens, units};

  shift_reg_b2b shift_register0 ( 
    .clock(clock), 
    .reset_load(load_enable), 
    .shift_enable(shift_enable), 
    .load_select(load_signal), 
    .input_data1(binary_input), 
    .input_data2(adder_output), 
    .output_data({ten_thousands, thousands, hundreds, tens, units}) 
  );

  mux_b2b mux0 ( 
    .input_a(4'b0011), 
    .input_b(4'b1011), 
    .select(select_signal), 
    .output_data(mux_output[3:0]) 
  );
  mux_b2b mux1 ( 
    .input_a(4'b0011), 
    .input_b(4'b1011), 
    .select(select_signal), 
    .output_data(mux_output[7:4]) 
  );
  mux_b2b mux2 ( 
    .input_a(4'b0011), 
    .input_b(4'b1011), 
    .select(select_signal), 
    .output_data(mux_output[11:8]) 
  );
  mux_b2b mux3 ( 
    .input_a(4'b0011), 
    .input_b(4'b1011), 
    .select(select_signal), 
    .output_data(mux_output[15:12]) 
  );
  mux_b2b mux4 ( 
    .input_a(4'b0011), 
    .input_b(4'b1011), 
    .select(select_signal), 
    .output_data(mux_output[19:16]) 
  );

  add_sub_c2 adder0 ( .in_A(units),   .in_B(mux_output[3:0]),   .Result(adder_output[3:0])   );
  add_sub_c2 adder1 ( .in_A(tens),    .in_B(mux_output[7:4]),   .Result(adder_output[7:4])   );
  add_sub_c2 adder2 ( .in_A(hundreds), .in_B(mux_output[11:8]),  .Result(adder_output[11:8])  );
  add_sub_c2 adder3 ( .in_A(thousands), .in_B(mux_output[15:12]), .Result(adder_output[15:12]) );
  add_sub_c2 adder4 ( .in_A(ten_thousands), .in_B(mux_output[19:16]), .Result(adder_output[19:16]) );

  msb_reg_b2b msb_register0 ( 
    .clock(clock), 
    .reset(load_enable), 
    .input_data(msb_bits), 
    .output_data(load_signal), 
    .load(load_msb), 
    .output_enable(add_enable) 
  );

  counter_b2b counter0 ( 
    .clock(clock), 
    .load(load_enable), 
    .decrement(shift_enable), 
    .zero(zero_flag)
  );

  control_unit_b2b control0 ( 
    .clock(clock), 
    .reset(reset), 
    .start(start), 
    .finished(conversion_done), 
    .shift(shift_enable), 
    .load(load_enable), 
    .select(select_signal), 
    .load_msb(load_msb), 
    .add_enable(add_enable), 
    .zero(zero_flag) 
  );

endmodule