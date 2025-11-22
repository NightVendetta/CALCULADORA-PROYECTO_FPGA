module controlador_bcd2bin( reloj, reset, inicio, terminado, desplazar, cargar, seleccionar, cargar_msb, sumar, fin_contador );
  
  input       reloj;
  input       reset;
  input       inicio;
  input       fin_contador;

  output reg desplazar;
  output reg cargar;
  output reg seleccionar;
  output reg cargar_msb;
  output reg sumar;
  output reg terminado;

  parameter INICIO     = 3'b000;
  parameter VERIFICAR  = 3'b001;
  parameter DESPLAZAR_DECIMAL = 3'b010;
  parameter SUMAR      = 3'b011;
  parameter CARGAR_A2  = 3'b100;
  parameter FINAL      = 3'b101;

  reg [2:0] estado_actual;
  reg [5:0] contador_temporal;

always @(posedge reloj) begin
  if (reset) begin
    estado_actual = INICIO;
    contador_temporal = 0;
  end else begin
    case(estado_actual)

      INICIO:begin
        if(inicio)
          estado_actual = DESPLAZAR_DECIMAL;
        else
          estado_actual = INICIO;
      end

      DESPLAZAR_DECIMAL: begin
        estado_actual = VERIFICAR;
      end

      VERIFICAR: begin
        if(fin_contador)
          estado_actual = FINAL;
        else
          estado_actual = CARGAR_A2;
      end

      CARGAR_A2: begin
        estado_actual = SUMAR;
      end

      SUMAR: begin
        estado_actual = DESPLAZAR_DECIMAL;
      end

      FINAL: begin
        contador_temporal = contador_temporal + 1;
        estado_actual = (contador_temporal > 30) ? INICIO : FINAL;
      end

      default: estado_actual = INICIO;
    endcase
  end
end

always @(*) begin
  case(estado_actual)
    INICIO: begin
      terminado   = 0;
      cargar_msb = 0;
      seleccionar = 0;
      desplazar   = 0;
      cargar      = 1;
      sumar       = 0;
    end

    DESPLAZAR_DECIMAL: begin
      terminado   = 0;
      cargar_msb = 1;
      seleccionar = 1;
      desplazar   = 1;
      cargar      = 0;
      sumar       = 0;
    end

    VERIFICAR: begin
      terminado   = 0;
      cargar_msb = 1;
      seleccionar = 1;
      desplazar   = 0;
      cargar      = 0;
      sumar       = 0;
    end

    CARGAR_A2: begin
      terminado   = 0;
      cargar_msb = 0;
      seleccionar = 0;
      desplazar   = 0;
      cargar      = 0;
      sumar       = 1;
    end

    SUMAR: begin
      terminado   = 0;
      cargar_msb = 0;
      seleccionar = 0;
      desplazar   = 0;
      cargar      = 0;
      sumar       = 0;
    end

    FINAL: begin
      terminado   = 1;
      cargar_msb = 0;
      seleccionar = 0;
      desplazar   = 0;
      cargar      = 0;
      sumar       = 0;
    end

  endcase
end

`ifdef BENCH
reg [8*40:1] nombre_estado;
always @(*) begin
  case(estado_actual)
    INICIO     : nombre_estado = "INICIO";
    VERIFICAR  : nombre_estado = "VERIFICAR";
    DESPLAZAR_DECIMAL : nombre_estado = "DESPLAZAR_DECIMAL";
    SUMAR      : nombre_estado = "SUMAR";
    CARGAR_A2  : nombre_estado = "CARGAR_A2";
    FINAL      : nombre_estado = "FINAL";
  endcase
end
`endif

endmodule