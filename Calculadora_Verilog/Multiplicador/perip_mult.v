module peripheral_mult(
    input clock,
    input rst,
    input [15:0] d_in,
    input cs,
    input [4:0] addr, // 4 LSB from j1_io_addr
    input rd,
    input wr,
    output reg [31:0] d_out
);

//------------------------------------ registros y cables ----------------------------
reg [4:0] selector;     // selector del multiplexor y registros de escritura
reg [15:0] reg_A;       // registros de entrada para el multiplicador
reg [15:0] reg_B;
reg iniciar;
wire [31:0] producto;   // salida del multiplicador
wire operacion_completada;

//------------------------------------ decodificador de direcciones -------------------
always @(*) begin
    if (cs) begin
        case (addr)
            5'h04: selector = 5'b00001; // dirección para registro A
            5'h08: selector = 5'b00010; // dirección para registro B  
            5'h0C: selector = 5'b00100; // dirección para señal de inicio
            5'h10: selector = 5'b01000; // dirección para leer resultado
            5'h14: selector = 5'b10000; // dirección para leer estado
            default: selector = 5'b00000;
        endcase
    end
    else 
        selector = 5'b00000;
end

//------------------------------------ escritura de registros ------------------------
always @(posedge clock) begin
    if (rst) begin
        iniciar <= 0;
        reg_A   <= 0;
        reg_B   <= 0;
    end
    else begin
        if (cs && wr) begin
            reg_A   <= selector[0] ? d_in : reg_A;
            reg_B   <= selector[1] ? d_in : reg_B;
            iniciar <= selector[2] ? d_in[0] : iniciar;
        end
    end
end

//------------------------------------ multiplexor de salidas ------------------------
always @(posedge clock) begin
    if (rst)
        d_out <= 0;
    else if (cs) begin
        case (selector[4:0])
            5'b01000: d_out <= producto;
            5'b10000: d_out <= {31'b0, operacion_completada};
        endcase
    end
end

//------------------------------------ instancia del multiplicador -------------------
mult multiplicador_instancia ( 
    .rst(rst),
    .clock(clock),
    .start(iniciar),
    .completed(operacion_completada),
    .product(producto),
    .operand_A(reg_A),
    .operand_B(reg_B)
);

endmodule
