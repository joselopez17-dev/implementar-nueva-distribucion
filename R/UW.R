# ============================================================
# Familia Unit-Weibull para GAMLSS
#
# Parametros:
#   mu > 0
#   sigma > 0
#
# Respuesta:
#   0 < y < 1
#
# Los score y las segundas derivadas esperadas coinciden con
# los de WEI2 evaluados en z = -log(y), porque el termino del
# log-jacobiano, -log(y), no depende de mu ni de sigma.
#
# Requiere cargar gamlss.dist y los archivos utils.R y dUW.R
# antes de utilizar UW() desde source().
# ============================================================

UW <- function(mu.link = "log", sigma.link = "log") {
  mstats <- gamlss.dist::checklink(
    "mu.link", "Unit-Weibull", substitute(mu.link),
    c("inverse", "log", "identity", "own")
  )

  dstats <- gamlss.dist::checklink(
    "sigma.link", "Unit-Weibull", substitute(sigma.link),
    c("inverse", "log", "identity", "own")
  )

  structure(
    list(
      family = c("UW", "Unit-Weibull"),
      parameters = list(mu = TRUE, sigma = TRUE),
      nopar = 2,
      type = "Continuous",

      mu.link = as.character(substitute(mu.link)),
      sigma.link = as.character(substitute(sigma.link)),

      mu.linkfun = mstats$linkfun,
      sigma.linkfun = dstats$linkfun,
      mu.linkinv = mstats$linkinv,
      sigma.linkinv = dstats$linkinv,
      mu.dr = mstats$mu.eta,
      sigma.dr = dstats$mu.eta,

      # Primeras derivadas de log f(y; mu, sigma).
      dldm = function(y, mu, sigma) {
        z <- -base::log(y)
        (1 / mu) - z^sigma
      },

      dldd = function(y, mu, sigma) {
        z <- -base::log(y)
        log_z <- base::log(z)

        (1 / sigma) + log_z - mu * z^sigma * log_z
      },

      # Segundas derivadas esperadas utilizadas por la
      # parametrizacion de WEI2 en GAMLSS. El jacobiano de la
      # transformacion no depende de los parametros, por lo
      # que estas derivadas esperadas se conservan.
      d2ldm2 = function(mu) {
        -1 / mu^2
      },

      d2ldd2 = function(mu, sigma) {
        -(1 / sigma^2) * (
          (base::pi^2 / 6) + (digamma(2) - base::log(mu))^2
        )
      },

      d2ldmdd = function(mu, sigma) {
        -(1 / (sigma * mu)) * (digamma(2) - base::log(mu))
      },

      # Incremento de la desviancia.
      G.dev.incr = function(y, mu, sigma, ...) {
        -2 * dUW(y, mu = mu, sigma = sigma, log = TRUE)
      },

      # Residuos cuantiles aleatorizados.
      rqres = expression(
        rqres(
          pfun = "pUW",
          type = "Continuous",
          y = y,
          mu = mu,
          sigma = sigma
        )
      ),

      # Inicializacion: aplicar las formulas de WEI2 a z=-log(y).
      mu.initial = expression({
        init <- .uw_initial_values(y)
        mu <- init$mu
      }),

      sigma.initial = expression({
        init <- .uw_initial_values(y)
        sigma <- init$sigma
      }),

      mu.valid = function(mu) {
        all(is.finite(mu) & mu > 0, na.rm = TRUE)
      },

      sigma.valid = function(sigma) {
        all(is.finite(sigma) & sigma > 0, na.rm = TRUE)
      },

      y.valid = function(y) {
        all(is.finite(y) & y > 0 & y < 1, na.rm = TRUE)
      }
    ),
    class = c("gamlss.family", "family")
  )
}
