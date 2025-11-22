`timescale 1ns / 1ps

`define SIMULATION
module prueba_periferico_bcd2bin;
   reg reloj;
   reg  reset;
   reg  iniciar;
   reg [19:0] dato_entrada;
   reg habilitacion_chip;
   reg [4:0] direccion;
   reg leer;
   reg escribir;
   wire [31:0] dato_salida;

  periferico_bcd2bin uut (
    .reloj(reloj),
    .reset(reset),
    .dato_entrada(dato_entrada),
    .habilitacion_chip(habilitacion_chip),
    .direccion(direccion),
    .leer(leer),
    .escribir(escribir),
    .dato_salida(dato_salida)
  );

   parameter PERIODO = 20;
   
   initial begin  
      reloj = 0; reset = 0; dato_entrada = 0; direccion = 16'h0000; habilitacion_chip=0; leer=0; escribir=0;
   end
   
   initial reloj <= 0;
   always #(PERIODO/2) reloj <= ~reloj;

   initial begin 
    forever begin
     @ (posedge reloj);
    reset = 1;
    @ (posedge reloj);
    reset = 0;
     #(PERIODO*4)
     
     habilitacion_chip=1; leer=0; escribir=1;
    dato_entrada = 20'h12345;
    direccion = 16'h0004;
     #(PERIODO)
     habilitacion_chip=0; leer=0; escribir=0;
     #(PERIODO*4)
     habilitacion_chip=0; leer=0; escribir=0;
     #(PERIODO*3)
     
     habilitacion_chip=1; leer=0; escribir=1;
    dato_entrada = 16'h0001;
    direccion = 16'h000C;
     #(PERIODO)
     habilitacion_chip=0; leer=0; escribir=0;
     @ (posedge prueba_periferico_bcd2bin.uut.convertidor_bcd_binario0.terminado);
     
     habilitacion_chip=1; leer=1; escribir=0;
     direccion = 16'h0014;
     #(PERIODO)
     habilitacion_chip=0; leer=0; escribir=0;
     #(PERIODO)
     
     habilitacion_chip=1; leer=1; escribir=0;
     direccion = 16'h0010;
     #(PERIODO);
     habilitacion_chip=0; leer=0; escribir=0;
     #(PERIODO*30);   
    end
   end

   initial begin: CASO_PRUEBA
     $dumpfile("prueba_periferico_bcd2bin.vcd");
     $dumpvars(-1, prueba_periferico_bcd2bin);
     #(PERIODO*100) $finish;
   end

endmodule