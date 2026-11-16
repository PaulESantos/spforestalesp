library(spforestalesp)

entrada <- data.frame(
  numero = 1:8,
  genero = c("Abarema", "Abaremaa", "Abarema", "Abarema",
             "Abarema", "Cidea", "Abarema", "Nada"),
  epiteto_especifico = c("acreana", "auriculata", "acreanus", "acrenab",
                         "acrea", "alba", "acreana", "inexistens"),
  autor = c("Autor A", "Autor B", NA, NA, NA, NA, "Autor B", NA)
)
referencia <- data.frame(
  genus = c("Abarema", "Abarema", "Abarema", "Abarema", "Cideb", "Cidec"),
  species = c("acreana", "auriculata", "acreana", "acrenaa", "alba", "alba"),
  taxon_authors = c("Autor A", "Autor B", "Autor B", "Autor C", "Autor D", "Autor E"),
  taxon_status = c("Synonym", "Accepted", "Accepted", "Accepted", "Accepted", "Accepted"),
  plant_name_id = 1:6,
  accepted_plant_name_id = c(2L, NA, NA, NA, NA, NA)
)

salida <- conciliar_especies_serfor(entrada, referencia, max_dist = 1)
stopifnot(
  inherits(salida, "tbl_df"), nrow(salida) == nrow(entrada),
  identical(salida$metodo_coincidencia[1], "binomio_exacto"),
  identical(salida$nombre_aceptado[1], "Abarema auriculata"),
  identical(salida$metodo_coincidencia[2], "genero_difuso_epiteto_exacto"),
  identical(salida$metodo_coincidencia[3], "variante_terminacion"),
  identical(salida$metodo_coincidencia[4], "epiteto_difuso"),
  identical(salida$estado_coincidencia[5], "sin_coincidencia"),
  identical(salida$estado_coincidencia[6], "ambiguo"),
  identical(salida$id_referencia[7], "3"),
  identical(salida$estado_coincidencia[8], "sin_coincidencia")
)

empates <- data.frame(
  numero = 1:2,
  genero = c("Cidea", "Abarema"),
  epiteto_especifico = c("alba", "abcc"),
  autor = NA_character_
)
referencia_empates <- data.frame(
  genus = c("Cideb", "Cidec", "Abarema", "Abarema"),
  species = c("alba", "beta", "abca", "abcb")
)
salida_empates <- conciliar_especies_serfor(empates, referencia_empates)
stopifnot(
  identical(salida_empates$genero_coincidente[1], "Cideb"),
  identical(salida_empates$metodo_coincidencia[1], "genero_difuso_epiteto_exacto"),
  identical(salida_empates$estado_coincidencia[2], "ambiguo"),
  nrow(attr(salida_empates, "candidatos_ambiguos")[["2"]]) == 2L
)

origen <- new.env(parent = emptyenv())
data("lista_oficial_especies_forestales", package = "spforestalesp",
     envir = origen)
serfor <- origen$lista_oficial_especies_forestales
referencia_serfor <- unique(data.frame(
  genus = serfor$genero,
  species = serfor$epiteto_especifico,
  taxon_authors = serfor$autor
))
resultado_completo <- conciliar_especies_serfor(serfor, referencia_serfor)
stopifnot(
  nrow(resultado_completo) == 734L,
  all(resultado_completo$estado_coincidencia == "coincidencia"),
  all(resultado_completo$metodo_coincidencia == "binomio_exacto"),
  all(resultado_completo$autor_coincide)
)

modelo <- new.env(parent = emptyenv())
for (archivo in c("serfor_modelo", "referencia_modelo",
                  "resultado_modelo_esperado")) {
  data(list = archivo, package = "spforestalesp", envir = modelo)
}
resultado_modelo <- conciliar_especies_serfor(
  modelo$serfor_modelo, modelo$referencia_modelo
)
esperado <- modelo$resultado_modelo_esperado
for (columna in setdiff(names(esperado), "numero")) {
  stopifnot(identical(resultado_modelo[[columna]], esperado[[columna]]))
}
stopifnot(
  identical(resultado_modelo$numero, esperado$numero),
  length(attr(resultado_modelo, "candidatos_ambiguos")) == 3L,
  is.na(resultado_modelo$distancia_epiteto[4L])
)
