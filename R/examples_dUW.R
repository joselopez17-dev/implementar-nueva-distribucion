# ============================================================
# Ejemplos y comprobaciones de las funciones Unit-Weibull
# Ejecutar desde la carpeta raiz del repositorio:
# source("R/utils.R")
# source("R/dUW.R")
# source("R/examples_dUW.R")
# ============================================================

if (!exists(".uw_recycle_args", mode = "function")) {
  source(file.path("R", "utils.R"))
}
if (!exists("dUW", mode = "function")) {
  source(file.path("R", "dUW.R"))
}

# Parametros ilustrativos
mu <- 0.7
sigma <- 1.5
x <- seq(0.001, 0.999, length.out = 500)

# 1. Comparacion con la transformacion de WEI2
if (!requireNamespace("gamlss.dist", quietly = TRUE)) {
  stop("Instale gamlss.dist para comparar con dWEI2().")
}

densidad_desde_wei2 <- gamlss.dist::dWEI2(
  -base::log(x),
  mu = mu,
  sigma = sigma
) / x

densidad_directa <- dUW(
  x,
  mu = mu,
  sigma = sigma
)

error_densidad <- max(abs(densidad_desde_wei2 - densidad_directa))
cat("Error maximo entre densidades:", error_densidad, "\n")

stopifnot(error_densidad < 1e-8)

# 2. Comprobar que la densidad integra uno
integral <- stats::integrate(
  function(t) dUW(t, mu = mu, sigma = sigma),
  lower = 0,
  upper = 1,
  rel.tol = 1e-8
)$value

cat("Integral numerica de la densidad:", integral, "\n")
stopifnot(abs(integral - 1) < 1e-6)

# 3. Comprobar la CDF con la expresion cerrada
cdf_directa <- base::exp(-mu * (-base::log(x))^sigma)
cdf_funcion <- pUW(x, mu = mu, sigma = sigma)

error_cdf <- max(abs(cdf_directa - cdf_funcion))
cat("Error maximo entre CDF:", error_cdf, "\n")
stopifnot(error_cdf < 1e-8)

# 4. Comprobar la inversion de cuantiles
probabilidades <- c(0.05, 0.25, 0.5, 0.75, 0.95)
cuantiles <- qUW(probabilidades, mu = mu, sigma = sigma)
probabilidades_recuperadas <- pUW(cuantiles, mu = mu, sigma = sigma)

stopifnot(isTRUE(all.equal(
  probabilidades,
  probabilidades_recuperadas,
  tolerance = 1e-8
)))

# 5. Graficar densidad y CDF
op <- graphics::par(mfrow = c(1, 2))

graphics::plot(
  x, densidad_directa,
  type = "l", lwd = 2,
  xlab = "x", ylab = "Densidad",
  main = "Densidad Unit-Weibull"
)

graphics::plot(
  x, cdf_funcion,
  type = "l", lwd = 2,
  xlab = "x", ylab = "F(x)",
  main = "CDF Unit-Weibull"
)

graphics::par(op)

cat("Comprobaciones de dUW.R terminadas.\n")
