# ============================================================
# Ejecutar todas las pruebas de Unit-Weibull
#
# Desde la carpeta raiz del repositorio:
# source("tests/run_all_tests.R")
# ============================================================

cat("\n========================================\n")
cat("PRUEBAS DE FUNCIONES DE DISTRIBUCION\n")
cat("========================================\n")
source(file.path("tests", "test_dUW.R"))

cat("\n========================================\n")
cat("PRUEBAS DE FAMILIA GAMLSS\n")
cat("========================================\n")
source(file.path("tests", "test_UW.R"))

cat("\n========================================\n")
cat("TODAS LAS PRUEBAS TERMINARON SIN ERROR\n")
cat("========================================\n")
