module control_sqrt(clk, rst, init, msb, z, done, ld_tmp, r0, sh, ld, lda2);
    input clk, rst, init, msb, z;
    output reg done, ld_tmp, r0, sh, ld, lda2;

    parameter INICIO=0, VERIFICAR=1, DESPLAZAR=2, CARGAR_TMP=3, CARGAR_A2=4, VERIFICAR_Z=5, FINAL=6;
    reg [2:0] estado;

    always @(posedge clk) begin
        if (rst) begin
            estado <= INICIO;
        end else begin
            case(estado)
                INICIO: estado <= init ? DESPLAZAR : INICIO;
                DESPLAZAR: estado <= CARGAR_TMP;
                CARGAR_TMP: estado <= VERIFICAR;
                VERIFICAR: estado <= msb ? VERIFICAR_Z : CARGAR_A2;
                CARGAR_A2: estado <= VERIFICAR_Z;
                VERIFICAR_Z: estado <= z ? FINAL : DESPLAZAR;
                FINAL: estado <= FINAL;
                default: estado <= INICIO;
            endcase
        end
    end

    always @(*) begin
        {done, ld_tmp, r0, sh, ld, lda2} = 6'b000000;
        case(estado)
            INICIO: {ld} = 1'b1;
            DESPLAZAR: {sh} = 1'b1;
            CARGAR_TMP: {ld_tmp} = 1'b1;
            CARGAR_A2: {r0, lda2} = 2'b11;
            FINAL: {done} = 1'b1;
        endcase
    end
endmodule