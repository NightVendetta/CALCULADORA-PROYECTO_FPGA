# Calculadora Digital - Proyecto Final
## Electronica digital I

### Integrantes:
- Samuel David Bermudez Chaparro - 1013101679
- Juan Sebastian Florez Payares- 1014656445

---

## Sobre este proyecto

Este es nuestro proyecto final de Electronica Digital 1. Durante todo el semestre estuvimos trabajando en el diseño e implementación de una calculadora digital usando Verilog y avanzando en el diseño e implementación de lo aprendido en un proyecto usando pantalla LED y FPGA.

Lo que se hizo fue crear todos los módulos usando como referencia los modulos hechos por el profesor Carlos Camargo: multiplicación, división, raíz cuadrada y los conversores entre binario y BCD. Cada uno lo fuimos desarrollando por separado y después los integramos.

## Qué contiene este repositorio

###  Los módulos de la calculadora:
- **Multiplicación** - Con el algoritmo de desplazamiento y suma
- **División** - Usando restas sucesivas  
- **Raíz Cuadrada** - Con el método binario
- **Binario a BCD** - Para mostrar números en displays
- **BCD a Binario** - Para leer entradas de teclado

###  Nuestros diagramas:
- **Diagramas de flujo** - Cómo funciona cada algoritmo paso a paso
- **Camino de datos** - Los componentes y conexiones de cada módulo
- **Máquinas de control** - Los estados por los que pasa cada operación

###  Simulaciones:
- Las pruebas que se hicieron para verificar que todo se diseñó correctamente
- Capturas de las waveforms de GTKWave
- Codigos para implementacion en FPGA mediante minicom (este apartado sigue como prototipo ya que la FPGA presentó problemas con los pines)
## Plataformas utilizadas

Usamos Icarus Verilog para compilar y simular, y GTKWave para ver los resultados. 

Para correr cualquier simulación:

```bash
iverilog -o sim modulo.v modulo_TB.v
vvp sim
gtkwave modulo_TB.vcd
