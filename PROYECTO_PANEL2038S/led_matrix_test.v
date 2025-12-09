
module led_matrix_test (
    input wire clk_25mhz,
    
    output wire LP_CLK,
    output wire LATCH,
    output wire NOE,
    output reg [2:0] RGB0,
    output reg [2:0] RGB1,
    output wire [4:0] ROW
);

parameter NUM_ROWS = 32;
parameter NUM_COLS = 64;
parameter BIT_DEPTH = 4;

wire rst_n;
wire clk_en;

// Contadores
reg [15:0] display_counter;
reg [7:0] col_counter;
reg [5:0] row_counter;
reg [2:0] bit_plane;
reg [3:0] le_pulse_count;
reg config_done;

// Señales de control de contadores desde FSM
wire col_counter_reset;
wire col_counter_inc;
wire row_counter_reset;
wire row_counter_inc;
wire bit_plane_reset;
wire bit_plane_inc;
wire display_counter_reset;
wire display_counter_inc;
wire le_pulse_count_reset;
wire le_pulse_count_inc;
wire config_done_set;

// Estado de FSM
wire [4:0] fsm_state;

// Memoria
wire [5:0] actual_col = col_counter[5:0];
wire [10:0] pixel_addr = {row_counter[4:0], actual_col};
wire [23:0] mem_data;
wire mem_rd;

// Bits extraídos
wire [7:0] pixel_r0_full = mem_data[23:16];
wire [7:0] pixel_g0_full = mem_data[15:8];
wire [7:0] pixel_b0_full = mem_data[7:0];

wire [3:0] pixel_r0 = pixel_r0_full[7:4];
wire [3:0] pixel_g0 = pixel_g0_full[7:4];
wire [3:0] pixel_b0 = pixel_b0_full[7:4];
wire [3:0] pixel_r1 = pixel_r0_full[3:0];
wire [3:0] pixel_g1 = pixel_g0_full[3:0];
wire [3:0] pixel_b1 = pixel_b0_full[3:0];

wire bit_r0 = pixel_r0[bit_plane];
wire bit_g0 = pixel_g0[bit_plane];
wire bit_b0 = pixel_b0[bit_plane];
wire bit_r1 = pixel_r1[bit_plane];
wire bit_g1 = pixel_g1[bit_plane];
wire bit_b1 = pixel_b1[bit_plane];

reg [7:0] rst_counter;
reg rst_n_reg;

always @(posedge clk_25mhz) begin
    if (rst_counter < 8'd255) begin
        rst_counter <= rst_counter + 1;
        rst_n_reg <= 0;
    end else begin
        rst_n_reg <= 1;
    end
end

assign rst_n = rst_n_reg;

reg [2:0] clk_div;
reg clk_en_reg;

always @(posedge clk_25mhz or negedge rst_n) begin
    if (!rst_n) begin
        clk_div <= 0;
        clk_en_reg <= 0;
    end else begin
        clk_div <= clk_div + 1;
        clk_en_reg <= (clk_div == 3'd0);
    end
end

assign clk_en = clk_en_reg;

// Instancia de memoria

memory #(
    .size(2047),
    .width(10)
) mem_single (
    .clk(clk_25mhz),
    .address(pixel_addr),
    .rd(mem_rd),
    .rdata(mem_data)
);


// Instancia de FSM

fsm_controller u_fsm (
    .clk(clk_25mhz),
    .rst_n(rst_n),
    .clk_en(clk_en),
    .col_counter(col_counter),
    .row_counter(row_counter),
    .bit_plane(bit_plane),
    .display_counter(display_counter),
    .le_pulse_count(le_pulse_count),
    .config_done(config_done),
    .NUM_COLS(NUM_COLS),
    .NUM_ROWS(NUM_ROWS),
    .LP_CLK(LP_CLK),
    .LATCH(LATCH),
    .NOE(NOE),
    .mem_rd(mem_rd),
    .ROW(ROW),
    .col_counter_reset(col_counter_reset),
    .col_counter_inc(col_counter_inc),
    .row_counter_reset(row_counter_reset),
    .row_counter_inc(row_counter_inc),
    .bit_plane_reset(bit_plane_reset),
    .bit_plane_inc(bit_plane_inc),
    .display_counter_reset(display_counter_reset),
    .display_counter_inc(display_counter_inc),
    .le_pulse_count_reset(le_pulse_count_reset),
    .le_pulse_count_inc(le_pulse_count_inc),
    .config_done_set(config_done_set),
    .state(fsm_state)
);

// Contadores
always @(posedge clk_25mhz or negedge rst_n) begin
    if (!rst_n) begin
        col_counter <= 0;
        row_counter <= 0;
        bit_plane <= 0;
        display_counter <= 0;
        le_pulse_count <= 0;
        config_done <= 0;
    end else if (clk_en) begin
        // col_counter
        if (col_counter_reset)
            col_counter <= 0;
        else if (col_counter_inc)
            col_counter <= col_counter + 1;
        
        // row_counter
        if (row_counter_reset)
            row_counter <= 0;
        else if (row_counter_inc)
            row_counter <= row_counter + 1;
        
        // bit_plane
        if (bit_plane_reset)
            bit_plane <= 0;
        else if (bit_plane_inc)
            bit_plane <= bit_plane + 1;
        
        // display_counter
        if (display_counter_reset)
            display_counter <= 0;
        else if (display_counter_inc)
            display_counter <= display_counter + 1;
        
        // le_pulse_count
        if (le_pulse_count_reset)
            le_pulse_count <= 0;
        else if (le_pulse_count_inc)
            le_pulse_count <= le_pulse_count + 1;
        
        // config_done
        if (config_done_set)
            config_done <= 1;
    end
end

//  RGB
always @(posedge clk_25mhz or negedge rst_n) begin
    if (!rst_n) begin
        RGB0 <= 3'b000;
        RGB1 <= 3'b000;
    end else if (clk_en) begin
        // Solo cargar datos en SHIFT_DATA cuando LP_CLK == 0
        if (fsm_state == 5'd5 && LP_CLK == 0) begin  // SHIFT_DATA
            RGB0[0] <= bit_r0;
            RGB0[1] <= bit_g0;
            RGB0[2] <= bit_b0;
            RGB1[0] <= bit_r1;
            RGB1[1] <= bit_g1;
            RGB1[2] <= bit_b1;
        end else if (fsm_state == 5'd0 || fsm_state == 5'd1 || fsm_state == 5'd2) begin
            // INIT, CONFIG_REG1, CONFIG_REG2
            RGB0 <= 3'b000;
            RGB1 <= 3'b000;
        end else if (fsm_state != 5'd5) begin
            // Otros estados
            RGB0 <= 3'b000;
            RGB1 <= 3'b000;
        end
    end
end

endmodule
