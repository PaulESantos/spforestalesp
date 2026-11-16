#' Conciliar nombres de SERFOR con una referencia taxonomica
#'
#' Aplica, en orden, binomio exacto, genero difuso con epiteto exacto,
#' variante de terminacion y epiteto difuso dentro del genero. Las
#' coincidencias empatadas quedan marcadas como ambiguas.
#'
#' @param serfor Tibble con las columnas `numero`, `genero`,
#'   `epiteto_especifico` y `autor`. Por defecto usa los datos del paquete.
#' @param target_df Referencia con `genus` y `species`; puede incluir
#'   `taxon_authors`, `taxon_status`, `taxon_name`, `plant_name_id` y
#'   `accepted_plant_name_id`. Si es `NULL`, usa `wcvpdata` (>= 0.7.0).
#' @param max_dist Distancia maxima para genero y epiteto difusos.
#' @param method Metodo de distancia de `stringdist` usado por `fuzzyjoin`.
#' @details Solo se consideran especies de la referencia. La coincidencia
#'   de autoria ignora diferencias de espacios y mayusculas y permite
#'   distinguir registros que comparten un binomio. Una autoria diferente
#'   queda indicada en `autor_coincide`; no invalida por si sola un binomio
#'   unico. Los epitetos de hasta siete caracteres solo se comparan de forma
#'   difusa con candidatos de igual longitud. Consulte
#'   `vignette("metodologia-conciliacion", package = "spforestalesp")` para el
#'   orden completo de etapas.
#' @return Tibble de una fila por registro de SERFOR, con
#'   `estado_coincidencia` (`coincidencia`, `ambiguo` o `sin_coincidencia`),
#'   `metodo_coincidencia`, nombres coincidentes, distancias y, si la
#'   referencia lo permite, autoria, estado taxonomico y nombre aceptado.
#'   El atributo `candidatos_ambiguos` guarda los candidatos empatados.
#' @examples
#' data("lista_oficial_especies_forestales")
#' serfor_ejemplo <- lista_oficial_especies_forestales[
#'   lista_oficial_especies_forestales$numero %in% c(1L, 406L),
#' ]
#' referencia <- data.frame(
#'   genus = c("Abarema", "Moquilea"),
#'   species = c("acreana", "magnifructa")
#' )
#' resultado <- conciliar_especies_serfor(serfor_ejemplo, referencia)
#' resultado[c("numero", "metodo_coincidencia", "epiteto_coincidente")]
#' @export
conciliar_especies_serfor <- function(serfor = NULL, target_df = NULL,
                                     max_dist = 1L, method = "osa") {
  if (is.null(serfor)) {
    datos <- new.env(parent = emptyenv())
    utils::data("lista_oficial_especies_forestales", package = "spforestalesp",
                envir = datos)
    serfor <- datos$lista_oficial_especies_forestales
  }
  if (is.null(target_df)) {
    if (!requireNamespace("wcvpdata", quietly = TRUE) ||
        utils::packageVersion("wcvpdata") < "0.7.0") {
      stop("Instale wcvpdata (>= 0.7.0) o proporcione target_df.")
    }
    target_df <- getExportedValue("wcvpdata", "wcvp_matching_names")(
      as_data_frame = TRUE,
      columns = c("plant_name_id", "taxon_rank", "taxon_status", "family",
                  "genus", "species", "infraspecific_rank", "infraspecies",
                  "taxon_name", "taxon_authors", "accepted_plant_name_id")
    )
  }
  if (!is.data.frame(serfor) ||
      !all(c("numero", "genero", "epiteto_especifico", "autor") %in% names(serfor))) {
    stop("serfor debe contener numero, genero, epiteto_especifico y autor.")
  }
  if (!is.data.frame(target_df) ||
      !all(c("genus", "species") %in% names(target_df))) {
    stop("target_df debe contener genus y species.")
  }
  if (length(max_dist) != 1L || is.na(max_dist) || max_dist < 0 ||
      max_dist != as.integer(max_dist)) {
    stop("max_dist debe ser un entero no negativo.")
  }
  if (length(method) != 1L || is.na(method) || !nzchar(method)) {
    stop("method debe ser un metodo de distancia valido.")
  }

  entrada <- as.data.frame(serfor, stringsAsFactors = FALSE)
  referencia <- as.data.frame(target_df, stringsAsFactors = FALSE)
  for (columna in c("genus", "species")) {
    referencia[[columna]] <- trimws(as.character(referencia[[columna]]))
  }
  referencia <- referencia[
    !is.na(referencia$genus) & nzchar(referencia$genus) &
      !is.na(referencia$species) & nzchar(referencia$species), , drop = FALSE
  ]
  if ("taxon_rank" %in% names(referencia)) {
    referencia <- referencia[
      !is.na(referencia$taxon_rank) &
        tolower(as.character(referencia$taxon_rank)) == "species", , drop = FALSE
    ]
  }
  if ("infraspecific_rank" %in% names(referencia)) {
    referencia <- referencia[
      is.na(referencia$infraspecific_rank) |
        !nzchar(trimws(as.character(referencia$infraspecific_rank))), , drop = FALSE
    ]
  }
  if (nrow(referencia) == 0L) stop("La referencia no contiene nombres a nivel de especie.")

  clave <- function(genero, epiteto) paste(genero, epiteto, sep = "\r")
  claves <- unique(referencia[c("genus", "species")])
  claves$clave <- clave(claves$genus, claves$species)
  generos <- unique(claves$genus)
  n <- nrow(entrada)
  entrada$genero_coincidente <- rep(NA_character_, n)
  entrada$epiteto_coincidente <- rep(NA_character_, n)
  entrada$metodo_coincidencia <- rep(NA_character_, n)
  entrada$distancia_genero <- rep(NA_real_, n)
  entrada$distancia_epiteto <- rep(NA_real_, n)
  entrada$estado_coincidencia <- rep("sin_coincidencia", n)
  entrada$autor_coincide <- rep(NA, n)
  entrada$autor_referencia <- rep(NA_character_, n)
  entrada$estado_taxonomico <- rep(NA_character_, n)
  entrada$id_referencia <- rep(NA_character_, n)
  entrada$id_aceptado <- rep(NA_character_, n)
  entrada$nombre_aceptado <- rep(NA_character_, n)
  ambiguos <- list()

  asignar <- function(i, genero, epiteto, metodo, distancia_g = 0, distancia_e = 0) {
    entrada$genero_coincidente[i] <<- genero
    entrada$epiteto_coincidente[i] <<- epiteto
    entrada$metodo_coincidencia[i] <<- metodo
    entrada$distancia_genero[i] <<- distancia_g
    entrada$distancia_epiteto[i] <<- distancia_e
    entrada$estado_coincidencia[i] <<- "coincidencia"
  }
  registrar_ambiguedad <- function(i, candidatos, etapa) {
    entrada$estado_coincidencia[i] <<- "ambiguo"
    entrada$metodo_coincidencia[i] <<- etapa
    ambiguos[[as.character(i)]] <<- tibble::as_tibble(candidatos)
  }

  # El binomio exacto se resuelve antes de usar distancias.
  indice <- match(clave(entrada$genero, entrada$epiteto_especifico), claves$clave)
  exactos <- which(!is.na(indice))
  for (i in exactos) {
    asignar(i, claves$genus[indice[i]], claves$species[indice[i]], "binomio_exacto")
  }

  # Genero exacto o, si falta, distancia minima entre generos distintos.
  genero_objetivo <- rep(NA_character_, n)
  distancia_g <- rep(NA_real_, n)
  pendientes <- which(is.na(indice))
  genero_exacto <- pendientes[entrada$genero[pendientes] %in% generos]
  genero_objetivo[genero_exacto] <- entrada$genero[genero_exacto]
  distancia_g[genero_exacto] <- 0
  genero_difuso <- setdiff(pendientes, genero_exacto)
  if (length(genero_difuso)) {
    origenes <- unique(entrada$genero[genero_difuso])
    origenes <- origenes[!is.na(origenes) & nzchar(origenes)]
    if (length(origenes)) {
      candidatos_g <- fuzzyjoin::stringdist_inner_join(
        data.frame(origen = origenes), data.frame(destino = generos),
        by = c("origen" = "destino"), max_dist = max_dist,
        method = method, distance_col = "distancia"
      )
      for (i in genero_difuso) {
        cg <- candidatos_g[candidatos_g$origen == entrada$genero[i], , drop = FALSE]
        if (!nrow(cg)) next
        cg <- cg[cg$distancia == min(cg$distancia), , drop = FALSE]
        if (nrow(cg) > 1L) {
          con_epiteto <- cg$destino[
            clave(cg$destino, entrada$epiteto_especifico[i]) %in% claves$clave
          ]
          if (length(con_epiteto) == 1L) cg <- cg[cg$destino == con_epiteto, , drop = FALSE]
        }
        if (nrow(cg) == 1L) {
          genero_objetivo[i] <- cg$destino
          distancia_g[i] <- cg$distancia
        } else {
          registrar_ambiguedad(i, cg, "genero_difuso")
        }
      }
    }
  }

  # Epiteto exacto dentro del genero resuelto.
  pendientes <- which(is.na(indice) & !is.na(genero_objetivo))
  for (i in pendientes) {
    k <- match(clave(genero_objetivo[i], entrada$epiteto_especifico[i]), claves$clave)
    if (!is.na(k)) {
      metodo <- if (distancia_g[i] == 0) "binomio_exacto" else "genero_difuso_epiteto_exacto"
      asignar(i, claves$genus[k], claves$species[k], metodo, distancia_g[i])
    }
  }

  # Variantes de terminacion: solo si la raiz identifica una especie unica.
  raiz <- function(x) {
    resultado <- sub("(ae|is|um|us|a|i)$", "", x)
    resultado[is.na(x) | resultado == x | nchar(resultado) < 3L] <- NA_character_
    resultado
  }
  claves$raiz <- raiz(claves$species)
  pendientes <- which(entrada$estado_coincidencia == "sin_coincidencia" &
                       !is.na(genero_objetivo))
  for (i in pendientes) {
    r <- raiz(entrada$epiteto_especifico[i])
    if (is.na(r)) next
    cand <- claves[claves$genus == genero_objetivo[i] & !is.na(claves$raiz) &
                     claves$raiz == r, , drop = FALSE]
    if (nrow(cand) == 1L) {
      asignar(i, cand$genus, cand$species, "variante_terminacion",
              distancia_g[i], NA_real_)
    }
  }

  # fuzzyjoin compara epitetos solamente con candidatos del mismo genero.
  pendientes <- which(entrada$estado_coincidencia == "sin_coincidencia" &
                       !is.na(genero_objetivo))
  for (g in unique(genero_objetivo[pendientes])) {
    filas <- pendientes[genero_objetivo[pendientes] == g]
    candidatos <- claves[claves$genus == g, c("species"), drop = FALSE]
    nombres <- data.frame(fila = filas, epiteto = entrada$epiteto_especifico[filas])
    nombres <- nombres[!is.na(nombres$epiteto) & nzchar(nombres$epiteto), , drop = FALSE]
    if (!nrow(nombres)) next
    pares <- fuzzyjoin::stringdist_inner_join(
      nombres, candidatos, by = c("epiteto" = "species"),
      max_dist = max_dist, method = method, distance_col = "distancia"
    )
    if (!nrow(pares)) next
    pares <- pares[!(nchar(pares$epiteto) <= 7L &
                       nchar(pares$epiteto) != nchar(pares$species)), , drop = FALSE]
    for (i in unique(pares$fila)) {
      cand <- pares[pares$fila == i, , drop = FALSE]
      cand <- cand[cand$distancia == min(cand$distancia), , drop = FALSE]
      if (nrow(cand) == 1L) {
        asignar(i, g, cand$species, "epiteto_difuso", distancia_g[i], cand$distancia)
      } else {
        registrar_ambiguedad(i, cand, "epiteto_difuso")
      }
    }
  }

  # Asociar el registro WCVP; usar la autoria para deshacer homonimos.
  normalizar_autor <- function(x) {
    gsub("[[:space:]]+", "", tolower(as.character(x)))
  }
  if (!"taxon_authors" %in% names(referencia)) referencia$taxon_authors <- NA_character_
  if (!"taxon_status" %in% names(referencia)) referencia$taxon_status <- NA_character_
  if (!"plant_name_id" %in% names(referencia)) referencia$plant_name_id <- NA_character_
  if (!"accepted_plant_name_id" %in% names(referencia)) referencia$accepted_plant_name_id <- NA_character_
  if (!"taxon_name" %in% names(referencia)) {
    referencia$taxon_name <- paste(referencia$genus, referencia$species)
  }
  referencia$clave <- clave(referencia$genus, referencia$species)
  coincidencias <- which(entrada$estado_coincidencia == "coincidencia")
  claves_observadas <- unique(clave(
    entrada$genero_coincidente[coincidencias],
    entrada$epiteto_coincidente[coincidencias]
  ))
  filas_metadatos <- which(referencia$clave %in% claves_observadas)
  indices_por_clave <- split(filas_metadatos, referencia$clave[filas_metadatos])
  for (i in coincidencias) {
    k <- clave(entrada$genero_coincidente[i], entrada$epiteto_coincidente[i])
    cand <- referencia[indices_por_clave[[k]], , drop = FALSE]
    autores_iguales <- !is.na(cand$taxon_authors) & !is.na(entrada$autor[i]) &
      normalizar_autor(cand$taxon_authors) == normalizar_autor(entrada$autor[i])
    if (sum(autores_iguales) == 1L) cand <- cand[autores_iguales, , drop = FALSE]
    if (nrow(cand) != 1L) {
      registrar_ambiguedad(i, cand, entrada$metodo_coincidencia[i])
      next
    }
    entrada$autor_referencia[i] <- as.character(cand$taxon_authors)
    entrada$autor_coincide[i] <- !is.na(cand$taxon_authors) && !is.na(entrada$autor[i]) &&
      normalizar_autor(cand$taxon_authors) == normalizar_autor(entrada$autor[i])
    entrada$estado_taxonomico[i] <- as.character(cand$taxon_status)
    entrada$id_referencia[i] <- as.character(cand$plant_name_id)
    id_aceptado <- cand$accepted_plant_name_id
    if (is.na(id_aceptado) && isTRUE(tolower(as.character(cand$taxon_status)) == "accepted")) {
      id_aceptado <- cand$plant_name_id
    }
    entrada$id_aceptado[i] <- as.character(id_aceptado)
  }
  if (any(!is.na(entrada$id_aceptado))) {
    ids <- as.character(referencia$plant_name_id)
    indice_aceptado <- match(entrada$id_aceptado, ids)
    valido <- which(!is.na(indice_aceptado))
    entrada$nombre_aceptado[valido] <- as.character(
      referencia$taxon_name[indice_aceptado[valido]]
    )
  }

  salida <- tibble::as_tibble(entrada)
  attr(salida, "candidatos_ambiguos") <- ambiguos
  salida
}
