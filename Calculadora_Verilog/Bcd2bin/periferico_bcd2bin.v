module periferico_bcd2bin(reloj, reset, dato_entrada, habilitacion_chip, direccion, leer, escribir, dato_salida);

  input reloj;
  input reset;
  input [19:0] dato_entrada;
  input habilitacion_chip;
  input [4:0]  direccion;
  input leer;
  input escribir;
  output reg [31:0] dato_salida;

  reg [4:0] selector;
  reg [19:0] registro_entrada;
  reg iniciar_conversion;
  wire [15:0] resultado_binario;
  wire conversion_terminada;

always @(*) begin
  if (habilitacion_chip) begin
    case (direccion)
      5'h04: selector =  5'b00001;
      5'h0C: selector =  5'b00100;
      5'h10: selector =  5'b01000;
      5'h14: selector =  5'b10000;
      default: selector = 5'b00000;
    endcase
  end
  else 
    selector = 5'b00000;
end

always @(posedge reloj) begin
  if(reset) begin
    iniciar_conversion = 0;
    registro_entrada    = 0;
  end
  else begin
    if (habilitacion_chip && escribir) begin
      registro_entrada    = selector[0] ? dato_entrada[19:0]    : registro_entrada;
      iniciar_conversion = selector[2] ? dato_entrada[0] : iniciar_conversion;
    end
  end
end

always @(posedge reloj) begin
  if(reset)
    dato_salida = 0;
  else if (habilitacion_chip) begin
    case (selector[4:0])
      5'b01000: dato_salida    =  {16'b0, resultado_binario};
      5'b10000: dato_salida    =  {31'b0, conversion_terminada};
    endcase
  end
end

convertidor_bcd_binario convertidor_bcd_binario0 (
  .reset(reset),
  .reloj(reloj),
  .inicio(iniciar_conversion),
  .terminado(conversion_terminada),
  .resultado_bin(resultado_binario),
  .entrada_bcd(registro_entrada)
);

endmodule