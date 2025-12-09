PROJECT = led_matrix_test
TOP_MODULE = top
VERILOG_SRC = memory.v fsm_controller.v led_matrix_test.v top.v
LPF_FILE = colorlight_5a_75e.lpf
DEVICE = 25k
PACKAGE = CABGA256
BUILD_DIR = build
YOSYS = yosys
NEXTPNR = nextpnr-ecp5
ECPPACK = ecppack
OPENFPGALOADER = openFPGALoader
FREQ = 25

.PHONY: all clean program flash info check

all: $(BUILD_DIR)/$(PROJECT).bit

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/$(PROJECT).json: $(VERILOG_SRC) | $(BUILD_DIR)
	@echo "========================================"
	@echo "Síntesis (4 archivos modulares)..."
	@echo "========================================"
	$(YOSYS) -p "read_verilog $(VERILOG_SRC); synth_ecp5 -top $(TOP_MODULE) -json $@"

$(BUILD_DIR)/$(PROJECT).config: $(BUILD_DIR)/$(PROJECT).json $(LPF_FILE)
	@echo "========================================"
	@echo "Place & Route..."
	@echo "========================================"
	$(NEXTPNR) --$(DEVICE) --package $(PACKAGE) --json $< --lpf $(LPF_FILE) --textcfg $@ --freq $(FREQ)

$(BUILD_DIR)/$(PROJECT).bit: $(BUILD_DIR)/$(PROJECT).config
	@echo "========================================"
	@echo "Generando bitstream..."
	@echo "========================================"
	$(ECPPACK) --compress $< $@
	@echo ""
	@echo "✓ LISTO: $(BUILD_DIR)/$(PROJECT).bit"
	@echo ""

program: $(BUILD_DIR)/$(PROJECT).bit
	@echo "Programando FPGA..."
	sudo $(OPENFPGALOADER) -c ft232RL --pins=TXD:CTS:DTR:RXD -m $<

flash: $(BUILD_DIR)/$(PROJECT).bit
	sudo $(OPENFPGALOADER) -c ft232RL --pins=TXD:CTS:DTR:RXD $<

clean:
	rm -rf $(BUILD_DIR)

info:
	@echo "Proyecto: LED Matrix (4 archivos)"
	@echo "  1. memory.v - Memoria"
	@echo "  2. fsm_controller.v - FSM separada"
	@echo "  3. led_matrix_test.v - Integrador"
	@echo "  4. top.v - Top level"

check:
	@echo "Verificando..."
	@for f in $(VERILOG_SRC) $(LPF_FILE) image.hex; do \
		if [ -f $$f ]; then echo "  ✓ $$f"; else echo "  ✗ $$f FALTA"; fi \
	done
