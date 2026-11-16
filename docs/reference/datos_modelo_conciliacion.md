# Datos modelo para evaluar la conciliación taxonómica

Tres tibbles sintéticos que cubren las etapas de conciliación y sus
resultados esperados. Los nombres y las autorías de prueba no
representan decisiones taxonómicas oficiales.

## Usage

``` r
data(serfor_modelo)
data(referencia_modelo)
data(resultado_modelo_esperado)
```

## Format

- `serfor_modelo`:

  Doce entradas con las ocho columnas del listado de SERFOR. Incluye una
  entrada duplicada, errores de género y epíteto, variantes de
  terminación y nombres sin coincidencia.

- `referencia_modelo`:

  Catorce registros de referencia con género, epíteto, autoría, rango,
  estado e identificadores de nombres aceptados.

- `resultado_modelo_esperado`:

  Doce filas con el estado, método, identificador y nombre aceptado
  esperados para cada entrada.

## Examples

``` r
data(serfor_modelo)
data(referencia_modelo)
data(resultado_modelo_esperado)
resultado <- conciliar_especies_serfor(serfor_modelo, referencia_modelo)
all(vapply(c("estado_coincidencia", "metodo_coincidencia"), function(columna) {
  identical(resultado[[columna]], resultado_modelo_esperado[[columna]])
}, logical(1)))
#> [1] TRUE
```
