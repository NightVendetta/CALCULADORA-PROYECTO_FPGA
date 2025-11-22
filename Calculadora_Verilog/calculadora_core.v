module calculadora_core(
    input clk,
    input reset_n,
    input [15:0] operand_a,
    input [2:0] operation,
    input start,
    output reg [31:0] result,
    output reg ready
);

    // === SEÑALES DE CADA MÓDULO ===
    wire [31:0] mult_result, div_result, sqrt_result;
    wire [19:0] bin2bcd_result;
    wire [15:0] bcd2bin_result;
    wire mult_done, div_done, sqrt_done, bin2bcd_done, bcd2bin_done;
    
    // === OPERANDO B FIJO PARA MULTIPLICACIÓN/DIVISIÓN ===
    wire [15:0] operand_b = 16'h0002;  // Puede ajustarse

    // === INSTANCIAS DE TODOS LOS MÓDULOS ===

    // Multiplicación
    mult multiplicador (
        .rst(!reset_n),
        .clock(clk),
        .start(start && (operation == 3'b000)),
        .completed(mult_done),
        .product(mult_result),
        .operand_A(operand_a),
        .operand_B(operand_b)
    );

    // División
    div divisor (
        .rst(!reset_n),
        .clock(clk),
        .comenzar(start && (operation == 3'b001)),
        .finalizado(div_done),
        .cociente(div_result),
        .dividendo(operand_a),
        .divisor(operand_b)
    );

    // Raíz cuadrada
    sqrt raiz_cuadrada (
        .clk(clk),
        .rst(!reset_n),
        .init(start && (operation == 3'b010)),
        .A(operand_a),
        .result(sqrt_result[15:0]),
        .done(sqrt_done)
    );

    // Binario a BCD
    binary_to_bcd conversor_bcd (
        .clock(clk),
        .reset(!reset_n),
        .start(start && (operation == 3'b011)),
        .binary_input(operand_a),
        .bcd_output(bin2bcd_result),
        .conversion_done(bin2bcd_done)
    );

    // BCD a Binario
    convertidor_bcd_binario conversor_bin (
        .reloj(clk),
        .reset(!reset_n),
        .inicio(start && (operation == 3'b100)),
        .entrada_bcd({4'b0, operand_a}),  // Ajuste para entrada de 16 bits
        .resultado_bin(bcd2bin_result),
        .terminado(bcd2bin_done)
    );

    // === SELECCIÓN DE RESULTADO ===
    always @(*) begin
        case(operation)
            3'b000: begin
                result = mult_result;
                ready = mult_done;
            end
            3'b001: begin
                result = div_result;
                ready = div_done;
            end
            3'b010: begin
                result = {16'b0, sqrt_result[15:0]};
                ready = sqrt_done;
            end
            3'b011: begin
                result = {12'b0, bin2bcd_result};
                ready = bin2bcd_done;
            end
            3'b100: begin
                result = {16'b0, bcd2bin_result};
                ready = bcd2bin_done;
            end
            default: begin
                result = 32'b0;
                ready = 1'b0;
            end
        endcase
    end

endmodule