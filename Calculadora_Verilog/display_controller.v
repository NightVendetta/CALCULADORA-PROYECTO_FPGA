module display_controller(
    input clk,
    input reset_n,
    input [19:0] bcd_value,
    output reg [7:0] cathodes,
    output reg [3:0] anodes
);

    reg [1:0] digit_select;
    reg [3:0] current_digit;
    reg [15:0] refresh_counter;
    
    // Multiplexación de displays
    always @(posedge clk) begin
        if (!reset_n) begin
            refresh_counter <= 0;
            digit_select <= 0;
        end else begin
            refresh_counter <= refresh_counter + 1;
            if (refresh_counter == 16'hFFFF) begin
                digit_select <= digit_select + 1;
            end
        end
    end
    
    // Selección de dígito actual
    always @(*) begin
        case(digit_select)
            2'b00: current_digit = bcd_value[3:0];    // Unidades
            2'b01: current_digit = bcd_value[7:4];    // Decenas
            2'b10: current_digit = bcd_value[11:8];   // Centenas
            2'b11: current_digit = bcd_value[15:12];  // Millares
        endcase
    end
    
    // Activación de ánodos
    always @(*) begin
        case(digit_select)
            2'b00: anodes = 4'b1110;
            2'b01: anodes = 4'b1101;
            2'b10: anodes = 4'b1011;
            2'b11: anodes = 4'b0111;
        endcase
    end
    
    // Decodificador BCD a 7 segmentos (cátodos activos en bajo)
    always @(*) begin
        case(current_digit)
            4'h0: cathodes = 8'b00000011;  // 0
            4'h1: cathodes = 8'b10011111;  // 1
            4'h2: cathodes = 8'b00100101;  // 2
            4'h3: cathodes = 8'b00001101;  // 3
            4'h4: cathodes = 8'b10011001;  // 4
            4'h5: cathodes = 8'b01001001;  // 5
            4'h6: cathodes = 8'b01000001;  // 6
            4'h7: cathodes = 8'b00011111;  // 7
            4'h8: cathodes = 8'b00000001;  // 8
            4'h9: cathodes = 8'b00001001;  // 9
            default: cathodes = 8'b11111111; // Apagado
        endcase
    end

endmodule