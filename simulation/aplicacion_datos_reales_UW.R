# ============================================================
# APLICACION DE UNIT-WEIBULL A DATOS REALES
#
# Dataset: GasolineYield del paquete betareg.
# Respuesta: yield, proporcion de crudo transformado en gasolina.
#
# Ejecutar desde la raiz:
# install.packages(c("betareg", "gamlss", "gamlss.dist"))
# source("simulation/aplicacion_datos_reales_UW.R")
#
# Analisis:
# 1) Verificar soporte (0,1) y describir la respuesta.
# 2) Comparar UW, GB1, LOGITNO, BE y BEo con modelo de intercepto.
# 3) Ajuste exploratorio con temperatura como predictor de mu.
# 4) Graficas de histograma/densidad y CDF empirica/CDF UW.
#
# IMPORTANTE: GasolineYield contiene 32 observaciones. Los resultados
# se interpretan como una aplicacion ilustrativa, no como validacion
# universal ni como prueba definitiva de superioridad.
# ============================================================

if (!requireNamespace("betareg", quietly = TRUE)) {
  stop(
    "Falta el paquete betareg. Ejecute install.packages('betareg') ",
    "y vuelva a correr este script."
  )
}
if (!requireNamespace("gamlss", quietly = TRUE) ||
    !requireNamespace("gamlss.dist", quietly = TRUE)) {
  stop("Instale gamlss y gamlss.dist antes de continuar.")
}

if (!exists("dUW", mode = "function") ||
    !exists("pUW", mode = "function") ||
    !exists("UW", mode = "function")) {
  source(file.path("R", "utils.R"))
  source(file.path("R", "dUW.R"))
  source(file.path("R", "UW.R"))
}

# Cargar datos documentados en el paquete betareg.
utils::data("GasolineYield", package = "betareg", envir = environment())
datos_gasolina <- GasolineYield

if (!all(c("yield", "temp") %in% names(datos_gasolina))) {
  stop("GasolineYield no contiene las columnas yield y temp esperadas.")
}

y <- datos_gasolina$yield

# Validacion estricta de la respuesta.
if (!is.numeric(y) || any(!is.finite(y)) ||
    any(y <= 0 | y >= 1)) {
  stop(
    "La respuesta yield debe ser numerica, completa y estar ",
    "estrictamente en (0,1). Revise los datos."
  )
}

cat("\nAPLICACION REAL: GASOLINE YIELD DE PRATER\n")
cat("Numero de observaciones:", length(y), "\n")
cat("Minimo:", min(y), "\n")
cat("Maximo:", max(y), "\n")
cat("Media:", mean(y), "\n")
cat("Mediana:", stats::median(y), "\n")
cat("Desviacion estandar:", stats::sd(y), "\n")
cat("Todos los valores estan en (0,1):",
    all(y > 0 & y < 1), "\n")

# Funcion auxiliar para ajustar y registrar advertencias.
.uw_ajustar_datos_reales <- function(
    formula,
    datos,
    familia,
    max_cycles = 1000) {

  advertencias <- character(0)
  error_texto <- NA_character_

  ajuste <- withCallingHandlers(
    tryCatch(
      gamlss::gamlss(
        formula = formula,
        sigma.fo = ~ 1,
        family = familia,
        data = datos,
        control = gamlss::gamlss.control(
          n.cyc = max_cycles,
          trace = FALSE
        )
      ),
      error = function(e) {
        error_texto <<- conditionMessage(e)
        NULL
      }
    ),
    warning = function(w) {
      advertencias <<- c(advertencias, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )

  no_convergio <- any(grepl(
    "Algorithm RS has not yet converged",
    advertencias,
    fixed = TRUE
  ))

  convergio <- !is.null(ajuste) && !no_convergio
  if (!is.null(ajuste) && !is.null(ajuste$converged)) {
    convergio <- convergio && isTRUE(ajuste$converged)
  }

  list(
    ajuste = ajuste,
    convergencia = convergio,
    error = error_texto,
    advertencias = paste(unique(advertencias), collapse = " | ")
  )
}

familias_reales <- list(
  UW = UW(),
  GB1 = gamlss.dist::GB1(),
  LOGITNO = gamlss.dist::LOGITNO(),
  BE = gamlss.dist::BE(),
  BEo = gamlss.dist::BEo()
)

# Comparacion 1: modelo de distribucion sin covariables.
# Todos los modelos usan las mismas 32 observaciones.
cat("\nAJUSTE DE INTERCEPTO: COMPARACION DE DISTRIBUCIONES\n")

ajustes_intercepto <- lapply(
  familias_reales,
  function(fam) .uw_ajustar_datos_reales(
    formula = yield ~ 1,
    datos = datos_gasolina,
    familia = fam,
    max_cycles = 1000
  )
)

tabla_intercepto <- do.call(rbind, lapply(
  names(ajustes_intercepto),
  function(nombre) {
    salida <- ajustes_intercepto[[nombre]]
    ajuste <- salida$ajuste

    data.frame(
      familia = nombre,
      convergencia = salida$convergencia,
      AIC = if (!is.null(ajuste) && salida$convergencia) ajuste$aic else NA_real_,
      BIC_SBC = if (!is.null(ajuste) && salida$convergencia) ajuste$sbc else NA_real_,
      iteraciones = if (!is.null(ajuste)) ajuste$iter else NA_integer_,
      error = salida$error,
      advertencias = salida$advertencias,
      stringsAsFactors = FALSE
    )
  }
))

cat("\nRESULTADOS MODELOS DE INTERCEPTO\n")
print(tabla_intercepto, row.names = FALSE)

# Estimaciones de parametros de UW para el modelo de intercepto.
ajuste_UW_intercepto <- ajustes_intercepto$UW$ajuste
if (is.null(ajuste_UW_intercepto) ||
    !ajustes_intercepto$UW$convergencia) {
  stop("El ajuste de intercepto UW no convergio; revise las advertencias.")
}

mu_hat <- as.numeric(
  stats::fitted(ajuste_UW_intercepto, what = "mu")[1]
)
sigma_hat <- as.numeric(
  stats::fitted(ajuste_UW_intercepto, what = "sigma")[1]
)

cat("\nPARAMETROS UW ESTIMADOS EN GASOLINE YIELD\n")
cat("mu estimado:", mu_hat, "\n")
cat("sigma estimado:", sigma_hat, "\n")

# Comparacion 2: incorporar temperatura como predictor lineal
# del parametro mu para todas las familias. sigma permanece
# con intercepto. Es un analisis exploratorio por n = 32.
cat("\nAJUSTE EXPLORATORIO CON TEMPERATURA COMO PREDICTOR DE mu\n")

ajustes_temperatura <- lapply(
  familias_reales,
  function(fam) .uw_ajustar_datos_reales(
    formula = yield ~ temp,
    datos = datos_gasolina,
    familia = fam,
    max_cycles = 1000
  )
)

tabla_temperatura <- do.call(rbind, lapply(
  names(ajustes_temperatura),
  function(nombre) {
    salida <- ajustes_temperatura[[nombre]]
    ajuste <- salida$ajuste

    data.frame(
      familia = nombre,
      convergencia = salida$convergencia,
      AIC = if (!is.null(ajuste) && salida$convergencia) ajuste$aic else NA_real_,
      BIC_SBC = if (!is.null(ajuste) && salida$convergencia) ajuste$sbc else NA_real_,
      iteraciones = if (!is.null(ajuste)) ajuste$iter else NA_integer_,
      error = salida$error,
      advertencias = salida$advertencias,
      stringsAsFactors = FALSE
    )
  }
))

cat("\nRESULTADOS MODELOS CON TEMPERATURA\n")
print(tabla_temperatura, row.names = FALSE)

# Graficas del modelo UW de intercepto.
x_grid <- seq(0.001, 0.999, length.out = 1500)
densidad_uw <- dUW(x_grid, mu = mu_hat, sigma = sigma_hat)
cdf_uw <- pUW(x_grid, mu = mu_hat, sigma = sigma_hat)

if (!dir.exists("resultados_simulacion")) {
  dir.create("resultados_simulacion", recursive = TRUE)
}

marca <- format(Sys.time(), "%Y%m%d_%H%M%S")

archivo_densidad <- file.path(
  "resultados_simulacion",
  paste0("aplicacion_GasolineYield_densidad_UW_", marca, ".png")
)
archivo_cdf <- file.path(
  "resultados_simulacion",
  paste0("aplicacion_GasolineYield_CDF_UW_", marca, ".png")
)

grDevices::png(archivo_densidad, width = 1500, height = 1000, res = 160)
hist(
  y,
  breaks = "FD",
  probability = TRUE,
  xlim = c(0, 1),
  main = "Gasoline Yield: densidad ajustada Unit-Weibull",
  xlab = "Proporcion de crudo convertida en gasolina",
  ylab = "Densidad"
)
lines(x_grid, densidad_uw, lwd = 2)
legend(
  "topright",
  legend = c("Histograma", "Densidad UW ajustada"),
  lty = c(NA, 1),
  pch = c(15, NA),
  bty = "n"
)
grDevices::dev.off()

grDevices::png(archivo_cdf, width = 1500, height = 1000, res = 160)
plot(
  stats::ecdf(y),
  do.points = TRUE,
  verticals = TRUE,
  xlim = c(0, 1),
  ylim = c(0, 1),
  main = "Gasoline Yield: CDF empirica y Unit-Weibull ajustada",
  xlab = "Proporcion de crudo convertida en gasolina",
  ylab = "F(x)"
)
lines(x_grid, cdf_uw, lwd = 2)
legend(
  "topleft",
  legend = c("CDF empirica", "CDF UW ajustada"),
  lty = c(1, 1),
  bty = "n"
)
grDevices::dev.off()

# Exportar tablas y datos para trazabilidad.
utils::write.csv(
  datos_gasolina,
  file.path("resultados_simulacion",
            paste0("GasolineYield_datos_", marca, ".csv")),
  row.names = FALSE
)
utils::write.csv(
  tabla_intercepto,
  file.path("resultados_simulacion",
            paste0("GasolineYield_comparacion_intercepto_", marca, ".csv")),
  row.names = FALSE
)
utils::write.csv(
  tabla_temperatura,
  file.path("resultados_simulacion",
            paste0("GasolineYield_comparacion_temperatura_", marca, ".csv")),
  row.names = FALSE
)
utils::write.csv(
  data.frame(
    x = x_grid,
    densidad_UW = densidad_uw,
    CDF_UW = cdf_uw
  ),
  file.path("resultados_simulacion",
            paste0("GasolineYield_curvas_UW_", marca, ".csv")),
  row.names = FALSE
)

cat("\nAPLICACION REAL TERMINADA\n")
cat("Grafica densidad:", archivo_densidad, "\n")
cat("Grafica CDF:", archivo_cdf, "\n")
cat("Tablas y datos guardados en resultados_simulacion/.\n")
