module uart_controller(
    input clk,
    input reset_n,
    // UART interface
    input [7:0] rx_data,
    input rx_ready,
    output reg [7:0] tx_data,
    output reg tx_start,
    input tx_busy,
    // Calculator control interface
    output reg [15:0] operand_a,
    output reg [2:0] operation,
    output reg start,
    input [31:0] result,
    input result_ready,
    // Status
    output reg [7:0] status_leds
);
    
    reg [7:0] command_buffer [0:15];
    reg [3:0] buffer_index;
    reg [2:0] state;
    reg [31:0] result_buffer;
    
    parameter STATE_IDLE = 0;
    parameter STATE_READ_CMD = 1;
    parameter STATE_PARSE = 2;
    parameter STATE_EXECUTE = 3;
    parameter STATE_SEND_RESULT = 4;
    
    // Simple command parser for: MULT 123, DIV 456, SQRT 789, B2B 123, B2D 123
    always @(posedge clk) begin
        if (!reset_n) begin
            state <= STATE_IDLE;
            buffer_index <= 0;
            start <= 0;
            tx_start <= 0;
            operand_a <= 0;
            operation <= 0;
        end else begin
            case(state)
                STATE_IDLE: begin
                    if (rx_ready) begin
                        if (rx_data == 8'h0D || rx_data == 8'h0A) begin
                            // Ignore CR/LF
                        end else begin
                            command_buffer[0] <= rx_data;
                            buffer_index <= 1;
                            state <= STATE_READ_CMD;
                        end
                    end
                end
                
                STATE_READ_CMD: begin
                    if (rx_ready) begin
                        if (rx_data == 8'h0D || rx_data == 8'h0A) begin
                            // End of command
                            state <= STATE_PARSE;
                        end else if (rx_data == 8'h20) begin
                            // Space - start reading number
                            command_buffer[buffer_index] <= 0;
                            buffer_index <= buffer_index + 1;
                        end else begin
                            command_buffer[buffer_index] <= rx_data;
                            buffer_index <= buffer_index + 1;
                        end
                    end
                end
                
                STATE_PARSE: begin
                    // Simple command parsing
                    case(command_buffer[0])
                        "M", "m": begin // MULT
                            operation <= 3'b000;
                            operand_a <= ascii_to_number(1);
                        end
                        "D", "d": begin // DIV
                            operation <= 3'b001; 
                            operand_a <= ascii_to_number(1);
                        end
                        "S", "s": begin // SQRT
                            operation <= 3'b010;
                            operand_a <= ascii_to_number(1);
                        end
                        "B", "b": begin // BIN2BCD
                            operation <= 3'b011;
                            operand_a <= ascii_to_number(1);
                        end
                        "C", "c": begin // BCD2BIN
                            operation <= 3'b100;
                            operand_a <= ascii_to_number(1);
                        end
                        default: begin
                            // Unknown command
                            operation <= 3'b111;
                        end
                    endcase
                    state <= STATE_EXECUTE;
                end
                
                STATE_EXECUTE: begin
                    start <= 1;
                    if (result_ready) begin
                        start <= 0;
                        result_buffer <= result;
                        state <= STATE_SEND_RESULT;
                    end
                end
                
                STATE_SEND_RESULT: begin
                    // Send result back via UART
                    if (!tx_busy) begin
                        tx_data <= result_buffer[7:0]; // Send lower byte
                        tx_start <= 1;
                        state <= STATE_IDLE;
                    end
                end
            endcase
        end
    end
    
    function [15:0] ascii_to_number;
        input [3:0] start_index;
        integer i;
        reg [15:0] num;
        begin
            num = 0;
            for (i = start_index; i < buffer_index; i = i + 1) begin
                if (command_buffer[i] >= "0" && command_buffer[i] <= "9") begin
                    num = num * 10 + (command_buffer[i] - "0");
                end
            end
            ascii_to_number = num;
        end
    endfunction
    
    // Status LEDs
    always @(*) begin
        status_leds = {state, operation, result_ready, 1'b0};
    end
    
endmodule
