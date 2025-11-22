module msb_reg_b2b (clock, reset, input_data, output_data, load, output_enable);
  input             clock;
  input             reset;
  input             load;
  input             output_enable;
  input      [4:0]  input_data;
  output reg [4:0]  output_data;
  reg [4:0] internal_register;

always @(*) begin
  if(output_enable)
    output_data = ~internal_register;
  else
    output_data = 0;
end

always @(negedge clock) begin
  if (reset) begin
    internal_register  <= 0;
  end
  else begin
    if ( load )
      internal_register  <= input_data;
  end
end
endmodule