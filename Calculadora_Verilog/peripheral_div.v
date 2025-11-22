module peripheral_div(
    input clock,
    input rst,
    input [15:0] entrada_datos,
    input habilitar,
    input [4:0] direccion,
    input leer,
    input escribir,
    output reg [31:0] salida_datos
);

reg [4:0] selector;
reg [15:0] reg_dividendo;
reg [15:0] reg_divisor;
reg iniciar_operacion;
wire [31:0] resultado_division;
wire operacion_finalizada;

always @(*) begin
    if (habilitar) begin
        case (direccion)
            5'h04: selector = 5'b00001;
            5'h08: selector = 5'b00010;
            5'h0C: selector = 5'b00100;
            5'h10: selector = 5'b01000;
            5'h14: selector = 5'b10000;
            default: selector = 5'b00000;
        endcase
    end
    else 
        selector = 5'b00000;
end

always @(posedge clock) begin
    if (rst) begin
        iniciar_operacion <= 0;
        reg_dividendo     <= 0;
        reg_divisor       <= 0;
    end
    else begin
        if (habilitar && escribir) begin
            reg_dividendo     <= selector[0] ? entrada_datos : reg_dividendo;
            reg_divisor       <= selector[1] ? entrada_datos : reg_divisor;
            iniciar_operacion <= selector[2] ? entrada_datos[0] : iniciar_operacion;
        end
    end
end

always @(posedge clock) begin
    if (rst)
        salida_datos <= 0;
    else if (habilitar) begin
        case (selector[4:0])
            5'b01000: salida_datos <= resultado_division;
            5'b10000: salida_datos <= {31'b0, operacion_finalizada};
        endcase
    end
end

div instancia_divisor ( 
    .rst(rst),
    .clock(clock),
    .comenzar(iniciar_operacion),
    .finalizado(operacion_finalizada),
    .cociente(resultado_division),
    .dividendo(reg_dividendo),
    .divisor(reg_divisor)
);

endmodule