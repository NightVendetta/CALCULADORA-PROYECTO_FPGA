module registro_msb_bcd2bin (reloj, reset, entrada, salida, carga, habilitar_salida);

  input             reloj;
  input             reset;
  input             carga;
  input             habilitar_salida;
  input      [4:0]  entrada;
  output reg    [4:0]  salida;

  reg [4:0] contador_interno;

always @(*) begin
  if(habilitar_salida)
    salida = ~contador_interno;
  else
    salida = 0;
end

always @(negedge reloj) begin
  if (reset) begin
    contador_interno  <= 0;
  end
  else begin
    if ( carga )
      contador_interno  <= entrada;
  end
end

endmodule