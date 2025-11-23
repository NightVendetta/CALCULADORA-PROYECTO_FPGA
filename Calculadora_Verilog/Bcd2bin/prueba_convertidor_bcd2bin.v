`timescale 1ns / 1ps
`define SIMULATION
module prueba_convertidor_bcd2bin;
   reg  reloj;
   reg  reset;
   reg  iniciar;
   reg  [19:0] entrada_bcd;
   wire [32:0] resultado_binario;
   wire conversion_terminada;
   
   convertidor_bcd_binario uut (
     .reloj(reloj),
     .reset(reset),
     .inicio(iniciar),
     .entrada_bcd(entrada_bcd),
     .resultado_bin(resultado_binario),
     .terminado(conversion_terminada)
   );

   parameter PERIODO          = 20;
   parameter real CICLO_TRABAJO = 0.5;
   parameter OFFSET          = 0;
   reg [20:0] i;

   initial begin
      reloj = 0; reset = 0; iniciar = 0; entrada_bcd = 20'h35789;
   end
   
   initial begin
     #OFFSET;
     forever begin
         reloj = 1'b0;
         #(PERIODO-(PERIODO*CICLO_TRABAJO)) reloj = 1'b1;
         #(PERIODO*CICLO_TRABAJO);
       end
   end
   
   initial begin
        @ (negedge reloj);
        reset = 1;
        @ (negedge reloj);
        reset = 0;
        @ (posedge reloj);
        iniciar = 0;
        @ (posedge reloj);
        iniciar = 1;
       for(i=0; i<2; i=i+1) begin
         @ (posedge reloj);
       end
          iniciar = 0;
       for(i=0; i<17; i=i+1) begin
         @ (posedge reloj);
       end
   end
   
   initial begin: CASO_PRUEBA
     $dumpfile("prueba_convertidor_bcd2bin.vcd");
     $dumpvars(-1, uut);
     #((PERIODO*CICLO_TRABAJO)*200) $finish;
   end
endmodule