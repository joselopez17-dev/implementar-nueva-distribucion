# ============================================================
# Ejemplo de uso de la familia UW dentro de GAMLSS
#
# Ejecutar desde la carpeta raiz:
# source("R/utils.R")
# source("R/dUW.R")
# source("R/UW.R")
# source("R/examples_UW.R")
#
# Este ejemplo debe ejecutarse en RStudio con gamlss y
# gamlss.dist instalados. No sustituye las pruebas formales.
# ============================================================

if (!requireNamespace("gamlss", quietly = TRUE)) {
  stop("Instale el paquete gamlss.")
}

if (!exists(".uw_recycle_args", mode = "function")) {
  source(file.path("R", "utils.R"))
}
if (!exists("dUW", mode = "function")) {
  source(file.path("R", "dUW.R"))
}
if (!exists("UW", mode = "function")) {
  source(file.path("R", "UW.R"))
}

library(gamlss.dist)

# Generar una muestra conocida
set.seed(2026)
mu_real <- 0.7
sigma_real <- 1.5
n <- 1000

datos <- data.frame(
  x = rUW(n, mu = mu_real, sigma = sigma_real)
)

stopifnot(all(datos$x > 0 & datos$x < 1))

# Ajuste de intercepto para ambos parametros.
# Se utiliza RS como primer intento; si no converge,
# revisar valores iniciales, derivadas y algoritmo.
ajuste_UW <- gamlss::gamlss(
  x ~ 1,
  sigma.fo = ~1,
  family = UW(),
  data = datos,
  method = gamlss::RS(),
  control = gamlss::gamlss.control(
    n.cyc = 100,
    trace = FALSE
  )
)

print(summary(ajuste_UW))

cat("\nParametros usados para simular:\n")
cat("mu =", mu_real, "\n")
cat("sigma =", sigma_real, "\n")

cat("\nParametros estimados:\n")
print(stats::fitted(ajuste_UW, what = "mu")[1])
print(stats::fitted(ajuste_UW, what = "sigma")[1])

# Diagnosticos basicos
graphics::par(mfrow = c(1, 2))
graphics::hist(
  datos$x,
  breaks = 30,
  probability = TRUE,
  main = "Muestra simulada UW",
  xlab = "x"
)
graphics::curve(
  dUW(x, mu = mu_real, sigma = sigma_real),
  from = 0.001,
  to = 0.999,
  add = TRUE,
  lwd = 2
)
plot(ajuste_UW)
graphics::par(mfrow = c(1, 1))
