module selector_bcd2bin (entrada_a, entrada_b, salida, seleccion);

  input [3:0]      entrada_a;
  input [3:0]      entrada_b;
  input            seleccion;
  output reg [3:0] salida;

always @(*) begin
  if(seleccion)    
    salida = entrada_b;
  else
    salida = entrada_a;
end

endmodule