module contador_bcd2bin (reloj, carga, decrementar, fin_contador);

  input reloj;
  input carga;
  input decrementar;
  output reg fin_contador;

  reg [4:0] contador_interno = 8;

always @(negedge reloj) begin
  if (carga) 
    contador_interno  <= 5'b10000; // 16
  else begin
    if (decrementar) 
      contador_interno  <= contador_interno - 1;
    else
      contador_interno  <= contador_interno;
  end
  fin_contador = (contador_interno == 0) ? 1 : 0 ;
end

endmodule