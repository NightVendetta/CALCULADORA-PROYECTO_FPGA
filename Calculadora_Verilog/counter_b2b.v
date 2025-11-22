module counter_b2b (clock, load, decrement, zero);
  input clock;
  input load;
  input decrement;
  output reg zero;
  reg [4:0] count=8;

always @(negedge clock) begin
  if (load) 
    count  <= 5'b10000; //16
  else begin
    if (decrement) 
      count  <= count-1;
    else
      count  <= count;
  end
  zero = (count==0) ? 1 : 0 ;
end
endmodule