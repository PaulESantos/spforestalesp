# Ejecutar desde la raíz del proyecto después de instalar spforestalesp,
# fuzzyjoin y wcvpdata (>= 0.7.0).
library(spforestalesp)

resultado <- conciliar_especies_serfor(max_dist = 1L, method = "osa")
dir.create("results", showWarnings = FALSE)
saveRDS(resultado, "results/conciliacion_serfor_wcvp.rds", compress = "xz")
utils::write.csv(resultado, "results/conciliacion_serfor_wcvp.csv",
                 row.names = FALSE, fileEncoding = "UTF-8", na = "")
print(table(resultado$estado_coincidencia, resultado$metodo_coincidencia,
            useNA = "ifany"))
