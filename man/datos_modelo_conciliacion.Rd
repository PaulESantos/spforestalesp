\name{datos_modelo_conciliacion}
\alias{serfor_modelo}
\alias{referencia_modelo}
\alias{resultado_modelo_esperado}
\title{Datos modelo para evaluar la conciliación taxonómica}
\description{
Tres tibbles sintéticos que cubren las etapas de conciliación y sus resultados
esperados. Los nombres y las autorías de prueba no representan decisiones
taxonómicas oficiales.
}
\format{
\describe{
  \item{\code{serfor_modelo}}{Doce entradas con las ocho columnas del listado
  de SERFOR. Incluye una entrada duplicada, errores de género y epíteto,
  variantes de terminación y nombres sin coincidencia.}
  \item{\code{referencia_modelo}}{Catorce registros de referencia con género,
  epíteto, autoría, rango, estado e identificadores de nombres aceptados.}
  \item{\code{resultado_modelo_esperado}}{Doce filas con el estado, método,
  identificador y nombre aceptado esperados para cada entrada.}
}
}
\usage{
data(serfor_modelo)
data(referencia_modelo)
data(resultado_modelo_esperado)
}
\examples{
data(serfor_modelo)
data(referencia_modelo)
data(resultado_modelo_esperado)
resultado <- conciliar_especies_serfor(serfor_modelo, referencia_modelo)
all(vapply(c("estado_coincidencia", "metodo_coincidencia"), function(columna) {
  identical(resultado[[columna]], resultado_modelo_esperado[[columna]])
}, logical(1)))
}
