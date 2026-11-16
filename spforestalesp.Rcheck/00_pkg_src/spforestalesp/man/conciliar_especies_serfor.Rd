\name{conciliar_especies_serfor}
\alias{conciliar_especies_serfor}
\title{Conciliar nombres de SERFOR con una referencia taxonómica}
\usage{
conciliar_especies_serfor(serfor = NULL, target_df = NULL,
                         max_dist = 1L, method = "osa")
}
\arguments{
  \item{serfor}{Tabla con \code{numero}, \code{genero}, \code{epiteto_especifico}
  y \code{autor}. Por defecto, usa la lista incluida en el paquete.}
  \item{target_df}{Referencia con \code{genus} y \code{species}. Puede incluir
  \code{taxon_authors}, \code{taxon_status}, \code{taxon_name},
  \code{plant_name_id} y \code{accepted_plant_name_id}. Por defecto, usa
  \code{wcvpdata} (versión 0.7.0 o posterior).}
  \item{max_dist}{Distancia máxima entera y no negativa para las etapas difusas.}
  \item{method}{Método de distancia de \code{stringdist} usado por \code{fuzzyjoin}.
  El valor predeterminado es \code{osa}.}
}
\description{
Concilia la lista de SERFOR con un backbone taxonómico mediante coincidencia
exacta del binomio, género difuso con epíteto exacto, variante de terminación
y epíteto difuso dentro del género. Las etapas difusas usan
\code{fuzzyjoin::stringdist_inner_join()}.
}
\details{
Solo se consideran registros de especie de la referencia. Para epítetos de
siete caracteres o menos, la etapa difusa exige igual longitud. Los empates
quedan como \code{ambiguo}; los candidatos se conservan en el atributo
\code{candidatos_ambiguos}. La coincidencia de autoría ignora diferencias de
espacios y mayúsculas y se usa para distinguir registros con el mismo
binomio. Una autoría diferente queda indicada en \code{autor_coincide}, pero
no invalida por sí sola un binomio único. El orden completo de etapas se
documenta en \code{vignette("metodologia-conciliacion", package = "spforestalesp")}. Un nombre aceptado solo
se informa cuando puede resolverse mediante los identificadores de la
referencia.
}
\value{
Un tibble de una fila por registro de SERFOR con
\code{estado_coincidencia} (\code{coincidencia}, \code{ambiguo} o
\code{sin_coincidencia}), \code{metodo_coincidencia}, nombres coincidentes,
distancias y, cuando existen, autoría, estado taxonómico y nombre aceptado.
El atributo \code{candidatos_ambiguos} guarda los candidatos empatados.
}
\examples{
data(lista_oficial_especies_forestales)
serfor_ejemplo <- lista_oficial_especies_forestales[
  lista_oficial_especies_forestales$numero \%in\% c(1L, 406L),
]
referencia <- data.frame(
  genus = c("Abarema", "Moquilea"),
  species = c("acreana", "magnifructa")
)
resultado <- conciliar_especies_serfor(serfor_ejemplo, referencia)
resultado[c("numero", "metodo_coincidencia", "epiteto_coincidente")]
}
