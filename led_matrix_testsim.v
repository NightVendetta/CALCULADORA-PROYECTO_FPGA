// ============================================================================
// ICN2038S LED Matrix Controller - VERSIÓN FUNCIONAL PARA SIMULACIÓN
// ============================================================================

module led_matrix_testsim (
    input wire clk_25mhz,
    output reg LP_CLK,
    output reg LATCH,
    output reg NOE,
    output reg [2:0] RGB0,
    output reg [2:0] RGB1,
    output reg [4:0] ROW
);

// ============================================================================
// Parámetros
// ============================================================================
parameter NUM_ROWS = 32;
parameter NUM_COLS = 64;
parameter BIT_DEPTH = 4;

// Estados principales
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

reg [4:0] state = INIT;

// Contadores - TODOS INICIALIZADOS
reg [15:0] display_counter = 0;
reg [7:0] col_counter = 0;
reg [5:0] row_counter = 0;
reg [2:0] bit_plane = 0;
reg [3:0] le_pulse_count = 0;

// Reset y clock enable - TODOS INICIALIZADOS
reg rst_n = 0;
reg [7:0] rst_counter = 0;
reg clk_en = 0;
reg [2:0] clk_div = 0;

// Flags - TODOS INICIALIZADOS
reg config_done = 0;

// ============================================================================
// Memoria de imagen
// ============================================================================
wire [5:0] actual_col = col_counter[5:0];
wire [10:0] pixel_addr = {row_counter[4:0], actual_col};  // 0-2047

wire [23:0] mem_data;
reg mem_rd = 0;

// UNA sola instancia de memoria
memory #(
    .size(2047),
    .width(10)
) mem_single (
    .clk(clk_25mhz),
    .address(pixel_addr),
    .rd(mem_rd),
    .rdata(mem_data)
);

// ============================================================================
// Extracción de datos
// ============================================================================
wire [7:0] pixel_r0_full = mem_data[23:16];
wire [7:0] pixel_g0_full = mem_data[15:8];
wire [7:0] pixel_b0_full = mem_data[7:0];

// Convertir a 4 bits (tomar bits superiores)
wire [3:0] pixel_r0 = pixel_r0_full[7:4];
wire [3:0] pixel_g0 = pixel_g0_full[7:4];
wire [3:0] pixel_b0 = pixel_b0_full[7:4];

// Para RGB1, usar los bits inferiores
wire [3:0] pixel_r1 = pixel_r0_full[3:0];
wire [3:0] pixel_g1 = pixel_g0_full[3:0];
wire [3:0] pixel_b1 = pixel_b0_full[3:0];

// Seleccionar bit según bit_plane
wire bit_r0 = pixel_r0[bit_plane];
wire bit_g0 = pixel_g0[bit_plane];
wire bit_b0 = pixel_b0[bit_plane];
wire bit_r1 = pixel_r1[bit_plane];
wire bit_g1 = pixel_g1[bit_plane];
wire bit_b1 = pixel_b1[bit_plane];

// ============================================================================
// Reset interno
// ============================================================================
always @(posedge clk_25mhz) begin
    if (rst_counter < 8'd255) begin
        rst_counter <= rst_counter + 1;
        rst_n <= 0;
    end else begin
        rst_n <= 1;
    end
end

// ============================================================================
// Clock divider
// ============================================================================
always @(posedge clk_25mhz) begin
    clk_div <= clk_div + 1;
    clk_en <= (clk_div == 3'd0);
end

// ============================================================================
// Máquina de estados principal - CORREGIDA
// ============================================================================
always @(posedge clk_25mhz) begin
    if (!rst_n) begin
        state <= INIT;
        LP_CLK <= 0;
        LATCH <= 0;
        NOE <= 1;
        RGB0 <= 3'b000;
        RGB1 <= 3'b000;
        ROW <= 5'b00000;
        col_counter <= 0;
        row_counter <= 0;
        bit_plane <= 0;
        display_counter <= 0;
        le_pulse_count <= 0;
        mem_rd <= 0;
        config_done <= 0;
    end else if (clk_en) begin
        // Reset de señales por defecto
        LP_CLK <= 0;
        LATCH <= 0;
        NOE <= 1;
        RGB0 <= 3'b000;
        RGB1 <= 3'b000;
        
        case (state)
            INIT: begin
                state <= config_done ? IDLE : CONFIG_REG1;
            end
            
            CONFIG_REG1: begin
                if (le_pulse_count < 11) begin
                    LP_CLK <= ~LP_CLK;
                    LATCH <= 1;
                    
                    if (LP_CLK) begin
                        RGB0 <= 3'b000;
                        RGB1 <= 3'b000;
                        le_pulse_count <= le_pulse_count + 1;
                    end
                end else begin
                    LATCH <= 0;
                    LP_CLK <= 0;
                    le_pulse_count <= 0;
                    state <= CONFIG_REG2;
                end
            end
            
            CONFIG_REG2: begin
                if (le_pulse_count < 12) begin
                    LP_CLK <= ~LP_CLK;
                    LATCH <= 1;
                    
                    if (LP_CLK) begin
                        RGB0 <= 3'b000;
                        RGB1 <= 3'b000;
                        le_pulse_count <= le_pulse_count + 1;
                    end
                end else begin
                    LATCH <= 0;
                    LP_CLK <= 0;
                    le_pulse_count <= 0;
                    config_done <= 1;
                    state <= IDLE;
                end
            end
            
            IDLE: begin
                mem_rd <= 1;
                state <= LOAD_ROW;
            end
            
            LOAD_ROW: begin
                mem_rd <= 1;
                ROW <= row_counter[4:0];
                col_counter <= 0;
                state <= SHIFT_DATA;
            end
            
            SHIFT_DATA: begin
                if (col_counter < NUM_COLS) begin
                    LP_CLK <= ~LP_CLK;
                    
                    if (LP_CLK == 0) begin
                        // Enviar datos a RGB0 y RGB1
                        RGB0[0] <= bit_r0;
                        RGB0[1] <= bit_g0;
                        RGB0[2] <= bit_b0;
                        RGB1[0] <= bit_r1;
                        RGB1[1] <= bit_g1;
                        RGB1[2] <= bit_b1;
                    end else begin
                        col_counter <= col_counter + 1;
                    end
                end else begin
                    LP_CLK <= 0;
                    RGB0 <= 3'b000;
                    RGB1 <= 3'b000;
                    mem_rd <= 0;
                    le_pulse_count <= 0;
                    state <= DATA_LATCH;
                end
            end
            
            DATA_LATCH: begin
                if (le_pulse_count < 3) begin
                    LP_CLK <= ~LP_CLK;
                    LATCH <= 1;
                    
                    if (LP_CLK) begin
                        le_pulse_count <= le_pulse_count + 1;
                    end
                end else begin
                    LATCH <= 0;
                    LP_CLK <= 0;
                    le_pulse_count <= 0;
                    display_counter <= 0;
                    state <= DISPLAY;
                end
            end
            
            DISPLAY: begin
                NOE <= 0;
                display_counter <= display_counter + 1;
                
                case (bit_plane)
                    3'd0: if (display_counter >= 16'd50)   state <= NEXT_BIT;
                    3'd1: if (display_counter >= 16'd100)  state <= NEXT_BIT;
                    3'd2: if (display_counter >= 16'd200)  state <= NEXT_BIT;
                    3'd3: if (display_counter >= 16'd400)  state <= NEXT_BIT;
                    default: state <= NEXT_BIT;
                endcase
            end
            
            NEXT_BIT: begin
                NOE <= 1;
                
                if (bit_plane >= 3) begin
                    bit_plane <= 0;
                    state <= NEXT_ROW;
                end else begin
                    bit_plane <= bit_plane + 1;
                    state <= IDLE;
                end
            end
            
            NEXT_ROW: begin
                if (row_counter >= (NUM_ROWS - 1)) begin
                    row_counter <= 0;
                end else begin
                    row_counter <= row_counter + 1;
                end
                state <= IDLE;
            end
            
            default: state <= INIT;
        endcase
    end
end

endmodule

// ============================================================================
// Módulo de memoria
// ============================================================================
module memory #(
    parameter size = 2047,
    parameter width = 10
)(
    input clk,
    input [width:0] address,
    input rd,
    output reg [23:0] rdata
);

reg [23:0] MEM [0:size];

initial begin
    $readmemh("image.hex", MEM);
end

always @(negedge clk) begin
    if (rd) begin
        rdata <= MEM[address];
    end
end

endmodule