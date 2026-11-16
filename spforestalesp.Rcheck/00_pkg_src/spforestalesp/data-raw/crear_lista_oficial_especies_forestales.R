# Ejecutar desde la raíz del paquete:
# source("data-raw/crear_lista_oficial_especies_forestales.R")

origen <- "raw-data/lista_oficial_especies_forestales.md"
destino <- "data/lista_oficial_especies_forestales.rda"

lineas <- readLines(origen, encoding = "UTF-8", warn = FALSE)
filas <- grep("^\\|[[:space:]]*[0-9]+[[:space:]]*\\|", lineas, value = TRUE)
contenido <- sub("^[[:space:]]*\\|", "", filas)
contenido <- sub("\\|[[:space:]]*$", "", contenido)
campos <- lapply(strsplit(contenido, "|", fixed = TRUE), trimws)

if (length(filas) != 734L || any(lengths(campos) != 5L)) {
  stop("El listado debe contener 734 filas de cinco columnas.")
}

matriz <- do.call(rbind, campos)
colnames(matriz) <- c(
  "numero", "especie", "familia", "nombre_comun", "nombre_comercial"
)

lista_oficial_especies_forestales <- as.data.frame(
  matriz, stringsAsFactors = FALSE
)
lista_oficial_especies_forestales$numero <- as.integer(
  lista_oficial_especies_forestales$numero
)

patron_nombre <- "^([^[:space:]]+)[[:space:]]+([^[:space:]]+)[[:space:]]+(.+)$"
partes <- regmatches(
  lista_oficial_especies_forestales$especie,
  regexec(patron_nombre, lista_oficial_especies_forestales$especie)
)
if (any(lengths(partes) != 4L)) {
  stop("Hay nombres científicos sin género, epíteto específico o autor.")
}
partes <- do.call(rbind, partes)
lista_oficial_especies_forestales$genero <- partes[, 2L]
lista_oficial_especies_forestales$epiteto_especifico <- partes[, 3L]
lista_oficial_especies_forestales$autor <- partes[, 4L]
lista_oficial_especies_forestales <- lista_oficial_especies_forestales[c(
  "numero", "especie", "genero", "epiteto_especifico", "autor",
  "familia", "nombre_comun", "nombre_comercial"
)]

if (!identical(lista_oficial_especies_forestales$numero, seq_len(734L))) {
  stop("La numeración del listado no coincide con 1:734.")
}

for (columna in c("nombre_comun", "nombre_comercial")) {
  valor <- lista_oficial_especies_forestales[[columna]]
  valor[valor %in% c("S.I.", "N.D.", "No registra", "")] <- NA_character_
  lista_oficial_especies_forestales[[columna]] <- valor
}

# Un tibble conserva las columnas de data.frame y añade estas dos clases.
# Esto permite generar el archivo incluso si tibble aún no está instalado.
class(lista_oficial_especies_forestales) <- c("tbl_df", "tbl", "data.frame")

dir.create("data", showWarnings = FALSE)
save(lista_oficial_especies_forestales, file = destino, compress = "xz")
