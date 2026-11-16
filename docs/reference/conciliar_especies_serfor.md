# Conciliar nombres de SERFOR con una referencia taxonómica

Concilia la lista de SERFOR con un backbone taxonómico mediante
coincidencia exacta del binomio, género difuso con epíteto exacto,
variante de terminación y epíteto difuso dentro del género. Las etapas
difusas usan
[`fuzzyjoin::stringdist_inner_join()`](https://rdrr.io/pkg/fuzzyjoin/man/stringdist_join.html).

## Usage

``` r
conciliar_especies_serfor(serfor = NULL, target_df = NULL,
                         max_dist = 1L, method = "osa")
```

## Arguments

- serfor:

  Tabla con `numero`, `genero`, `epiteto_especifico` y `autor`. Por
  defecto, usa la lista incluida en el paquete.

- target_df:

  Referencia con `genus` y `species`. Puede incluir `taxon_authors`,
  `taxon_status`, `taxon_name`, `plant_name_id` y
  `accepted_plant_name_id`. Por defecto, usa `wcvpdata` (versión 0.7.0 o
  posterior).

- max_dist:

  Distancia máxima entera y no negativa para las etapas difusas.

- method:

  Método de distancia de `stringdist` usado por `fuzzyjoin`. El valor
  predeterminado es `osa`.

## Details

Solo se consideran registros de especie de la referencia. Para epítetos
de siete caracteres o menos, la etapa difusa exige igual longitud. Los
empates quedan como `ambiguo`; los candidatos se conservan en el
atributo `candidatos_ambiguos`. La coincidencia de autoría ignora
diferencias de espacios y mayúsculas y se usa para distinguir registros
con el mismo binomio. Una autoría diferente queda indicada en
`autor_coincide`, pero no invalida por sí sola un binomio único. El
orden completo de etapas se documenta en
[`vignette("metodologia-conciliacion", package = "spforestalesp")`](https://paulesantos.github.io/spforestalesp/articles/metodologia-conciliacion.md).
Un nombre aceptado solo se informa cuando puede resolverse mediante los
identificadores de la referencia.

## Value

Un tibble de una fila por registro de SERFOR con `estado_coincidencia`
(`coincidencia`, `ambiguo` o `sin_coincidencia`), `metodo_coincidencia`,
nombres coincidentes, distancias y, cuando existen, autoría, estado
taxonómico y nombre aceptado. El atributo `candidatos_ambiguos` guarda
los candidatos empatados.

## Examples

``` r
data(lista_oficial_especies_forestales)
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
