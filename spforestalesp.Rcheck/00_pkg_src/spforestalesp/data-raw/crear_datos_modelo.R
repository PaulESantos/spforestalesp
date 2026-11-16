# Ejecutar desde la raíz del paquete:
# source("data-raw/crear_datos_modelo.R")

genero <- c(
  "Abarema", "Abarema", "Abaremaa", "Trema", "Moquilea", "Abarema",
  "Cidea", "Abarema", "Nada", "Alchornea", "Oldia", "Abarema"
)
epiteto <- c(
  "acreana", "acreana", "auriculata", "micrantha", "magnifruta", "acrea",
  "alba", "abcc", "inexistens", "glandulosa", "alba", "acreana"
)
autor <- c(
  "Autor A", "Autor A", "Autor C", "(L.) Blume", "Sothers & Prance",
  "Autor X", "Autor X", "Autor X", "Autor X", "Autor X", "Autor S", "Autor B"
)

serfor_modelo <- tibble::tibble(
  numero = seq_along(genero),
  especie = paste(genero, epiteto, autor),
  genero = genero,
  epiteto_especifico = epiteto,
  autor = autor,
  familia = NA_character_,
  nombre_comun = NA_character_,
  nombre_comercial = NA_character_
)

referencia_modelo <- tibble::tibble(
  plant_name_id = 101:114,
  genus = c(
    "Abarema", "Abarema", "Abarema", "Trema", "Moquilea",
    "Abarema", "Abarema", "Cideb", "Cidec", "Alchornea",
    "Alchornea", "Oldia", "Newia", "Abarema"
  ),
  species = c(
    "acreana", "acreana", "auriculata", "micranthum", "magnifructa",
    "abca", "abcb", "alba", "alba", "glandulosa", "glandulosa",
    "alba", "alba", "acreana"
  ),
  taxon_authors = c(
    "Autor A", "Autor B", "Autor C", "(L.) Blume", "Sothers & Prance",
    "Autor Y", "Autor Z", "Autor D", "Autor E", "Autor P", "Autor Q",
    "Autor S", "Autor N", "Autor A"
  ),
  taxon_status = c(
    rep("Accepted", 10), "Invalid", "Synonym", "Accepted", "Accepted"
  ),
  accepted_plant_name_id = c(
    rep(NA_integer_, 11), 113L, NA_integer_, NA_integer_
  ),
  taxon_rank = c(rep("Species", 13), "Variety"),
  infraspecific_rank = c(rep(NA_character_, 13), "var."),
  taxon_name = c(
    "Abarema acreana", "Abarema acreana", "Abarema auriculata",
    "Trema micranthum", "Moquilea magnifructa", "Abarema abca",
    "Abarema abcb", "Cideb alba", "Cidec alba",
    "Alchornea glandulosa", "Alchornea glandulosa", "Oldia alba",
    "Newia alba", "Abarema acreana var. minor"
  )
)

resultado_modelo_esperado <- tibble::tibble(
  numero = 1:12,
  estado_coincidencia = c(
    rep("coincidencia", 5), "sin_coincidencia", "ambiguo", "ambiguo",
    "sin_coincidencia", "ambiguo", "coincidencia", "coincidencia"
  ),
  metodo_coincidencia = c(
    "binomio_exacto", "binomio_exacto", "genero_difuso_epiteto_exacto",
    "variante_terminacion", "epiteto_difuso", NA_character_,
    "genero_difuso", "epiteto_difuso", NA_character_,
    "binomio_exacto", "binomio_exacto", "binomio_exacto"
  ),
  id_referencia = c(
    "101", "101", "103", "104", "105", NA_character_, NA_character_,
    NA_character_, NA_character_, NA_character_, "112", "102"
  ),
  nombre_aceptado = c(
    "Abarema acreana", "Abarema acreana", "Abarema auriculata",
    "Trema micranthum", "Moquilea magnifructa", rep(NA_character_, 5),
    "Newia alba", "Abarema acreana"
  )
)

dir.create("data", showWarnings = FALSE)
save(serfor_modelo, file = "data/serfor_modelo.rda", compress = "xz")
save(referencia_modelo, file = "data/referencia_modelo.rda", compress = "xz")
save(resultado_modelo_esperado,
     file = "data/resultado_modelo_esperado.rda", compress = "xz")
