# Diagramas de Camino de Datos

Los diagramas de camino de datos muestran la estructura de los componentes que manipulan la información en cada módulo.

## Multiplicación
El camino de datos del multiplicador consta de registros para almacenar los operandos temporales y el producto acumulado. Incluye unidades funcionales para desplazamiento izquierdo y derecho, un sumador de 32 bits para acumular resultados, y un decrementador para controlar las iteraciones. La máquina de estados coordina todas las operaciones y genera las señales de control.

## División
El camino de datos del divisor utiliza un registro de 32 bits para el dividendo extendido y operaciones intermedias. Incluye un desplazador izquierdo, un sumador/restador en complemento a 2, y un comparador para evaluar el signo de las restas. La máquina de estados controla la secuencia de operaciones y la actualización del cociente.

## Raíz Cuadrada
El camino de datos de la raíz cuadrada utiliza tres registros de desplazamiento (LSR2, LSR_R, LSR_TMP) para almacenar valores intermedios, un sumador/restador para calcular las restas condicionales, y un contador para controlar las iteraciones. La máquina de estados coordina las operaciones.

## Binario a BCD
El camino de datos del conversor Binario a BCD consta de un registro de desplazamiento que almacena el valor BCD en formación, un contador para las iteraciones, comparadores para verificar cada dígito BCD, y sumadores para añadir 3 cuando es necesario. La máquina de estados controla la secuencia de operaciones.

## BCD a Binario
El camino de datos del conversor BCD a Binario es similar al de Binario a BCD, pero utiliza restadores en lugar de sumadores. El registro de desplazamiento almacena el valor binario en formación, y las unidades funcionales ajustan los dígitos BCD durante el desplazamiento.
