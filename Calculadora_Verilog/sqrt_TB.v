`timescale 1ns / 1ps
module sqrt_TB;
    reg clk, rst, start;
    reg [15:0] A;
    wire [15:0] result;
    wire done;

    sqrt uut(clk, rst, start, A, result, done);

    parameter PERIOD = 20;
    initial begin
        clk = 0;
        forever #(PERIOD/2) clk = ~clk;
    end

    initial begin
        rst = 0; start = 0; A = 16'h00E1;
        @(negedge clk); rst = 1;
        @(negedge clk); rst = 0;
        #(PERIOD*4);
        @(posedge clk); start = 1;
        @(posedge clk); start = 0;
        #(PERIOD*100);
        $finish;
    end

    initial begin
        $dumpfile("sqrt_TB.vcd");
        $dumpvars(0, sqrt_TB);
    end
endmodule