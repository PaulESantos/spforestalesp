# Conciliar nombres de SERFOR con una referencia taxonomica

Aplica, en orden, binomio exacto, genero difuso con epiteto exacto,
variante de terminacion y epiteto difuso dentro del genero. Las
coincidencias empatadas quedan marcadas como ambiguas.

## Usage

``` r
conciliar_especies_serfor(
  serfor = NULL,
  target_df = NULL,
  max_dist = 1L,
  method = "osa"
)
```

## Arguments

- serfor:

  Tibble con las columnas `numero`, `genero`, `epiteto_especifico` y
  `autor`. Por defecto usa los datos del paquete.

- target_df:

  Referencia con `genus` y `species`; puede incluir `taxon_authors`,
  `taxon_status`, `taxon_name`, `plant_name_id` y
  `accepted_plant_name_id`. Si es `NULL`, usa `wcvpdata` (\>= 0.7.0).

- max_dist:

  Distancia maxima para genero y epiteto difusos.

- method:

  Metodo de distancia de `stringdist` usado por `fuzzyjoin`.

## Value

Tibble de una fila por registro de SERFOR, con `estado_coincidencia`
(`coincidencia`, `ambiguo` o `sin_coincidencia`), `metodo_coincidencia`,
nombres coincidentes, distancias y, si la referencia lo permite,
autoria, estado taxonomico y nombre aceptado. El atributo
`candidatos_ambiguos` guarda los candidatos empatados.

## Details

Solo se consideran especies de la referencia. La coincidencia de autoria
ignora diferencias de espacios y mayusculas y permite distinguir
registros que comparten un binomio. Una autoria diferente queda indicada
en `autor_coincide`; no invalida por si sola un binomio unico. Los
epitetos de hasta siete caracteres solo se comparan de forma difusa con
candidatos de igual longitud. Consulte
[`vignette("metodologia-conciliacion", package = "spforestalesp")`](https://paulesantos.github.io/spforestalesp/articles/metodologia-conciliacion.md)
para el orden completo de etapas.

## Examples

``` r
data("lista_oficial_especies_forestales")
serfor_ejemplo <- lista_oficial_especies_forestales[
  lista_oficial_especies_forestales$numero %in% c(1L, 406L),
]
referencia <- data.frame(
  genus = c("Abarema", "Moquilea"),
  species = c("acreana", "magnifructa")
)
resultado <- conciliar_especies_serfor(serfor_ejemplo, referencia)
resultado[c("numero", "metodo_coincidencia", "epiteto_coincidente")]
#> # A tibble: 2 × 3
#>   numero metodo_coincidencia epiteto_coincidente
#>    <int> <chr>               <chr>              
#> 1      1 binomio_exacto      acreana            
#> 2    406 epiteto_difuso      magnifructa        
```
