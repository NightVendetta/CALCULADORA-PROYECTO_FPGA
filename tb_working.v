`timescale 1ns / 1ps

module tb_working;
    reg clk_25mhz = 0;
    
    // Señales del módulo
    wire LP_CLK, LATCH, NOE;
    wire [2:0] RGB0, RGB1;
    wire [4:0] ROW;
    
    // Instancia del módulo corregido
    led_matrix_testsim dut (
        .clk_25mhz(clk_25mhz),
        .LP_CLK(LP_CLK),
        .LATCH(LATCH),
        .NOE(NOE),
        .RGB0(RGB0),
        .RGB1(RGB1),
        .ROW(ROW)
    );
    
    // Contador de ciclos
    integer cycle_count = 0;
    
    // Generador de reloj (25MHz = periodo 40ns)
    always #20 begin
        clk_25mhz = ~clk_25mhz;
        if (clk_25mhz == 1) cycle_count = cycle_count + 1;
    end
    
    // Monitoreo en consola
    always @(posedge clk_25mhz) begin
        if (cycle_count == 256) begin
            $display("=== CICLO 256 ===");
            $display("rst_n = %b", dut.rst_n);
            $display("state = %d", dut.state);
            $display("config_done = %b", dut.config_done);
        end
        
        if (cycle_count == 512) begin
            $display("=== CICLO 512 ===");
            $display("state = %d", dut.state);
            $display("row_counter = %d", dut.row_counter);
            $display("col_counter = %d", dut.col_counter);
        end
        
        // Mostrar progreso cada 1000 ciclos
        if (cycle_count % 1000 == 0 && cycle_count > 0) begin
            $display("Ciclo %6d: state=%d, row=%d, col=%d, bit_plane=%d", 
                     cycle_count, dut.state, dut.row_counter, dut.col_counter, dut.bit_plane);
        end
    end
    
    initial begin
        // Archivo de volcado
        $dumpfile("working.vcd");
        $dumpvars(0, tb_working);
        
        $display("========================================");
        $display("INICIANDO SIMULACIÓN LED MATRIX CONTROLLER");
        $display("========================================");
        
        // Simular por tiempo suficiente (2ms)
        #2000000;
        
        $display("\n========================================");
        $display("SIMULACIÓN COMPLETADA");
        $display("Ciclos totales: %d", cycle_count);
        $display("Estado final: %d", dut.state);
        $display("Última fila: %d", dut.ROW);
        $display("========================================");
        
        $finish;
    end
    
    // Terminar si hay algún error crítico
    always @(posedge clk_25mhz) begin
        if (cycle_count > 300 && dut.state === 5'bx) begin
            $display("ERROR: Estado 'state' sigue en X después de 300 ciclos!");
            $display("rst_n = %b, rst_counter = %d", dut.rst_n, dut.rst_counter);
            $finish;
        end
    end
endmodule