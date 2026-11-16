pkgname <- "spforestalesp"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
options(pager = "console")
library('spforestalesp')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("conciliar_especies_serfor")
### * conciliar_especies_serfor

flush(stderr()); flush(stdout())

### Name: conciliar_especies_serfor
### Title: Conciliar nombres de SERFOR con una referencia taxonómica
### Aliases: conciliar_especies_serfor

### ** Examples

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



cleanEx()
nameEx("datos_modelo_conciliacion")
### * datos_modelo_conciliacion

flush(stderr()); flush(stdout())

### Name: datos_modelo_conciliacion
### Title: Datos modelo para evaluar la conciliación taxonómica
### Aliases: serfor_modelo referencia_modelo resultado_modelo_esperado

### ** Examples

data(serfor_modelo)
data(referencia_modelo)
data(resultado_modelo_esperado)
resultado <- conciliar_especies_serfor(serfor_modelo, referencia_modelo)
all(vapply(c("estado_coincidencia", "metodo_coincidencia"), function(columna) {
  identical(resultado[[columna]], resultado_modelo_esperado[[columna]])
}, logical(1)))



### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
