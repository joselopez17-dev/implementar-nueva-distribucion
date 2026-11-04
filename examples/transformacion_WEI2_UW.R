# Transformacion de WEI2 a Unit-Weibull (UW)
# Proyecto: Implementacion de Unit-Weibull en GAMLSS
#
# Idea:
#   Si Y ~ WEI2(mu, sigma) y X = exp(-Y), entonces
#   X sigue una distribucion Unit-Weibull.
#
#   La transformacion inversa es:
#       y = -log(x)
#
#   El jacobiano es:
#       |dy/dx| = 1/x
#
#   Por tanto:
#       f_UW(x) = dWEI2(-log(x), mu, sigma) / x
#
# Parametros:
#       mu    = alpha
#       sigma = beta

# Instalar una sola vez si el paquete no esta instalado:
# install.packages("gamlss.dist")

library(gamlss.dist)


# 1. Densidad Unit-Weibull obtenida a partir de WEI2


dUW_desde_WEI2 <- function(x, mu, sigma, log = FALSE) {
  
  # Validacion de parametros (se usan escalares en este ejemplo)
  if (length(mu) != 1L || !is.finite(mu) || mu <= 0) {
    stop("'mu' debe ser un unico valor positivo.")
  }
  
  if (length(sigma) != 1L || !is.finite(sigma) || sigma <= 0) {
    stop("'sigma' debe ser un unico valor positivo.")
  }
  
  # Inicializar la salida:
  # densidad = 0 fuera del soporte; log-densidad = -Inf.
  resultado <- rep(if (log) -Inf else 0, length(x))
  names(resultado) <- names(x)
  
  # El soporte de Unit-Weibull es estrictamente 0 < x < 1.
  valido <- is.finite(x) & x > 0 & x < 1
  
  if (any(valido)) {
    
    # Sustitucion del argumento de WEI2:
    # y = -log(x)
    y <- -log(x[valido])
    
    if (log) {
      # En escala logaritmica:
      # log(f_UW) = log(f_WEI2(-log(x))) - log(x)
      resultado[valido] <-
        dWEI2(y, mu = mu, sigma = sigma, log = TRUE) -
        log(x[valido])
      
    } else {
      # En escala natural:
      # f_UW(x) = f_WEI2(-log(x)) * (1/x)
      resultado[valido] <-
        dWEI2(y, mu = mu, sigma = sigma) / x[valido]
    }
  }
  
  resultado
}



# 2. Densidad Unit-Weibull escrita directamente


dUW_formula <- function(x, mu, sigma, log = FALSE) {
  
  if (length(mu) != 1L || !is.finite(mu) || mu <= 0) {
    stop("'mu' debe ser un unico valor positivo.")
  }
  
  if (length(sigma) != 1L || !is.finite(sigma) || sigma <= 0) {
    stop("'sigma' debe ser un unico valor positivo.")
  }
  
  resultado <- rep(if (log) -Inf else 0, length(x))
  names(resultado) <- names(x)
  
  valido <- is.finite(x) & x > 0 & x < 1
  
  if (any(valido)) {
    
    z <- -log(x[valido])
    
    # Logaritmo de la densidad:
    log_densidad <- log(mu) +
      log(sigma) -
      log(x[valido]) +
      (sigma - 1) * log(z) -
      mu * z^sigma
    
    if (log) {
      resultado[valido] <- log_densidad
    } else {
      resultado[valido] <- exp(log_densidad)
    }
  }
  
  resultado
}



# 3. Funcion de distribucion acumulada usando WEI2


pUW_desde_WEI2 <- function(q, mu, sigma) {
  
  resultado <- rep(0, length(q))
  names(resultado) <- names(q)
  
  # Para q <= 0, F(q) = 0.
  # Para q >= 1, F(q) = 1.
  resultado[!is.na(q) & q >= 1] <- 1
  
  valido <- is.finite(q) & q > 0 & q < 1
  
  if (any(valido)) {
    
    y <- -log(q[valido])
    
    # F_X(x) = P(Y >= -log(x))
    # Se usa la cola superior de WEI2.
    resultado[valido] <- pWEI2(
      y,
      mu = mu,
      sigma = sigma,
      lower.tail = FALSE
    )
  }
  
  resultado
}



# 4. Cuantiles y generacion aleatoria mediante WEI2


qUW_desde_WEI2 <- function(p, mu, sigma) {
  
  # Q_UW(p) = exp(-Q_WEI2(1-p))
  exp(-qWEI2(
    1 - p,
    mu = mu,
    sigma = sigma
  ))
}


rUW_desde_WEI2 <- function(n, mu, sigma) {
  
  # Si Y ~ WEI2, entonces X = exp(-Y) ~ Unit-Weibull.
  exp(rWEI2(
    n,
    mu = mu,
    sigma = sigma
  ) * (-1))
}


# 5. Comprobacion numerica de la equivalencia


mu <- 0.7
sigma <- 1.5

x <- seq(0.001, 0.999, length.out = 500)

densidad_WEI2_transformada <- dUW_desde_WEI2(
  x, mu = mu, sigma = sigma
)

densidad_UW_directa <- dUW_formula(
  x, mu = mu, sigma = sigma
)

error_maximo <- max(abs(
  densidad_WEI2_transformada - densidad_UW_directa
))

cat("Parametro mu:", mu, "\n")
cat("Parametro sigma:", sigma, "\n")
cat("Error maximo entre las dos densidades:", error_maximo, "\n")

# Las dos expresiones deben coincidir numericamente.
stopifnot(isTRUE(all.equal(
  densidad_WEI2_transformada,
  densidad_UW_directa,
  tolerance = 1e-10
)))

cat("Comprobacion de densidades: CORRECTA\n")



# 6. Comparacion grafica de las densidades


plot(
  x,
  densidad_WEI2_transformada,
  type = "l",
  lwd = 2,
  col = "blue",
  xlab = "x",
  ylab = "Densidad",
  main = "Unit-Weibull: transformacion de WEI2"
)

lines(
  x,
  densidad_UW_directa,
  lwd = 2,
  lty = 2,
  col = "red"
)

legend(
  "topright",
  legend = c("Desde WEI2", "Formula directa UW"),
  col = c("blue", "red"),
  lty = c(1, 2),
  lwd = 2
)



# 7. Comparacion de las funciones de distribucion


cdf_UW <- pUW_desde_WEI2(
  x, mu = mu, sigma = sigma
)

cdf_UW_directa <- exp(
  -mu * (-log(x))^sigma
)

error_cdf <- max(abs(cdf_UW - cdf_UW_directa))

cat("Error maximo entre las funciones de distribucion:",
    error_cdf, "\n")

stopifnot(isTRUE(all.equal(
  cdf_UW,
  cdf_UW_directa,
  tolerance = 1e-10
)))

cat("Comprobacion de CDF: CORRECTA\n")



# 8. Ejemplo de simulacion


set.seed(2026)

muestra_UW <- rUW_desde_WEI2(
  n = 1000,
  mu = mu,
  sigma = sigma
)

# La muestra debe estar dentro del intervalo (0,1).
stopifnot(all(muestra_UW > 0 & muestra_UW < 1))

hist(
  muestra_UW,
  breaks = 30,
  probability = TRUE,
  main = "Muestra simulada Unit-Weibull",
  xlab = "x"
)

curve(
  dUW_desde_WEI2(
    x,
    mu = mu,
    sigma = sigma
  ),
  from = 0.001,
  to = 0.999,
  add = TRUE,
  lwd = 2,
  col = "blue"
)

cat("Simulacion generada correctamente.\n")

