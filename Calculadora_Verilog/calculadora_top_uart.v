module calculadora_top_uart(
    // === CLOCK AND RESET ===
    input clk,
    input reset_n,
    
    // === UART INTERFACE ===  
    input uart_rx,
    output uart_tx,
    
    // === DISPLAY OUTPUTS ===
    output [7:0] segment_cathodes,
    output [3:0] segment_anodes,
    
    // === STATUS LEDS ===
    output [7:0] leds
);

    // UART signals
    wire [7:0] uart_rx_data;
    wire uart_rx_ready;
    wire [7:0] uart_tx_data;
    wire uart_tx_start;
    wire uart_tx_busy;
    
    // Calculator control signals
    wire [15:0] calc_operand_a;
    wire [2:0] calc_operation;
    wire calc_start;
    wire [31:0] calc_result;
    wire calc_ready;
    
    // UART instance
    uart uart_inst (
        .clk(clk),
        .reset_n(reset_n),
        .rx(uart_rx),
        .tx(uart_tx),
        .tx_data(uart_tx_data),
        .tx_start(uart_tx_start),
        .tx_busy(uart_tx_busy),
        .rx_data(uart_rx_data),
        .rx_ready(uart_rx_ready)
    );
    
    // UART controller
    uart_controller uart_ctrl (
        .clk(clk),
        .reset_n(reset_n),
        .rx_data(uart_rx_data),
        .rx_ready(uart_rx_ready),
        .tx_data(uart_tx_data),
        .tx_start(uart_tx_start),
        .tx_busy(uart_tx_busy),
        .operand_a(calc_operand_a),
        .operation(calc_operation),
        .start(calc_start),
        .result(calc_result),
        .result_ready(calc_ready),
        .status_leds(leds)
    );
    
    // Calculator core (tu código existente)
    calculadora_core calc_core (
        .clk(clk),
        .reset_n(reset_n),
        .operand_a(calc_operand_a),
        .operation(calc_operation),
        .start(calc_start),
        .result(calc_result),
        .ready(calc_ready)
    );
    
    // Display controller (para mostrar resultados en displays físicos)
    display_controller display_ctrl (
        .clk(clk),
        .reset_n(reset_n),
        .bcd_value({12'b0, calc_result[7:0]}), // Mostrar byte bajo del resultado
        .cathodes(segment_cathodes),
        .anodes(segment_anodes)
    );

endmodule
