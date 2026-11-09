# ============================================================
# VALIDACION EXTENDIDA DE PARAMETROS UNIT-WEIBULL
#
# Ejecutar desde la raiz:
# source("simulation/estudio_parametros_UW.R")
#
# Diseno factorial exploratorio 3 x 3:
# mu en {0.5, 1, 2}
# sigma en {0.5, 1, 1.5}
#
# Para cada combinacion se estudian n = 100, 300 y 800.
# Se calculan sesgo, ECM, RMSE, cobertura y convergencia.
# ============================================================

source("simulation/estudio_simulacion_UW.R")

grid_parametros_UW <- expand.grid(
  mu = c(0.5, 1, 2),
  sigma = c(0.5, 1, 1.5)
)

grid_parametros_UW$escenario <- paste0(
  "mu_", grid_parametros_UW$mu,
  "_sigma_", grid_parametros_UW$sigma
)

grid_parametros_UW <- grid_parametros_UW[
  , c("escenario", "mu", "sigma")
]

cat("\nDISENO FACTORIAL EXTENDIDO UNIT-WEIBULL\n")
print(grid_parametros_UW, row.names = FALSE)

# Ejecucion inicial: 50 replicas por combinacion.
# Total: 9 escenarios x 3 tamanos x 50 replicas = 1,350 ajustes.
resultado_parametros_UW <- ejecutar_monte_carlo_UW(
  B = 50,
  tamanos = c(100, 300, 800),
  escenarios = grid_parametros_UW,
  nivel = 0.95,
  semilla = 20261112,
  max_cycles = 100
)

if (!dir.exists("resultados_simulacion")) {
  dir.create("resultados_simulacion", recursive = TRUE)
}

utils::write.csv(
  grid_parametros_UW,
  file = "resultados_simulacion/diseno_factorial_UW.csv",
  row.names = FALSE
)

cat("\nESTUDIO EXTENDIDO TERMINADO\n")
cat("Resumen:", resultado_parametros_UW$archivo_resumen, "\n")
cat("Detalle:", resultado_parametros_UW$archivo_detalle, "\n")
cat("Diseno: resultados_simulacion/diseno_factorial_UW.csv\n")
