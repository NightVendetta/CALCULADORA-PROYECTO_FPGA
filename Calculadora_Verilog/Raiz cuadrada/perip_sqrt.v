module periferico_raiz(
    input reloj,
    input reiniciar,
    input [15:0] entrada_datos,
    input habilitar,
    input [4:0] direccion,
    input leer,
    input escribir,
    output reg [31:0] salida_datos
);

reg [4:0] selector;
reg [15:0] registro_valor;
reg iniciar_operacion;
wire [15:0] resultado_raiz;
wire operacion_terminada;

always @(*) begin
    if (habilitar) begin
        case (direccion)
            5'h04: selector = 5'b00001;
            5'h0C: selector = 5'b00100;
            5'h10: selector = 5'b01000;
            5'h14: selector = 5'b10000;
            default: selector = 5'b00000;
        endcase
    end
    else 
        selector = 5'b00000;
end

always @(negedge reloj) begin
    if (reiniciar) begin
        iniciar_operacion <= 0;
        registro_valor <= 0;
    end
    else begin
        if (habilitar && escribir) begin
            registro_valor <= selector[0] ? entrada_datos : registro_valor;
            iniciar_operacion <= selector[2] ? entrada_datos[0] : iniciar_operacion;
        end
    end
end

always @(negedge reloj) begin
    if (reiniciar)
        salida_datos <= 0;
    else if (habilitar) begin
        case (selector[4:0])
            5'b01000: salida_datos <= {16'b0, resultado_raiz};
            5'b10000: salida_datos <= {31'b0, operacion_terminada};
        endcase
    end
end

raiz_cuadrada instancia_raiz ( 
    .reiniciar(reiniciar),
    .reloj(reloj),
    .iniciar(iniciar_operacion),
    .terminado(operacion_terminada),
    .resultado(resultado_raiz),
    .valor_entrada(registro_valor)
);

endmodule