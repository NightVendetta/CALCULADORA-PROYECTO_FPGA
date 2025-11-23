`timescale 1ns / 1ps

`define SIMULATION
module periferico_raiz_TB;
    reg reloj;
    reg reiniciar;
    reg [15:0] entrada_datos;
    reg habilitar;
    reg [4:0] direccion;
    reg leer;
    reg escribir;
    wire [31:0] salida_datos;

    periferico_raiz uut (
        .reloj(reloj),
        .reiniciar(reiniciar),
        .entrada_datos(entrada_datos),
        .habilitar(habilitar),
        .direccion(direccion),
        .leer(leer),
        .escribir(escribir),
        .salida_datos(salida_datos)
    );

    parameter PERIODO = 20;

    initial begin  
        reloj = 0;
        reiniciar = 0;
        entrada_datos = 0;
        direccion = 5'h00;
        habilitar = 0;
        leer = 0;
        escribir = 0;
    end

    initial reloj <= 0;
    always #(PERIODO/2) reloj <= ~reloj;

    initial begin 
        forever begin
            @ (posedge reloj);
            reiniciar = 1;
            @ (posedge reloj);
            reiniciar = 0;
            #(PERIODO * 4)

            habilitar = 1;
            leer = 0;
            escribir = 1;
            entrada_datos = 16'h0271;  // 625 decimal
            direccion = 5'h04;
            #(PERIODO)
            habilitar = 0;
            leer = 0;
            escribir = 0;
            #(PERIODO * 4)
            habilitar = 0;
            leer = 0;
            escribir = 0;
            #(PERIODO * 3)

            habilitar = 1;
            leer = 0;
            escribir = 1;
            entrada_datos = 16'h0001;
            direccion = 5'h0C;
            #(PERIODO)
            habilitar = 0;
            leer = 0;
            escribir = 0;
            @ (posedge periferico_raiz_TB.uut.instancia_raiz.terminado);

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
            #(PERIODO * 30);   
        end
    end

    initial begin: CASO_PRUEBA
        $dumpfile("periferico_raiz_TB.vcd");
        $dumpvars(-1, periferico_raiz_TB);
        #(PERIODO * 100) $finish;
    end

endmodule