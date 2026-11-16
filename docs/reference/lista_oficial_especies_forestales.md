# Lista oficial de especies forestales del Perú

Listado de 734 registros del anexo de SERFOR incluido en
`raw-data/lista_oficial_especies_forestales.md`.

## Usage

``` r
data(lista_oficial_especies_forestales)
```

## Format

Un tibble de 734 filas y ocho columnas:

- numero:

  Número de orden, entero.

- especie:

  Nombre científico completo, incluida la autoría.

- genero:

  Género botánico.

- epiteto_especifico:

  Epíteto específico.

- autor:

  Autoría científica, incluida la parte entre paréntesis cuando existe.

- familia:

  Familia botánica.

- nombre_comun:

  Nombre o nombres comunes, separados por comas cuando corresponde.

- nombre_comercial:

  Nombre comercial de la madera.

Las marcas `S.I.`, `N.D.` y `No registra` se representan como `NA` en
las dos columnas de nombres comunes y comerciales.

## Source

SERFOR, Lista Oficial de Especies Forestales, anexo reproducido en
`raw-data/lista_oficial_especies_forestales.md`.
