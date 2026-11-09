# ============================================================
# Pruebas de estructura de la familia UW y sus scores
#
# Ejecutar desde la raiz del repositorio:
# source("tests/test_UW.R")
#
# Este archivo no reemplaza la prueba de ajuste incluida en
# R/examples_UW.R.
# ============================================================

if (!requireNamespace("gamlss.dist", quietly = TRUE)) {
  stop("Instale gamlss.dist antes de ejecutar estas pruebas.")
}

source(file.path("R", "utils.R"))
source(file.path("R", "dUW.R"))
source(file.path("R", "UW.R"))

fam <- UW()

# 1. Estructura del objeto de familia.
stopifnot(
  inherits(fam, "gamlss.family"),
  identical(fam$family[1], "UW"),
  fam$nopar == 2,
  isTRUE(fam$parameters$mu),
  isTRUE(fam$parameters$sigma)
)

# 2. Validacion del soporte.
stopifnot(
  isTRUE(fam$y.valid(c(0.1, 0.5, 0.9))),
  !isTRUE(fam$y.valid(c(0, 0.5, 0.9))),
  !isTRUE(fam$y.valid(c(0.1, 1, 0.9)))
)

# 3. Validacion de parametros.
stopifnot(
  isTRUE(fam$mu.valid(c(0.1, 1, 10))),
  !isTRUE(fam$mu.valid(c(0.1, 0, 10))),
  isTRUE(fam$sigma.valid(c(0.1, 1, 10))),
  !isTRUE(fam$sigma.valid(c(0.1, -1, 10)))
)

# 4. Comparar scores analiticos con diferencias finitas.
x0 <- 0.4
mu0 <- 0.7
sigma0 <- 1.5
h <- 1e-6

loglik <- function(m, s) {
  dUW(x0, mu = m, sigma = s, log = TRUE)
}

score_mu_num <- (
  loglik(mu0 + h, sigma0) -
    loglik(mu0 - h, sigma0)
) / (2 * h)

score_sigma_num <- (
  loglik(mu0, sigma0 + h) -
    loglik(mu0, sigma0 - h)
) / (2 * h)

score_mu <- fam$dldm(x0, mu0, sigma0)
score_sigma <- fam$dldd(x0, mu0, sigma0)

stopifnot(
  abs(score_mu - score_mu_num) < 1e-5,
  abs(score_sigma - score_sigma_num) < 1e-5
)

cat("Score analitico mu:", score_mu, "\n")
cat("Score numerico mu:", score_mu_num, "\n")
cat("Score analitico sigma:", score_sigma, "\n")
cat("Score numerico sigma:", score_sigma_num, "\n")
# 5. Prueba de integracion: ajustar una muestra simulada con GAMLSS.
# Confirma que la familia puede participar en el algoritmo de estimacion.
if (!requireNamespace("gamlss", quietly = TRUE)) {
  stop("Instale gamlss para ejecutar la prueba de ajuste.")
}

set.seed(2026)
mu_real <- 0.7
sigma_real <- 1.5
datos_prueba <- data.frame(
  x = rUW(800, mu = mu_real, sigma = sigma_real)
)

ajuste_prueba <- gamlss::gamlss(
  x ~ 1,
  sigma.fo = ~1,
  family = UW(),
  data = datos_prueba,
  control = gamlss::gamlss.control(
    n.cyc = 100,
    trace = FALSE
  )
)

mu_estimado <- stats::fitted(ajuste_prueba, what = "mu")[1]
sigma_estimado <- stats::fitted(ajuste_prueba, what = "sigma")[1]

cat("mu estimado:", mu_estimado, "\n")
cat("sigma estimado:", sigma_estimado, "\n")

stopifnot(
  length(mu_estimado) == 1L,
  length(sigma_estimado) == 1L,
  is.finite(mu_estimado),
  is.finite(sigma_estimado),
  mu_estimado > 0,
  sigma_estimado > 0
)

cat("\nPRUEBA DE AJUSTE GAMLSS SUPERADA.\n")

cat("\nPRUEBAS DE ESTRUCTURA Y SCORES DE UW SUPERADAS.\n")
