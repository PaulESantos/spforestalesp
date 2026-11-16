## -----------------------------------------------------------------------------
library(spforestalesp)
data("serfor_modelo")
data("referencia_modelo")
data("resultado_modelo_esperado")

resultado <- conciliar_especies_serfor(serfor_modelo, referencia_modelo)
resultado[c("numero", "estado_coincidencia", "metodo_coincidencia")]

## -----------------------------------------------------------------------------
columnas <- c("estado_coincidencia", "metodo_coincidencia",
              "id_referencia", "nombre_aceptado")
all(vapply(columnas, function(columna) {
  identical(resultado[[columna]], resultado_modelo_esperado[[columna]])
}, logical(1)))

## -----------------------------------------------------------------------------
names(attr(resultado, "candidatos_ambiguos"))

