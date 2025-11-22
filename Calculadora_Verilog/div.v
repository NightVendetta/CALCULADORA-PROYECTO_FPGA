module div (
    input              rst,
    input              clock,
    input              comenzar,
    output reg         finalizado,
    output reg [31:0]  cociente,
    input      [15:0]  dividendo,
    input      [15:0]  divisor
);

parameter REPOSO          = 3'b000;
parameter COMPARAR        = 3'b001;
parameter VERIFICAR_FIN   = 3'b011;
parameter DESPLAZAR       = 3'b010;
parameter TERMINADO       = 3'b100;
parameter CARGAR_OPERANDOS = 3'b101;

reg  [2:0]  estado_actual;
reg  [31:0] registro_A;
reg  [15:0] registro_B;
wire [15:0] resta_AB;

initial begin
    cociente   = 0;
    finalizado = 0;
end 

reg [4:0] contador_ciclos;

assign resta_AB = registro_A[31:16] + (~registro_B + 1);

always @(posedge clock or posedge rst) begin
    if (rst) begin
        finalizado <= 0;
        cociente   <= 0;
        estado_actual = REPOSO;
    end else begin
        case(estado_actual)
            REPOSO: begin
                contador_ciclos =  16;
                finalizado     <= 0;
                cociente       =  0;
                if(comenzar)
                    estado_actual = CARGAR_OPERANDOS;
                else
                    estado_actual = REPOSO;
            end

            CARGAR_OPERANDOS: begin
                registro_A    <= {16'b0, dividendo};
                registro_B    <= divisor;
                finalizado   <= 0;
                cociente     =  0;
                estado_actual = DESPLAZAR;
            end

            DESPLAZAR: begin
                registro_A     = registro_A << 1;
                contador_ciclos = contador_ciclos - 1;
                finalizado     = 0;
                estado_actual = COMPARAR;
            end

            COMPARAR: begin
                if(resta_AB[15])
                    registro_A[0] = 0;
                else begin
                    registro_A[0]  = 1;
                    registro_A[31:16] = resta_AB;
                end
                finalizado = 0;
                estado_actual = VERIFICAR_FIN;
            end

            VERIFICAR_FIN: begin
                if(contador_ciclos == 0) begin
                    cociente[15:0] = registro_A;
                    estado_actual = TERMINADO;
                end
                else begin
                    estado_actual = DESPLAZAR;
                end
            end

            TERMINADO: begin
                finalizado = 1;
                contador_ciclos = contador_ciclos + 1;
                estado_actual = (contador_ciclos > 29) ? REPOSO : TERMINADO;
            end

            default: estado_actual = REPOSO;
        endcase
    end
end

`ifdef BENCH
reg [8*40:1] nombre_estado;
always @(*) begin
    case(estado_actual)
        REPOSO:             nombre_estado = "REPOSO";
        CARGAR_OPERANDOS:   nombre_estado = "CARGAR_OPERANDOS";
        COMPARAR:           nombre_estado = "COMPARAR";
        DESPLAZAR:          nombre_estado = "DESPLAZAR";
        VERIFICAR_FIN:      nombre_estado = "VERIFICAR_FIN";
        TERMINADO:          nombre_estado = "TERMINADO";
    endcase
end
`endif

endmodule