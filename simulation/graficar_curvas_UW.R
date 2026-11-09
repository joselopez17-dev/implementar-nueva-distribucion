# ============================================================
# GRAFICAS DE DENSIDAD Y DISTRIBUCION ACUMULADA: UNIT-WEIBULL
#
# Ejecutar desde la raiz del repositorio:
# source("simulation/graficar_curvas_UW.R")
#
# Genera archivos PNG y PDF en resultados_simulacion/.
# Los graficos usan el soporte abierto 0 < x < 1.
# ============================================================

if (!exists("dUW", mode = "function") ||
    !exists("pUW", mode = "function")) {
  source(file.path("R", "utils.R"))
  source(file.path("R", "dUW.R"))
}

escenarios_UW <- data.frame(
  escenario = c("A", "B", "C", "D"),
  mu = c(0.7, 1.5, 0.7, 1.5),
  sigma = c(1.5, 0.7, 0.7, 1.5)
)

# No se incluyen los extremos 0 y 1, pues el soporte es abierto.
x_grafica <- seq(0.0005, 0.999, length.out = 2000)

if (!dir.exists("resultados_simulacion")) {
  dir.create("resultados_simulacion", recursive = TRUE)
}

dibujar_densidades_UW <- function() {
  for (i in seq_len(nrow(escenarios_UW))) {
    mu_i <- escenarios_UW$mu[i]
    sigma_i <- escenarios_UW$sigma[i]
    densidad <- dUW(x_grafica, mu = mu_i, sigma = sigma_i)

    plot(
      x_grafica,
      densidad,
      type = "l",
      lwd = 2,
      xlim = c(0, 1),
      ylim = c(0, max(densidad[is.finite(densidad)], na.rm = TRUE) * 1.05),
      xlab = "x",
      ylab = "f(x)",
      main = paste0(
        "Escenario ", escenarios_UW$escenario[i],
        ": mu = ", mu_i, ", sigma = ", sigma_i
      )
    )
    abline(v = c(0, 1), lty = 3, col = "gray60")
  }
}

dibujar_CDF_UW <- function() {
  for (i in seq_len(nrow(escenarios_UW))) {
    mu_i <- escenarios_UW$mu[i]
    sigma_i <- escenarios_UW$sigma[i]
    acumulada <- pUW(x_grafica, mu = mu_i, sigma = sigma_i)

    plot(
      x_grafica,
      acumulada,
      type = "l",
      lwd = 2,
      ylim = c(0, 1),
      xlim = c(0, 1),
      xlab = "x",
      ylab = "F(x)",
      main = paste0(
        "Escenario ", escenarios_UW$escenario[i],
        ": mu = ", mu_i, ", sigma = ", sigma_i
      )
    )
    abline(h = c(0, 1), lty = 3, col = "gray60")
  }
}

marca <- format(Sys.time(), "%Y%m%d_%H%M%S")

archivo_densidad_png <- file.path(
  "resultados_simulacion",
  paste0("densidades_UW_", marca, ".png")
)
archivo_cdf_png <- file.path(
  "resultados_simulacion",
  paste0("CDF_UW_", marca, ".png")
)
archivo_densidad_pdf <- file.path(
  "resultados_simulacion",
  paste0("densidades_UW_", marca, ".pdf")
)
archivo_cdf_pdf <- file.path(
  "resultados_simulacion",
  paste0("CDF_UW_", marca, ".pdf")
)

# PNG de densidades
grDevices::png(
  filename = archivo_densidad_png,
  width = 1800,
  height = 1400,
  res = 180
)
par(mfrow = c(2, 2), mar = c(4.2, 4.2, 3.2, 1))
dibujar_densidades_UW()
grDevices::dev.off()

# PNG de funciones de distribucion acumulada
grDevices::png(
  filename = archivo_cdf_png,
  width = 1800,
  height = 1400,
  res = 180
)
par(mfrow = c(2, 2), mar = c(4.2, 4.2, 3.2, 1))
dibujar_CDF_UW()
grDevices::dev.off()

# Versiones PDF para el informe y el poster
grDevices::pdf(archivo_densidad_pdf, width = 11, height = 8.5)
par(mfrow = c(2, 2), mar = c(4.2, 4.2, 3.2, 1))
dibujar_densidades_UW()
grDevices::dev.off()

grDevices::pdf(archivo_cdf_pdf, width = 11, height = 8.5)
par(mfrow = c(2, 2), mar = c(4.2, 4.2, 3.2, 1))
dibujar_CDF_UW()
grDevices::dev.off()

# Guardar los valores graficados para reproducir o editar figuras.
curvas <- do.call(rbind, lapply(seq_len(nrow(escenarios_UW)), function(i) {
  data.frame(
    escenario = escenarios_UW$escenario[i],
    mu = escenarios_UW$mu[i],
    sigma = escenarios_UW$sigma[i],
    x = x_grafica,
    densidad = dUW(
      x_grafica,
      mu = escenarios_UW$mu[i],
      sigma = escenarios_UW$sigma[i]
    ),
    acumulada = pUW(
      x_grafica,
      mu = escenarios_UW$mu[i],
      sigma = escenarios_UW$sigma[i]
    )
  )
}))

archivo_curvas <- file.path(
  "resultados_simulacion",
  paste0("curvas_UW_", marca, ".csv")
)
utils::write.csv(curvas, archivo_curvas, row.names = FALSE)

cat("\nGRAFICAS UNIT-WEIBULL GENERADAS\n")
cat("Densidades PNG:", archivo_densidad_png, "\n")
cat("CDF PNG:", archivo_cdf_png, "\n")
cat("Densidades PDF:", archivo_densidad_pdf, "\n")
cat("CDF PDF:", archivo_cdf_pdf, "\n")
cat("Datos de curvas:", archivo_curvas, "\n")
