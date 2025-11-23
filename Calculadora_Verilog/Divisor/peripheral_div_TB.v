`timescale 1ns / 1ps

`define SIMULATION
module peripheral_div_TB;
    reg clock;
    reg rst;
    reg [15:0] entrada_datos;
    reg habilitar;
    reg [4:0] direccion;
    reg leer;
    reg escribir;
    wire [31:0] salida_datos;

    peripheral_div uut (
        .clock(clock),
        .rst(rst),
        .entrada_datos(entrada_datos),
        .habilitar(habilitar),
        .direccion(direccion),
        .leer(leer),
        .escribir(escribir),
        .salida_datos(salida_datos)
    );

    parameter PERIODO = 20;
    
    initial begin  
        clock = 0;
        rst = 0;
        entrada_datos = 0;
        direccion = 5'h00;
        habilitar = 0;
        leer = 0;
        escribir = 0;
    end
    
    initial clock <= 0;
    always #(PERIODO/2) clock <= ~clock;

    initial begin 
        forever begin
            @ (negedge clock);
            rst = 1;
            @ (negedge clock);
            rst = 0;
            #(PERIODO*4)
            
            habilitar = 1;
            leer = 0;
            escribir = 1;
            entrada_datos = 16'h0064;  // 100 decimal
            direccion = 5'h04;
            #(PERIODO)
            habilitar = 0;
            leer = 0;
            escribir = 0;
            #(PERIODO*3)
            
            habilitar = 1;
            leer = 0;
            escribir = 1;
            entrada_datos = 16'h0004;  // 4 decimal
            direccion = 5'h08;
            #(PERIODO)
            habilitar = 0;
            leer = 0;
            escribir = 0;
            #(PERIODO*3)
            
            habilitar = 1;
            leer = 0;
            escribir = 1;
            entrada_datos = 16'h0001;
            direccion = 5'h0C;
            #(PERIODO)
            habilitar = 0;
            leer = 0;
            escribir = 0;
            #(PERIODO*17)
            
            habilitar = 1;
            leer = 1;
            escribir = 0;
            direccion = 5'h14;
            #(PERIODO)
            habilitar = 0;
            leer = 0;
            escribir = 0;
            #(PERIODO)
            
            habilitar = 1;
            leer = 1;
            escribir = 0;
            direccion = 5'h10;
            #(PERIODO);
            habilitar = 0;
            leer = 0;
            escribir = 0;
            #(PERIODO*20);   
        end
    end
     
    initial begin: CASO_PRUEBA
        $dumpfile("perip_div_TB.vcd");
        $dumpvars(-1, peripheral_div_TB);
        #(PERIODO*100) $finish;
    end

endmodule