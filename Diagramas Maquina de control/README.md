# Diagramas de Máquina de Control

Estos diagramas representan las máquinas de estados finitos que coordinan la secuencia de operaciones en cada módulo.

## Multiplicación
La máquina de estados del multiplicador tiene seis estados principales. Comienza en IDLE y transiciona a LOAD_OPERANDS al activarse start. Luego alterna entre CHECK_BIT, ADD_OPERAND y SHIFT_OPERANDS según el valor de los bits del operando B. Finaliza en DONE después de completar todas las iteraciones, manteniéndose en este estado durante 30 ciclos de reloj antes de reiniciar.

## División
La máquina de estados del divisor gestiona el algoritmo de división mediante siete estados. Desde REPOSO transiciona a CARGAR_OPERANDOS al activarse comenzar. Luego ejecuta ciclos de DESPLAZAR, COMPARAR y actualización condicional (CARGAR_A2) basándose en el resultado de las restas. Finaliza en TERMINADO después de 16 iteraciones, con un período de espera similar al multiplicador.

## Raíz Cuadrada
La máquina de estados de la raíz cuadrada tiene seis estados. Comienza en START y al activarse init, realiza una secuencia de desplazamientos, cargas y comparaciones. El estado CHECK evalúa el bit más significativo de la resta para decidir si ajustar el resultado. El proceso termina en END1 cuando el contador llega a cero.

## Binario a BCD
La máquina de estados del conversor Binario a BCD tiene seis estados. Comienza en IDLE y transiciona a LOAD al activarse start. Luego, en un ciclo repetitivo, realiza SHIFT, ADD y DECREMENT hasta que el contador llega a cero, momento en el que transiciona a DONE y luego de vuelta a IDLE.

## BCD a Binario
La máquina de estados del conversor BCD a Binario tiene seis estados. Desde REPOSO transiciona a CARGAR al activarse inicio. Luego, en un ciclo, realiza DESPLAZAR, RESTAR y DECREMENTAR hasta que el contador se agosta, terminando en TERMINADO y volviendo a REPOSO.
