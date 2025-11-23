module calculadora_top(
    // === ENTRADAS PRINCIPALES ===
    input clk,                    // Reloj de la FPGA
    input reset_n,                // Reset (activo en bajo)
    
    // === ENTRADAS DE USUARIO ===
    input [15:0] switch_data,     // Datos desde switches
    input [2:0]  op_select,       // Selector de operación
    input        execute_btn,     // Botón de ejecutar
    
    // === SALIDAS A DISPLAYS ===
    output [7:0] segment_cathodes, // Segmentos del display
    output [3:0] segment_anodes,   // Dígitos seleccionados
    
    // === SALIDAS A LEDs ===
    output [7:0] leds             // LEDs de estado
);

    // === SEÑALES INTERNAS ===
    wire [31:0] operation_result;
    wire operation_done;
    wire [19:0] bcd_result;
    
    // === MÁQUINA DE ESTADOS ===
    reg [2:0] current_state;
    parameter IDLE      = 3'b000;
    parameter OPERATING = 3'b001;
    parameter DISPLAY   = 3'b010;

    // === INSTANCIA DEL NÚCLEO DE LA CALCULADORA ===
    calculadora_core calc_core (
        .clk(clk),
        .reset_n(reset_n),
        .operand_a(switch_data),
        .operation(op_select),
        .start(execute_btn && (current_state == IDLE)),
        .result(operation_result),
        .ready(operation_done)
    );

    // === CONVERSIÓN PARA DISPLAY ===
    binary_to_bcd display_converter (
        .clock(clk),
        .reset(!reset_n),
        .start(operation_done && (current_state == OPERATING)),
        .binary_input(operation_result[15:0]),
        .bcd_output(bcd_result),
        .conversion_done()
    );

    // === CONTROLADOR DE DISPLAY ===
    display_controller display_ctrl (
        .clk(clk),
        .reset_n(reset_n),
        .bcd_value(bcd_result),
        .cathodes(segment_cathodes),
        .anodes(segment_anodes)
    );

    // === LÓGICA DE CONTROL ===
    always @(posedge clk) begin
        if (!reset_n) begin
            current_state <= IDLE;
        end else begin
            case(current_state)
                IDLE: begin
                    if (execute_btn) 
                        current_state <= OPERATING;
                end
                OPERATING: begin
                    if (operation_done)
                        current_state <= DISPLAY;
                end
                DISPLAY: begin
                    if (execute_btn)
                        current_state <= IDLE;
                end
            endcase
        end
    end

    // === LEDs DE ESTADO ===
    assign leds = {operation_done, op_select, current_state};

endmodule