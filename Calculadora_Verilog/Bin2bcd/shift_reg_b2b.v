module shift_reg_b2b (clock, reset_load, shift_enable, load_select, input_data1, input_data2, output_data);
   input         clock;
   input         reset_load;
   input         shift_enable;
   input  [4:0]  load_select;
   input  [15:0] input_data1;
   input  [19:0] input_data2;
   output [19:0] output_data;

   reg [35:0]  shift_register;

assign output_data = shift_register[35:16];

always @(negedge clock)
  if(reset_load) begin
    shift_register[35:16] <= 20'h00000;
    shift_register[15:0]  <= input_data1;
  end
  else
   begin
    if(shift_enable)
      shift_register[35:0] <= {shift_register[34:0], 1'b0} ;
    else begin
      if(load_select[4]==1)
        shift_register[35:32] <= input_data2[19:16];
      if(load_select[3]==1)
        shift_register[31:28] <= input_data2[15:12];
      if(load_select[2]==1)
        shift_register[27:24] <= input_data2[11:8];
      if(load_select[1]==1)
        shift_register[23:20] <= input_data2[7:4];
      if(load_select[0]==1)
        shift_register[19:16] <= input_data2[3:0];
    end 
   end
endmodule