module lsr(clk, reset, shift, load, load_R0, in_bit, in_A, out_r);
    input clk, reset, shift, load, load_R0, in_bit;
    input [15:0] in_A;
    output reg [15:0] out_r;
    always @(negedge clk) begin
        if (reset) out_r <= 0;
        else if (load) out_r <= in_A;
        else if (shift) out_r <= {out_r[14:0], 1'b0};
        else if (load_R0) out_r <= {out_r[15:1], in_bit};
    end
endmodule