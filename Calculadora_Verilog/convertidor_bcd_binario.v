module convertidor_bcd_binario(reloj, reset, inicio, entrada_bcd, resultado_bin, terminado);

  input         reset;
  input         reloj;
  input         inicio;
  input  [19:0] entrada_bcd;
  output [15:0] resultado_bin;
  output        terminado;

  wire senal_desplazamiento;
  wire senal_carga;
  wire senal_seleccion;
  wire senal_carga_msb;
  wire senal_suma;
  wire senal_fin_contador;
  wire [4:0] senal_carga_registro;
  wire [4:0] senal_bits_significativos;

  wire [3:0] digito_unidades;
  wire [3:0] digito_decenas;
  wire [3:0] digito_centenas;
  wire [3:0] digito_millar;
  wire [3:0] digito_decenas_millar;
  wire [19:0] senal_carga_entrada;
  wire [19:0] senal_mux;

  assign senal_bits_significativos = { 
    senal_carga_entrada[19], 
    senal_carga_entrada[15], 
    senal_carga_entrada[11], 
    senal_carga_entrada[7], 
    senal_carga_entrada[3] 
  };

  registro_desplazamiento_bcd2bin registro0 (
    .reloj(reloj),
    .reset_carga(senal_carga),
    .desplazar(senal_desplazamiento),
    .carga_a2(senal_carga_registro),
    .entrada_reg1(entrada_bcd),
    .entrada_reg2(senal_carga_entrada),
    .salida_reg({digito_decenas_millar, digito_millar, digito_centenas, digito_decenas, digito_unidades}),
    .salida_reg2(resultado_bin)
  );
  
  selector_bcd2bin selector0 ( .entrada_a(4'b1101), .entrada_b(4'b1011), .salida(senal_mux[3:0]),   .seleccion(senal_seleccion) );
  selector_bcd2bin selector1 ( .entrada_a(4'b1101), .entrada_b(4'b1011), .salida(senal_mux[7:4]),   .seleccion(senal_seleccion) );
  selector_bcd2bin selector2 ( .entrada_a(4'b1101), .entrada_b(4'b1011), .salida(senal_mux[11:8]),  .seleccion(senal_seleccion) );
  selector_bcd2bin selector3 ( .entrada_a(4'b1101), .entrada_b(4'b1011), .salida(senal_mux[15:12]), .seleccion(senal_seleccion) );
  selector_bcd2bin selector4 ( .entrada_a(4'b1101), .entrada_b(4'b1011), .salida(senal_mux[19:16]), .seleccion(senal_seleccion) );
  
  add_sub_c2 sumador0  ( .in_A(digito_unidades), .in_B(senal_mux[3:0]),   .Result(senal_carga_entrada[3:0])   );
  add_sub_c2 sumador1  ( .in_A(digito_decenas), .in_B(senal_mux[7:4]),   .Result(senal_carga_entrada[7:4])   );
  add_sub_c2 sumador2  ( .in_A(digito_centenas), .in_B(senal_mux[11:8]),  .Result(senal_carga_entrada[11:8])  );
  add_sub_c2 sumador3  ( .in_A(digito_millar), .in_B(senal_mux[15:12]),  .Result(senal_carga_entrada[15:12]) );
  add_sub_c2 sumador4  ( .in_A(digito_decenas_millar), .in_B(senal_mux[19:16]), .Result(senal_carga_entrada[19:16]) );
  
  registro_msb_bcd2bin registro_msb0 ( 
    .reloj(reloj), 
    .reset(senal_carga), 
    .entrada(senal_bits_significativos), 
    .salida(senal_carga_registro), 
    .carga(senal_carga_msb), 
    .habilitar_salida(senal_suma) 
  );

  contador_bcd2bin contador0 ( .reloj(reloj), .carga(senal_carga) , .decrementar(senal_desplazamiento), .fin_contador(senal_fin_contador));
  controlador_bcd2bin controlador0 ( 
    .reloj(reloj), 
    .reset(reset), 
    .inicio(inicio), 
    .terminado(terminado), 
    .desplazar(senal_desplazamiento), 
    .cargar(senal_carga), 
    .seleccionar(senal_seleccion), 
    .cargar_msb(senal_carga_msb), 
    .sumar(senal_suma), 
    .fin_contador(senal_fin_contador) 
  );

endmodule