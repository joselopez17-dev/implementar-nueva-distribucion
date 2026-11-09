# ============================================================
# Funciones de distribucion Unit-Weibull
#
# Parametrizacion:
#   F(x; mu, sigma) = exp[-mu * (-log(x))^sigma]
#
#   f(x; mu, sigma) =
#     (mu * sigma / x) * (-log(x))^(sigma - 1) *
#     exp[-mu * (-log(x))^sigma]
#
# Soporte: 0 < x < 1; mu > 0; sigma > 0.
#
# Requiere cargar R/utils.R antes de este archivo cuando se
# trabaja con source(). En un paquete R, los archivos de R/
# comparten el entorno del namespace.
# ============================================================

dUW <- function(x, mu = 1, sigma = 1, log = FALSE) {
  if (!is.logical(log) || length(log) != 1L || is.na(log)) {
    stop("'log' debe ser TRUE o FALSE.")
  }

  args <- .uw_recycle_args(x, mu, sigma)
  x <- args$x
  mu <- args$mu
  sigma <- args$sigma

  .uw_validate_parameters(mu, sigma)

  ans <- rep(NA_real_, length(x))
  observed <- !is.na(x) & !is.na(mu) & !is.na(sigma)

  inside <- observed & is.finite(x) & x > 0 & x < 1
  outside <- observed & !inside

  # La densidad se define en el intervalo abierto (0,1).
  # Fuera de ese soporte se devuelve cero (o -Inf en log).
  ans[outside] <- if (log) -Inf else 0

  if (any(inside)) {
    z <- -base::log(x[inside])

    log_density <- base::log(mu[inside]) +
      base::log(sigma[inside]) -
      base::log(x[inside]) +
      (sigma[inside] - 1) * base::log(z) -
      mu[inside] * z^sigma[inside]

    ans[inside] <- if (log) log_density else base::exp(log_density)
  }

  ans
}


pUW <- function(q, mu = 1, sigma = 1,
                lower.tail = TRUE, log.p = FALSE) {
  if (!is.logical(lower.tail) || length(lower.tail) != 1L ||
      is.na(lower.tail)) {
    stop("'lower.tail' debe ser TRUE o FALSE.")
  }
  if (!is.logical(log.p) || length(log.p) != 1L || is.na(log.p)) {
    stop("'log.p' debe ser TRUE o FALSE.")
  }

  args <- .uw_recycle_args(q, mu, sigma)
  q <- args$x
  mu <- args$mu
  sigma <- args$sigma

  .uw_validate_parameters(mu, sigma)

  ans <- rep(NA_real_, length(q))
  observed <- !is.na(q) & !is.na(mu) & !is.na(sigma)

  below <- observed & q <= 0
  above <- observed & q >= 1
  inside <- observed & is.finite(q) & q > 0 & q < 1

  if (lower.tail) {
    ans[below] <- if (log.p) -Inf else 0
    ans[above] <- if (log.p) 0 else 1
  } else {
    ans[below] <- if (log.p) 0 else 1
    ans[above] <- if (log.p) -Inf else 0
  }

  if (any(inside)) {
    z <- -base::log(q[inside])
    log_cdf <- -mu[inside] * z^sigma[inside]

    if (lower.tail) {
      ans[inside] <- if (log.p) {
        log_cdf
      } else {
        base::exp(log_cdf)
      }
    } else {
      # -expm1(log_cdf) calcula 1 - exp(log_cdf) con mayor
      # estabilidad numerica cuando la supervivencia es pequena.
      survival <- -base::expm1(log_cdf)
      ans[inside] <- if (log.p) base::log(survival) else survival
    }
  }

  ans
}


qUW <- function(p, mu = 1, sigma = 1,
                lower.tail = TRUE, log.p = FALSE) {
  if (!is.logical(lower.tail) || length(lower.tail) != 1L ||
      is.na(lower.tail)) {
    stop("'lower.tail' debe ser TRUE o FALSE.")
  }
  if (!is.logical(log.p) || length(log.p) != 1L || is.na(log.p)) {
    stop("'log.p' debe ser TRUE o FALSE.")
  }

  args <- .uw_recycle_args(p, mu, sigma)
  p <- args$x
  mu <- args$mu
  sigma <- args$sigma

  .uw_validate_parameters(mu, sigma)

  # Convertir la probabilidad a la cola inferior. Para log.p=TRUE
  # y lower.tail=FALSE se usa -expm1(p), evitando cancelacion
  # numerica cuando la probabilidad de cola superior es pequena.
  if (log.p && lower.tail) {
    probability <- base::exp(p)
  } else if (log.p && !lower.tail) {
    probability <- -base::expm1(p)
  } else if (!log.p && lower.tail) {
    probability <- p
  } else {
    probability <- 1 - p
  }

  ans <- rep(NA_real_, length(probability))
  observed <- !is.na(probability) & !is.na(mu) & !is.na(sigma)
  valid <- observed & is.finite(probability) &
    probability >= 0 & probability <= 1
  invalid <- observed & !valid

  ans[invalid] <- NaN

  if (any(valid)) {
    # Inversa de F(x) = exp[-mu * (-log(x))^sigma].
    ans[valid] <- base::exp(
      -((-base::log(probability[valid]) / mu[valid])^(1 / sigma[valid]))
    )
  }

  ans
}


rUW <- function(n, mu = 1, sigma = 1) {
  if (length(n) != 1L || is.na(n) || !is.finite(n) ||
      n < 0 || n != base::floor(n)) {
    stop("'n' debe ser un entero no negativo.")
  }

  n <- as.integer(n)
  if (n == 0L) {
    return(numeric(0))
  }

  mu <- rep_len(mu, n)
  sigma <- rep_len(sigma, n)
  .uw_validate_parameters(mu, sigma)

  # Si U ~ Uniforme(0,1), Y = (-log(1-U)/mu)^(1/sigma)
  # tiene distribucion WEI2. Luego X = exp(-Y) es UW.
  u <- stats::runif(n)
  y <- (-base::log1p(-u) / mu)^(1 / sigma)

  base::exp(-y)
}
