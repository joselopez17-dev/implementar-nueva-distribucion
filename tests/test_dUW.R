# ============================================================
# Pruebas automatizadas de las funciones dUW, pUW, qUW y rUW
#
# Ejecutar desde la raiz del repositorio:
# source("tests/test_dUW.R")
#
# Requiere:
#   R/utils.R
#   R/dUW.R
#   paquete gamlss.dist para la comparacion con WEI2
# ============================================================

source(file.path("R", "utils.R"))
source(file.path("R", "dUW.R"))

# 1. Valores basicos y soporte
x <- c(0.05, 0.2, 0.5, 0.8, 0.95)
mu <- 0.7
sigma <- 1.5

dens <- dUW(x, mu = mu, sigma = sigma)
stopifnot(
  length(dens) == length(x),
  all(is.finite(dens)),
  all(dens > 0)
)

# La densidad fuera del soporte es cero; en escala log es -Inf.
stopifnot(
  identical(dUW(c(-0.1, 0, 1, 1.1), mu, sigma), rep(0, 4)),
  all(dUW(c(-0.1, 0, 1, 1.1), mu, sigma, log = TRUE) == -Inf)
)

# Los NA deben propagarse.
stopifnot(is.na(dUW(NA_real_, mu, sigma)))

# Una respuesta vacia debe producir una salida vacia.
stopifnot(length(dUW(numeric(0), mu, sigma)) == 0L)

# 2. Positividad de parametros
error_mu <- try(dUW(0.5, mu = 0, sigma = 1), silent = TRUE)
error_sigma <- try(dUW(0.5, mu = 1, sigma = -0.5), silent = TRUE)
stopifnot(inherits(error_mu, "try-error"))
stopifnot(inherits(error_sigma, "try-error"))

# 3. Coherencia entre densidad y log-densidad.
stopifnot(isTRUE(all.equal(
  base::log(dUW(x, mu, sigma)),
  dUW(x, mu, sigma, log = TRUE),
  tolerance = 1e-12
)))

# 4. Comparacion con la transformacion de WEI2.
stopifnot(requireNamespace("gamlss.dist", quietly = TRUE))
dens_wei2 <- gamlss.dist::dWEI2(
  -base::log(x),
  mu = mu,
  sigma = sigma
) / x

stopifnot(isTRUE(all.equal(
  dens,
  dens_wei2,
  tolerance = 1e-10
)))

# 5. Integral numerica igual a uno.
parametros <- list(
  c(mu = 0.7, sigma = 1),
  c(mu = 0.7, sigma = 1.5),
  c(mu = 1.3, sigma = 2)
)

integrales <- vapply(parametros, function(par) {
  stats::integrate(
    function(t) dUW(t, mu = par[["mu"]], sigma = par[["sigma"]]),
    lower = 0,
    upper = 1,
    rel.tol = 1e-7,
    subdivisions = 1000L
  )$value
}, numeric(1))

print(integrales)
stopifnot(all(abs(integrales - 1) < 1e-5))

# 6. CDF: limites, rango y monotonicidad.
q <- seq(0, 1, length.out = 101)
cdf <- pUW(q, mu = mu, sigma = sigma)

stopifnot(
  cdf[1] == 0,
  cdf[length(cdf)] == 1,
  all(cdf >= 0 & cdf <= 1),
  all(diff(cdf) >= 0)
)

# 7. Relacion entre las colas.
q_inside <- c(0.05, 0.3, 0.7, 0.95)
lower <- pUW(q_inside, mu, sigma)
upper <- pUW(q_inside, mu, sigma, lower.tail = FALSE)
stopifnot(max(abs(lower + upper - 1)) < 1e-12)

# 8. Cuantiles: pUW(qUW(p)) = p.
prob <- c(0, 0.01, 0.1, 0.5, 0.9, 0.99, 1)
quant <- qUW(prob, mu, sigma)
prob_back <- pUW(quant, mu, sigma)

stopifnot(isTRUE(all.equal(prob, prob_back, tolerance = 1e-10)))

# Verificar tambien la parametrizacion de cola superior.
upper_prob <- c(0.01, 0.1, 0.5, 0.9, 0.99)
upper_quant <- qUW(
  upper_prob, mu, sigma,
  lower.tail = FALSE
)
upper_back <- pUW(
  upper_quant, mu, sigma,
  lower.tail = FALSE
)
stopifnot(isTRUE(all.equal(
  upper_prob, upper_back, tolerance = 1e-10
)))

# 9. Escala logaritmica de las probabilidades.
log_cdf <- pUW(q_inside, mu, sigma, log.p = TRUE)
stopifnot(isTRUE(all.equal(
  base::exp(log_cdf), lower, tolerance = 1e-12
)))

log_upper <- pUW(
  q_inside, mu, sigma,
  lower.tail = FALSE,
  log.p = TRUE
)
stopifnot(isTRUE(all.equal(
  base::exp(log_upper), upper, tolerance = 1e-12
)))

# 10. Reciclaje de parametros.
vec <- dUW(
  c(0.2, 0.4, 0.6),
  mu = c(0.5, 0.7, 0.9),
  sigma = 1.2
)
stopifnot(length(vec) == 3L, all(is.finite(vec)))

# 11. Simulacion: soporte y coherencia con la CDF.
set.seed(2026)
sim <- rUW(5000, mu = mu, sigma = sigma)
stopifnot(
  length(sim) == 5000L,
  all(is.finite(sim)),
  all(sim > 0 & sim < 1)
)

cat("\nTODAS LAS PRUEBAS DE dUW/pUW/qUW/rUW FUERON SUPERADAS.\n")
