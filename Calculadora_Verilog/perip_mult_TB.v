`timescale 1ns / 1ps

`define SIMULATION
module peripheral_mult_TB;
    reg clock;
    reg rst;
    reg [15:0] data_in;
    reg chip_select;
    reg [4:0] direccion;
    reg read;
    reg write;
    wire [31:0] data_out;

    peripheral_mult uut (
        .clock(clock),
        .rst(rst),
        .d_in(data_in),
        .cs(chip_select),
        .addr(direccion),
        .rd(read),
        .wr(write),
        .d_out(data_out)
    );

    parameter CLK_PERIOD = 20;
    
    // Inicializar entradas
    initial begin  
        clock = 0;
        rst = 0;
        data_in = 0;
        direccion = 5'h00;
        chip_select = 0;
        read = 0;
        write = 0;
    end
    
    // Generación de reloj
    initial clock <= 0;
    always #(CLK_PERIOD/2) clock <= ~clock;

    initial begin 
        forever begin
            // Reset del sistema
            @ (negedge clock);
            rst = 1;
            @ (negedge clock);
            rst = 0;
            #(CLK_PERIOD*4)
            
            // Escribir operando A
            chip_select = 1;
            read = 0;
            write = 1;
            data_in = 16'h005B;
            direccion = 5'h04;
            #(CLK_PERIOD)
            chip_select = 0;
            read = 0;
            write = 0;
            #(CLK_PERIOD*3)
            
            // Escribir operando B
            chip_select = 1;
            read = 0;
            write = 1;
            data_in = 16'h000C;
            direccion = 5'h08;
            #(CLK_PERIOD)
            chip_select = 0;
            read = 0;
            write = 0;
            #(CLK_PERIOD*3)
            
            // Señal de inicio
            chip_select = 1;
            read = 0;
            write = 1;
            data_in = 16'h0001;
            direccion = 5'h0C;
            #(CLK_PERIOD)
            chip_select = 0;
            read = 0;
            write = 0;
            #(CLK_PERIOD*17)
            
            // Leer estado de completado
            chip_select = 1;
            read = 1;
            write = 0;
            direccion = 5'h14;
            #(CLK_PERIOD)
            chip_select = 0;
            read = 0;
            write = 0;
            #(CLK_PERIOD)
            
            // Leer resultado
            chip_select = 1;
            read = 1;
            write = 0;
            direccion = 5'h10;
            #(CLK_PERIOD);
            chip_select = 0;
            read = 0;
            write = 0;
            #(CLK_PERIOD*20);   
        end
    end
     
    initial begin: TEST_CASE
        $dumpfile("perip_mult_TB.vcd");
        $dumpvars(-1, peripheral_mult_TB);
        #(CLK_PERIOD*50) $finish;
    end

endmodule