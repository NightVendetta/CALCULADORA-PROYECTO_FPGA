`timescale 1ns / 1ps
`define SIMULATION
module div_TB;
    reg  clock;
    reg  rst;
    reg  comenzar;
    reg  [15:0] dividendo;
    reg  [15:0] divisor;
    wire [31:0] cociente;
    wire finalizado;

    div uut (
        .clock(clock),
        .rst(rst),
        .comenzar(comenzar),
        .dividendo(dividendo),
        .divisor(divisor),
        .cociente(cociente),
        .finalizado(finalizado)
    );

    parameter PERIODO = 20;
    
    initial begin
        clock = 0;
        rst = 0;
        comenzar = 0;
        dividendo = 16'h03E8;  // 1000 decimal
        divisor = 16'h0019;    // 25 decimal
    end
    
    initial clock <= 0;
    always #(PERIODO/2) clock <= ~clock;

    initial begin
        @ (negedge clock);
        rst = 1;
        @ (negedge clock);
        rst = 0;
        #(PERIODO*4)
        comenzar = 0;
        @ (posedge clock);
        comenzar = 1;
        #(PERIODO*2)
        comenzar = 0;
        #(PERIODO*60);
    end
     
    initial begin: CASO_PRUEBA
        $dumpfile("div_TB.vcd");
        $dumpvars(-1, div_TB);
        #(PERIODO*100) $finish;
    end

endmodule