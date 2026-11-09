# ============================================================
# Utilidades de la distribucion Unit-Weibull
# ============================================================

# Recicla x, mu y sigma a una longitud comun, como hacen las
# funciones de distribucion de R.
.uw_recycle_args <- function(x, mu, sigma) {
  if (length(mu) == 0L || length(sigma) == 0L) {
    stop("'mu' y 'sigma' no pueden estar vacios.")
  }

  # Como en las funciones base de R, una respuesta vacia
  # produce una salida vacia sin intentar reciclar parametros.
  if (length(x) == 0L) {
    return(list(
      x = x,
      mu = rep_len(mu, 0L),
      sigma = rep_len(sigma, 0L)
    ))
  }

  n <- max(length(x), length(mu), length(sigma))

  list(
    x = rep_len(x, n),
    mu = rep_len(mu, n),
    sigma = rep_len(sigma, n)
  )
}

# Comprueba que los parametros sean positivos y finitos.
.uw_validate_parameters <- function(mu, sigma) {
  bad_mu <- !is.na(mu) & (!is.finite(mu) | mu <= 0)
  bad_sigma <- !is.na(sigma) & (!is.finite(sigma) | sigma <= 0)

  if (any(bad_mu)) {
    stop("'mu' debe contener valores positivos y finitos.")
  }

  if (any(bad_sigma)) {
    stop("'sigma' debe contener valores positivos y finitos.")
  }

  invisible(TRUE)
}

# Transformacion de una observacion WEI2 a Unit-Weibull.
uw_transform <- function(y) {
  if (any(y <= 0, na.rm = TRUE)) {
    stop("La variable WEI2 debe ser estrictamente positiva.")
  }
  exp(-y)
}

# Transformacion inversa: de una observacion unitaria a escala
# Weibull. Requiere 0 < x < 1.
uw_inverse_transform <- function(x) {
  if (any(x <= 0 | x >= 1, na.rm = TRUE)) {
    stop("La variable Unit-Weibull debe cumplir 0 < x < 1.")
  }
  -base::log(x)
}

# Valores iniciales aproximados para los parametros de UW.
# Se aplican las formulas de inicializacion de WEI2 a
# z = -log(x), que es la variable Weibull transformada.
.uw_initial_values <- function(x) {
  if (length(x) == 0L ||
      any(!is.finite(x) | x <= 0 | x >= 1)) {
    stop("Los datos para iniciar UW deben estar estrictamente entre 0 y 1.")
  }

  z <- -base::log(x)
  log_z <- base::log(z)
  v <- if (length(log_z) > 1L) stats::var(log_z) else NA_real_

  sigma0 <- if (is.finite(v) && v > 0) {
    base::pi / base::sqrt(6 * v)
  } else {
    1
  }

  mu0 <- base::exp(
    -sigma0 * base::mean(log_z) - 0.5772156649015329
  )

  if (!is.finite(mu0) || mu0 <= 0) {
    mu0 <- 1
  }

  list(
    mu = rep(mu0, length(x)),
    sigma = rep(sigma0, length(x))
  )
}
