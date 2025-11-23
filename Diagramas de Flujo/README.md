## 📐 DIAGRAMAS DE FLUJO


En esta carpeta se encuentran los diagramas de flujo que describen el comportamiento algorítmico de cada uno de los módulos desarrollados para la calculadora digital.

## Multiplicación
El multiplicador implementa el algoritmo de desplazamiento y suma. Comienza en estado IDLE esperando la señal de start. Cuando se activa start, carga los operandos en registros temporales. Luego revisa bit por bit del operando B, realizando sumas cuando el bit menos significativo es 1 y desplazamientos en cada ciclo. El proceso se repite durante 16 iteraciones, finalizando con la señal completed activa después de un período de espera.

## División
El divisor implementa el algoritmo de división por restas sucesivas con desplazamiento. Comienza cargando el dividendo y divisor en registros de 32 y 16 bits respectivamente. En cada iteración desplaza el registro A a la izquierda, realiza una resta condicional, y actualiza el bit de cociente según el resultado. El proceso se repite 16 veces para obtener el cociente de 16 bits.

## Raíz Cuadrada
El módulo de raíz cuadrada implementa el algoritmo de desplazamiento y resta. Comienza cargando el valor de entrada en registros internos. En cada iteración, desplaza los registros, calcula una resta condicional y actualiza el resultado basándose en el signo de la resta. El proceso se repite 8 veces (para 16 bits) y finaliza activando la señal done.

## Binario a BCD
El conversor Binario a BCD utiliza el algoritmo de desplazamiento y suma de 3. Comienza cargando el valor binario en un registro de desplazamiento. En cada iteración, desplaza el registro BCD a la izquierda y luego añade 3 a cualquier dígito BCD que sea mayor a 4. Este proceso se repite 16 veces, una por cada bit del número binario. Al finalizar, se activa la señal conversion_done.

## BCD a Binario
El conversor BCD a Binario utiliza el algoritmo inverso al de Binario a BCD. Comienza cargando el valor BCD en un registro de desplazamiento. En cada iteración, desplaza el registro binario a la izquierda y luego resta 3 de cualquier dígito BCD que sea mayor a 7. Este proceso se repite 16 veces. Al finalizar, se activa la señal terminado.
