# Metodología de conciliación taxonómica

[`conciliar_especies_serfor()`](https://paulesantos.github.io/spforestalesp/reference/conciliar_especies_serfor.md)
compara cada entrada con una referencia de especies. Si no se
proporciona `target_df`, usa los nombres de `wcvpdata` (versión 0.7.0 o
posterior). Cada registro de entrada conserva una fila de salida,
incluso si el nombre se repite.

## Datos modelo reproducibles

El paquete incluye tres tibbles sintéticos: `serfor_modelo` (12
entradas), `referencia_modelo` (14 registros de referencia) y
`resultado_modelo_esperado` (estados y métodos esperados). Cubren
binomios exactos, género difuso, cambio de terminación, epíteto difuso,
empates, duplicados, sinónimos, nombres sin coincidencia y un registro
infraespecífico que debe quedar fuera de la búsqueda.

``` r

library(spforestalesp)
data("serfor_modelo")
data("referencia_modelo")
data("resultado_modelo_esperado")

resultado <- conciliar_especies_serfor(serfor_modelo, referencia_modelo)
resultado[c("numero", "estado_coincidencia", "metodo_coincidencia")]
```

    ## # A tibble: 12 × 3
    ##    numero estado_coincidencia metodo_coincidencia         
    ##     <int> <chr>               <chr>                       
    ##  1      1 coincidencia        binomio_exacto              
    ##  2      2 coincidencia        binomio_exacto              
    ##  3      3 coincidencia        genero_difuso_epiteto_exacto
    ##  4      4 coincidencia        variante_terminacion        
    ##  5      5 coincidencia        epiteto_difuso              
    ##  6      6 sin_coincidencia    NA                          
    ##  7      7 ambiguo             genero_difuso               
    ##  8      8 ambiguo             epiteto_difuso              
    ##  9      9 sin_coincidencia    NA                          
    ## 10     10 ambiguo             binomio_exacto              
    ## 11     11 coincidencia        binomio_exacto              
    ## 12     12 coincidencia        binomio_exacto

La comparación con la tabla esperada permite detectar cambios de
comportamiento:

``` r

columnas <- c("estado_coincidencia", "metodo_coincidencia",
              "id_referencia", "nombre_aceptado")
all(vapply(columnas, function(columna) {
  identical(resultado[[columna]], resultado_modelo_esperado[[columna]])
}, logical(1)))
```

    ## [1] TRUE

Estos nombres y autorías de prueba son sintéticos; no representan una
propuesta de cambio a la lista oficial de SERFOR.

## Preparación de la referencia

La referencia debe tener `genus` y `species`. Se eliminan las filas sin
estos campos. Si hay `taxon_rank`, se conservan solo las filas
`Species`; si hay `infraspecific_rank`, se descartan los registros
infraespecíficos. La función quita espacios iniciales y finales de
`genus` y `species` en la referencia.

## Orden de búsqueda

1.  **Binomio exacto:** compara género y epíteto específicos.
2.  **Género difuso con epíteto exacto:** usa la menor distancia dentro
    de `max_dist`. Un empate entre géneros se resuelve solo si uno
    contiene el epíteto exacto.
3.  **Variante de terminación:** compara la raíz tras quitar `ae`, `is`,
    `um`, `us`, `a` o `i`; la raíz debe apuntar a una única especie
    dentro del género.
4.  **Epíteto difuso:** compara solo con especies del género resuelto.
    Un epíteto de hasta siete caracteres requiere un candidato de igual
    longitud.

Las etapas difusas usan
[`fuzzyjoin::stringdist_inner_join()`](https://rdrr.io/pkg/fuzzyjoin/man/stringdist_join.html),
con distancia OSA y `max_dist = 1` por defecto. La columna
`distancia_epiteto` describe la distancia de la etapa difusa o el valor
cero para un epíteto exacto; es `NA` para una variante de terminación.

## Empates y nombres aceptados

Los empates no resueltos se marcan `ambiguo`. Sus candidatos se
conservan en el atributo `candidatos_ambiguos`:

``` r

names(attr(resultado, "candidatos_ambiguos"))
```

    ## [1] "7"  "8"  "10"

Cuando varios registros de referencia comparten un binomio, se compara
la autoría ignorando espacios y mayúsculas. Si no se distingue un único
registro, el caso queda ambiguo. Un binomio único con autoría diferente
conserva la coincidencia y registra `autor_coincide = FALSE`.

Si la referencia proporciona identificadores, la función sigue
`accepted_plant_name_id` y devuelve `nombre_aceptado` cuando puede
resolver ese registro. Los nombres aceptados son resultados de la
referencia, no ediciones automáticas de la lista de SERFOR.

## Corrida incluida con WCVP

Con `wcvpdata` 0.7.0 (WCVP versión 16, junio de 2026), 730 de 734
entradas recibieron coincidencia: 728 binomios exactos, un epíteto
difuso y una variante de terminación. Dos quedaron ambiguas (registros 9
y 218) y dos sin coincidencia (33 y 385). Revise también las
coincidencias no exactas 406 y 674, y las filas con
`autor_coincide = FALSE`.

El flujo se inspira en
[`wcvpmatch`](https://github.com/PaulESantos/wcvpmatch) y usa
[`fuzzyjoin`](https://github.com/dgrtwo/fuzzyjoin) para las
comparaciones difusas.
