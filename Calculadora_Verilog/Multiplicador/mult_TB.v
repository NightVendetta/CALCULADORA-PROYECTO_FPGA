`timescale 1ns / 1ps
`define SIMULATION
module mult_TB;
    reg  clock;
    reg  rst;
    reg  start;
    reg  [15:0] operand_A;
    reg  [15:0] operand_B;
    wire [31:0] product;
    wire completed;

    mult uut (
        .clock(clock),
        .rst(rst),
        .start(start),
        .operand_A(operand_A),
        .operand_B(operand_B),
        .product(product),
        .completed(completed)
    );

    parameter CLK_PERIOD = 20;
    
    initial begin
        clock = 0; rst = 0; start = 0; 
        operand_A = 16'h005B;  // 91 en decimal (0x5B = 91)
        operand_B = 16'h000C;  // 12 en decimal (0x0C = 12)
    end
    
    // Generación de reloj
    initial clock <= 0;
    always #(CLK_PERIOD/2) clock <= ~clock;

    initial begin // Reset del sistema, iniciar proceso de multiplicación
        // Reset 
        @ (negedge clock);
        rst = 1;
        @ (negedge clock);
        rst = 0;
        #(CLK_PERIOD*4)
        start = 0;
        @ (posedge clock);
        start = 1;
        #(CLK_PERIOD*2)
        start = 0;
        #(CLK_PERIOD*50);
    end
     
    initial begin: TEST_CASE
        $dumpfile("mult_TB.vcd");
        $dumpvars(-1, mult_TB);
        #(CLK_PERIOD*50) $finish;
    end

endmodule
