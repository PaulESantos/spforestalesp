# Ejecutar desde la raíz del proyecto después de renderizar README.qmd
# con: quarto render README.qmd --to gfm

# build_site_github_pages() no instala el paquete por defecto. La viñeta
# ejecuta library(spforestalesp), por lo que se requiere install = TRUE.
pkgdown::build_site_github_pages(install = TRUE, new_process = FALSE)

archivos <- c(
  "results/conciliacion_serfor_wcvp.rds",
  "results/conciliacion_serfor_wcvp.csv"
)
if (!all(file.exists(archivos))) {
  stop("Faltan resultados WCVP; ejecute data-raw/ejecutar_con_wcvp.R.")
}
dir.create("docs/results", recursive = TRUE, showWarnings = FALSE)
if (!all(file.copy(archivos, "docs/results", overwrite = TRUE))) {
  stop("No se pudieron copiar los resultados WCVP al sitio.")
}
