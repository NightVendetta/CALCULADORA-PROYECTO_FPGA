module uart #(
    parameter CLK_FREQ = 25_000_000,
    parameter BAUD_RATE = 115200
)(
    input clk,
    input reset_n,
    // UART physical interface
    input rx,
    output tx,
    // Transmit interface
    input [7:0] tx_data,
    input tx_start,
    output reg tx_busy,
    // Receive interface  
    output reg [7:0] rx_data,
    output reg rx_ready
);
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;
    
    // RX Logic
    reg [15:0] rx_counter = 0;
    reg [3:0] rx_bit_index = 0;
    reg rx_active = 0;
    reg [7:0] rx_shift_reg = 0;
    
    always @(posedge clk) begin
        if (!reset_n) begin
            rx_ready <= 0;
            rx_active <= 0;
            rx_counter <= 0;
            rx_bit_index <= 0;
        end else begin
            rx_ready <= 0;
            if (!rx_active) begin
                if (rx == 0) begin // Start bit detected
                    rx_active <= 1;
                    rx_counter <= BIT_PERIOD / 2;
                    rx_bit_index <= 0;
                end
            end else begin
                rx_counter <= rx_counter - 1;
                if (rx_counter == 0) begin
                    if (rx_bit_index < 8) begin
                        rx_shift_reg <= {rx, rx_shift_reg[7:1]};
                        rx_bit_index <= rx_bit_index + 1;
                        rx_counter <= BIT_PERIOD;
                    end else begin
                        // Stop bit
                        rx_active <= 0;
                        rx_ready <= 1;
                        rx_data <= rx_shift_reg;
                    end
                end
            end
        end
    end
    
    // TX Logic
    reg [15:0] tx_counter = 0;
    reg [3:0] tx_bit_index = 0;
    reg [7:0] tx_shift_reg = 0;
    reg tx_reg = 1;
    
    assign tx = tx_reg;
    
    always @(posedge clk) begin
        if (!reset_n) begin
            tx_busy <= 0;
            tx_reg <= 1;
        end else begin
            if (tx_start && !tx_busy) begin
                tx_busy <= 1;
                tx_shift_reg <= tx_data;
                tx_bit_index <= 0;
                tx_counter <= BIT_PERIOD;
                tx_reg <= 0; // Start bit
            end else if (tx_busy) begin
                tx_counter <= tx_counter - 1;
                if (tx_counter == 0) begin
                    if (tx_bit_index < 8) begin
                        tx_reg <= tx_shift_reg[0];
                        tx_shift_reg <= {1'b0, tx_shift_reg[7:1]};
                        tx_bit_index <= tx_bit_index + 1;
                        tx_counter <= BIT_PERIOD;
                    end else begin
                        tx_reg <= 1; // Stop bit
                        tx_busy <= 0;
                    end
                end
            end
        end
    end
    
endmodule
