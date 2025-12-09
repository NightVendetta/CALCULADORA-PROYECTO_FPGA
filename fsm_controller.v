

module fsm_controller (
    input wire clk,
    input wire rst_n,
    input wire clk_en,
    
    // Entradas de estado
    input wire [7:0] col_counter,
    input wire [5:0] row_counter,
    input wire [2:0] bit_plane,
    input wire [15:0] display_counter,
    input wire [3:0] le_pulse_count,
    input wire config_done,
    
    // Parámetros
    input wire [7:0] NUM_COLS,
    input wire [5:0] NUM_ROWS,
    
    // Salidas de control
    output reg LP_CLK,
    output reg LATCH,
    output reg NOE,
    output reg mem_rd,
    output reg [4:0] ROW,
    output reg col_counter_reset,
    output reg col_counter_inc,
    output reg row_counter_reset,
    output reg row_counter_inc,
    output reg bit_plane_reset,
    output reg bit_plane_inc,
    output reg display_counter_reset,
    output reg display_counter_inc,
    output reg le_pulse_count_reset,
    output reg le_pulse_count_inc,
    output reg config_done_set,
    output reg [4:0] state
);

    localparam INIT          = 5'd0;
    localparam CONFIG_REG1   = 5'd1;
    localparam CONFIG_REG2   = 5'd2;
    localparam IDLE          = 5'd3;
    localparam LOAD_ROW      = 5'd4;
    localparam SHIFT_DATA    = 5'd5;
    localparam DATA_LATCH    = 5'd6;
    localparam DISPLAY       = 5'd7;
    localparam NEXT_BIT      = 5'd8;
    localparam NEXT_ROW      = 5'd9;

    // Máquina de estados
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= INIT;
            LP_CLK <= 0;
            LATCH <= 0;
            NOE <= 1;
            ROW <= 5'b00000;
            mem_rd <= 0;
            col_counter_reset <= 0;
            col_counter_inc <= 0;
            row_counter_reset <= 0;
            row_counter_inc <= 0;
            bit_plane_reset <= 0;
            bit_plane_inc <= 0;
            display_counter_reset <= 0;
            display_counter_inc <= 0;
            le_pulse_count_reset <= 0;
            le_pulse_count_inc <= 0;
            config_done_set <= 0;
            
        end else if (clk_en) begin
            // Valores por defecto (para evitar latches)
            col_counter_reset <= 0;
            col_counter_inc <= 0;
            row_counter_reset <= 0;
            row_counter_inc <= 0;
            bit_plane_reset <= 0;
            bit_plane_inc <= 0;
            display_counter_reset <= 0;
            display_counter_inc <= 0;
            le_pulse_count_reset <= 0;
            le_pulse_count_inc <= 0;
            config_done_set <= 0;
            
            case (state)
                
                INIT: begin
                    NOE <= 1;
                    LP_CLK <= 0;
                    LATCH <= 0;
                    le_pulse_count_reset <= 1;
                    
                    if (!config_done) begin
                        state <= CONFIG_REG1;
                    end else begin
                        state <= IDLE;
                    end
                end
                
                CONFIG_REG1: begin
                    if (le_pulse_count < 11) begin
                        LP_CLK <= ~LP_CLK;
                        LATCH <= 1;
                        
                        if (LP_CLK) begin
                            le_pulse_count_inc <= 1;
                        end
                    end else begin
                        LATCH <= 0;
                        LP_CLK <= 0;
                        le_pulse_count_reset <= 1;
                        state <= CONFIG_REG2;
                    end
                end
                
                CONFIG_REG2: begin
                    if (le_pulse_count < 12) begin
                        LP_CLK <= ~LP_CLK;
                        LATCH <= 1;
                        
                        if (LP_CLK) begin
                            le_pulse_count_inc <= 1;
                        end
                    end else begin
                        LATCH <= 0;
                        LP_CLK <= 0;
                        le_pulse_count_reset <= 1;
                        config_done_set <= 1;
                        state <= IDLE;
                    end
                end
                
                IDLE: begin
                    NOE <= 1;
                    LP_CLK <= 0;
                    LATCH <= 0;
                    col_counter_reset <= 1;
                    mem_rd <= 1;
                    state <= LOAD_ROW;
                end
                
                LOAD_ROW: begin
                    mem_rd <= 1;
                    ROW <= row_counter[4:0];
                    col_counter_reset <= 1;
                    state <= SHIFT_DATA;
                end
                
                SHIFT_DATA: begin
                    if (col_counter < NUM_COLS) begin
                        LP_CLK <= ~LP_CLK;
                        
                        if (LP_CLK) begin
                            col_counter_inc <= 1;
                        end
                        
                    end else begin
                        LP_CLK <= 0;
                        mem_rd <= 0;
                        le_pulse_count_reset <= 1;
                        state <= DATA_LATCH;
                    end
                end
                
                DATA_LATCH: begin
                    if (le_pulse_count < 3) begin
                        LP_CLK <= ~LP_CLK;
                        LATCH <= 1;
                        
                        if (LP_CLK) begin
                            le_pulse_count_inc <= 1;
                        end
                    end else begin
                        LATCH <= 0;
                        LP_CLK <= 0;
                        le_pulse_count_reset <= 1;
                        display_counter_reset <= 1;
                        state <= DISPLAY;
                    end
                end
                
                DISPLAY: begin
                    NOE <= 0;
                    LATCH <= 0;
                    LP_CLK <= 0;
                    display_counter_inc <= 1;
                    
                    case (bit_plane)
                        3'd0: if (display_counter >= 16'd12)   state <= NEXT_BIT;
                        3'd1: if (display_counter >= 16'd25)   state <= NEXT_BIT;
                        3'd2: if (display_counter >= 16'd50)   state <= NEXT_BIT;
                        3'd3: if (display_counter >= 16'd100)  state <= NEXT_BIT;
                        default: state <= NEXT_BIT;
                    endcase
                end
                
                NEXT_BIT: begin
                    NOE <= 1;
                    
                    if (bit_plane >= 3) begin
                        bit_plane_reset <= 1;
                        state <= NEXT_ROW;
                    end else begin
                        bit_plane_inc <= 1;
                        state <= IDLE;
                    end
                end
                
                NEXT_ROW: begin
                    if (row_counter >= (NUM_ROWS - 1)) begin
                        row_counter_reset <= 1;
                    end else begin
                        row_counter_inc <= 1;
                    end
                    state <= IDLE;
                end
                
                default: state <= INIT;
            endcase
        end
    end

endmodule
