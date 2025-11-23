module lsr2(clk, rst_ld, shift, lda2, in_R1, in_R2, out_R);
    input clk, rst_ld, shift, lda2;
    input [15:0] in_R1, in_R2;
    output [15:0] out_R;
    reg [31:0] datos;
    assign out_R = datos[31:16];
    always @(negedge clk) begin
        if (rst_ld) datos <= {16'h0000, in_R1};
        else if (shift) datos <= {datos[29:0], 2'b00};
        else if (lda2) datos[31:16] <= in_R2;
    end
endmodule