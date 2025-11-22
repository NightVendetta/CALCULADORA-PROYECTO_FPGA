module mux_b2b (input_a, input_b, select, output_data);
  input [3:0]      input_a;
  input [3:0]      input_b;
  input            select;
  output reg [3:0] output_data;

always @(*) begin
  if(select)    
    output_data = input_b;
  else
    output_data = input_a;
end
endmodule