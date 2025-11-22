module registro_desplazamiento_bcd2bin (reloj, reset_carga, desplazar, carga_a2, entrada_reg1, entrada_reg2, salida_reg, salida_reg2);

   input         reloj;
   input         reset_carga;
   input         desplazar;
   input  [4:0]  carga_a2;
   input  [19:0] entrada_reg1;
   input  [19:0] entrada_reg2;
   output [19:0] salida_reg;
   output [15:0] salida_reg2;

   reg [35:0]  datos;

assign salida_reg  = datos[35:16];
assign salida_reg2 = datos[15:0];

always @(negedge reloj)
  if(reset_carga) begin
    datos[15:0]   <= 16'h0000;
    datos[35:16]  <= entrada_reg1;
  end
  else
   begin
    if(desplazar)
      datos[35:0] <= {1'b0, datos[35:1]} ;
    else begin
      if(carga_a2[4]==1)
        datos[35:32] <= entrada_reg2[19:16];
      if(carga_a2[3]==1)
        datos[31:28] <= entrada_reg2[15:12];
      if(carga_a2[2]==1)
        datos[27:24] <= entrada_reg2[11:8];
      if(carga_a2[1]==1)
        datos[23:20] <= entrada_reg2[7:4];
      if(carga_a2[0]==1)
        datos[19:16] <= entrada_reg2[3:0];
    end 
   end

endmodule