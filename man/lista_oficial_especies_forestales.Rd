\name{lista_oficial_especies_forestales}
\alias{lista_oficial_especies_forestales}
\title{Lista oficial de especies forestales del Perú}
\description{
Listado de 734 registros del anexo de SERFOR incluido en
\file{raw-data/lista_oficial_especies_forestales.md}.
}
\format{
Un tibble de 734 filas y ocho columnas:
\describe{
  \item{numero}{Número de orden, entero.}
  \item{especie}{Nombre científico completo, incluida la autoría.}
  \item{genero}{Género botánico.}
  \item{epiteto_especifico}{Epíteto específico.}
  \item{autor}{Autoría científica, incluida la parte entre paréntesis cuando existe.}
  \item{familia}{Familia botánica.}
  \item{nombre_comun}{Nombre o nombres comunes, separados por comas cuando corresponde.}
  \item{nombre_comercial}{Nombre comercial de la madera.}
}
Las marcas \code{S.I.}, \code{N.D.} y \code{No registra} se representan como \code{NA}
en las dos columnas de nombres comunes y comerciales.
}
\usage{data(lista_oficial_especies_forestales)}
\source{SERFOR, Lista Oficial de Especies Forestales, anexo reproducido en
\file{raw-data/lista_oficial_especies_forestales.md}.}
