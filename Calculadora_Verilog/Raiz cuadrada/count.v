module count(clk, ld, dec, z);
    input clk, ld, dec;
    output reg z;
    reg [3:0] contador = 8;
    always @(negedge clk) begin
        if (ld) contador <= 8;
        else if (dec) contador <= contador - 1;
        z <= (contador == 0);
    end
endmodule