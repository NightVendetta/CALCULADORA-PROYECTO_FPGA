
module top (
    input wire clk,
    output wire LP_CLK,
    output wire LATCH,
    output wire NOE,
    output wire [4:0] ROW,
    output wire [2:0] RGB0,
    output wire [2:0] RGB1
);

led_matrix_test u_controller (
    .clk_25mhz(clk),
    .LP_CLK(LP_CLK),
    .LATCH(LATCH),
    .NOE(NOE),
    .RGB0(RGB0),
    .RGB1(RGB1),
    .ROW(ROW)
);

endmodule
