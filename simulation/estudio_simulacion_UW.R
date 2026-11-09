# ============================================================
# ESTUDIO DE SIMULACION DE LA DISTRIBUCION UNIT-WEIBULL
#
# Ejecutar desde la raiz del repositorio:
# source("simulation/estudio_simulacion_UW.R")
#
# Define:
#   ejecutar_monte_carlo_UW()
#   comparar_familias_UW()
#
# Los resultados se guardan en CSV dentro de resultados_simulacion/.
# ============================================================

if (!exists("dUW", mode = "function") ||
    !exists("rUW", mode = "function") ||
    !exists("UW", mode = "function")) {
  source(file.path("R", "utils.R"))
  source(file.path("R", "dUW.R"))
  source(file.path("R", "UW.R"))
}

if (!requireNamespace("gamlss", quietly = TRUE) ||
    !requireNamespace("gamlss.dist", quietly = TRUE)) {
  stop("Instale los paquetes 'gamlss' y 'gamlss.dist' antes de continuar.")
}


# Ajusta un modelo GAMLSS de intercepto para una muestra.
# Captura errores y advertencias para no detener todo el estudio.
.uw_ajustar_gamlss <- function(y, family, max_cycles = 100) {
  advertencias <- character(0)
  error_texto <- NA_character_

  ajuste <- withCallingHandlers(
    tryCatch(
      gamlss::gamlss(
        formula = y ~ 1,
        sigma.fo = ~ 1,
        family = family,
        data = data.frame(y = y),
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

  if (is.null(ajuste)) {
    return(list(
      ajuste = NULL,
      convergencia = FALSE,
      error = error_texto,
      advertencias = paste(unique(advertencias), collapse = " | ")
    ))
  }

  convergencia <- ajuste$converged
  if (is.null(convergencia) || length(convergencia) == 0L) {
    convergencia <- is.finite(ajuste$G.deviance) &&
      !is.null(ajuste$iter) && ajuste$iter < max_cycles
  } else {
    convergencia <- isTRUE(convergencia)
  }

  list(
    ajuste = ajuste,
    convergencia = convergencia,
    error = error_texto,
    advertencias = paste(unique(advertencias), collapse = " | ")
  )
}


# Intervalos Wald aproximados en escala logaritmica.
#
# Para eta1 = log(mu) y eta2 = log(sigma), la informacion de
# Fisher esperada por observacion es:
#
# I(eta) = [ 1       a ]
#          [ a   pi^2/6 + a^2 ]
#
# donde a = digamma(2) - log(mu). Se deriva de las segundas
# derivadas esperadas implementadas en R/UW.R. Los intervalos
# se transforman nuevamente a la escala positiva original.
.uw_intervalos_fisher <- function(mu, sigma, n, nivel = 0.95) {
  a <- digamma(2) - log(mu)

  informacion_log <- matrix(
    c(1, a,
      a, pi^2 / 6 + a^2),
    nrow = 2,
    byrow = TRUE
  )

  covarianza_log <- solve(n * informacion_log)
  critico <- stats::qnorm(1 - (1 - nivel) / 2)

  se_log_mu <- sqrt(covarianza_log[1, 1])
  se_log_sigma <- sqrt(covarianza_log[2, 2])

  list(
    mu_inf = exp(log(mu) - critico * se_log_mu),
    mu_sup = exp(log(mu) + critico * se_log_mu),
    sigma_inf = exp(log(sigma) - critico * se_log_sigma),
    sigma_sup = exp(log(sigma) + critico * se_log_sigma)
  )
}


# ------------------------------------------------------------
# 1. ESTUDIO MONTE CARLO
# ------------------------------------------------------------

ejecutar_monte_carlo_UW <- function(
    B = 100,
    tamanos = c(100, 300, 800),
    escenarios = data.frame(
      escenario = c("A", "B"),
      mu = c(0.7, 1.5),
      sigma = c(1.5, 0.7)
    ),
    nivel = 0.95,
    semilla = 20261108,
    max_cycles = 100,
    carpeta_salida = "resultados_simulacion") {

  if (length(B) != 1L || is.na(B) || B < 1 || B != floor(B)) {
    stop("'B' debe ser un entero positivo.")
  }
  if (length(tamanos) == 0L ||
      any(!is.finite(tamanos) | tamanos < 2 | tamanos != floor(tamanos))) {
    stop("'tamanos' debe contener enteros mayores o iguales a 2.")
  }
  if (!all(c("escenario", "mu", "sigma") %in% names(escenarios))) {
    stop("'escenarios' debe tener columnas: escenario, mu y sigma.")
  }
  if (any(!is.finite(escenarios$mu) | escenarios$mu <= 0) ||
      any(!is.finite(escenarios$sigma) | escenarios$sigma <= 0)) {
    stop("Los parametros verdaderos mu y sigma deben ser positivos y finitos.")
  }
  if (nivel <= 0 || nivel >= 1) {
    stop("'nivel' debe estar entre 0 y 1.")
  }

  set.seed(semilla)
  total <- B * length(tamanos) * nrow(escenarios)
  resultados <- vector("list", total)
  indice <- 0L

  cat("\nINICIO DEL ESTUDIO MONTE CARLO UNIT-WEIBULL\n")
  cat("Replicaciones por combinacion:", B, "\n")
  cat("Tamanos de muestra:", paste(tamanos, collapse = ", "), "\n")
  cat("Escenarios:", nrow(escenarios), "\n\n")

  for (i in seq_len(nrow(escenarios))) {
    nombre_escenario <- as.character(escenarios$escenario[i])
    mu_real <- escenarios$mu[i]
    sigma_real <- escenarios$sigma[i]

    for (n_actual in tamanos) {
      cat("Escenario", nombre_escenario, "- n =", n_actual, "\n")

      for (b in seq_len(B)) {
        muestra <- rUW(n_actual, mu = mu_real, sigma = sigma_real)
        resultado_ajuste <- .uw_ajustar_gamlss(
          muestra,
          family = UW(),
          max_cycles = max_cycles
        )

        mu_hat <- NA_real_
        sigma_hat <- NA_real_
        mu_inf <- mu_sup <- sigma_inf <- sigma_sup <- NA_real_
        mu_cubre <- sigma_cubre <- NA
        longitud_mu <- longitud_sigma <- NA_real_

        ajuste <- resultado_ajuste$ajuste

        if (!is.null(ajuste)) {
          mu_hat <- tryCatch(
            as.numeric(stats::fitted(ajuste, what = "mu")[1]),
            error = function(e) NA_real_
          )
          sigma_hat <- tryCatch(
            as.numeric(stats::fitted(ajuste, what = "sigma")[1]),
            error = function(e) NA_real_
          )
        }

        correcto <- isTRUE(resultado_ajuste$convergencia) &&
          is.finite(mu_hat) && mu_hat > 0 &&
          is.finite(sigma_hat) && sigma_hat > 0

        if (correcto) {
          intervalos <- .uw_intervalos_fisher(
            mu = mu_hat,
            sigma = sigma_hat,
            n = n_actual,
            nivel = nivel
          )

          mu_inf <- intervalos$mu_inf
          mu_sup <- intervalos$mu_sup
          sigma_inf <- intervalos$sigma_inf
          sigma_sup <- intervalos$sigma_sup

          mu_cubre <- mu_real >= mu_inf && mu_real <= mu_sup
          sigma_cubre <- sigma_real >= sigma_inf &&
            sigma_real <= sigma_sup

          longitud_mu <- mu_sup - mu_inf
          longitud_sigma <- sigma_sup - sigma_inf
        }

        indice <- indice + 1L
        resultados[[indice]] <- data.frame(
          escenario = nombre_escenario,
          n = n_actual,
          replica = b,
          mu_real = mu_real,
          sigma_real = sigma_real,
          mu_estimado = mu_hat,
          sigma_estimado = sigma_hat,
          mu_ic_inf = mu_inf,
          mu_ic_sup = mu_sup,
          sigma_ic_inf = sigma_inf,
          sigma_ic_sup = sigma_sup,
          mu_cubre = mu_cubre,
          sigma_cubre = sigma_cubre,
          longitud_ic_mu = longitud_mu,
          longitud_ic_sigma = longitud_sigma,
          convergencia = isTRUE(resultado_ajuste$convergencia),
          ajuste_exitoso = correcto,
          iteraciones = if (!is.null(ajuste)) ajuste$iter else NA_integer_,
          error = resultado_ajuste$error,
          advertencias = resultado_ajuste$advertencias,
          stringsAsFactors = FALSE
        )
      }
    }
  }

  bruto <- do.call(rbind, resultados)
  grupos <- split(
    bruto,
    interaction(bruto$escenario, bruto$n, drop = TRUE, lex.order = TRUE)
  )

  resumen_lista <- list()
  j <- 0L

  for (grupo in grupos) {
    for (parametro in c("mu", "sigma")) {
      estimado <- grupo[[paste0(parametro, "_estimado")]]
      real <- grupo[[paste0(parametro, "_real")]][1]
      ok <- grupo$ajuste_exitoso & is.finite(estimado)
      errores <- estimado[ok] - real

      cobertura <- grupo[[paste0(parametro, "_cubre")]][ok]
      longitudes <- grupo[[paste0("longitud_ic_", parametro)]][ok]

      j <- j + 1L
      resumen_lista[[j]] <- data.frame(
        escenario = grupo$escenario[1],
        n = grupo$n[1],
        parametro = parametro,
        valor_real = real,
        replicaciones = nrow(grupo),
        ajustes_exitosos = sum(ok),
        porcentaje_exito = 100 * mean(ok),
        media_estimacion = if (sum(ok) > 0) mean(estimado[ok]) else NA_real_,
        sesgo = if (sum(ok) > 0) mean(errores) else NA_real_,
        sesgo_relativo_pct = if (sum(ok) > 0) {
          100 * mean(errores) / real
        } else {
          NA_real_
        },
        desviacion_estandar = if (sum(ok) > 1) stats::sd(estimado[ok]) else NA_real_,
        ECM = if (sum(ok) > 0) mean(errores^2) else NA_real_,
        RMSE = if (sum(ok) > 0) sqrt(mean(errores^2)) else NA_real_,
        cobertura_pct = if (sum(ok) > 0) {
          100 * mean(cobertura, na.rm = TRUE)
        } else {
          NA_real_
        },
        longitud_media_IC = if (sum(ok) > 0) {
          mean(longitudes, na.rm = TRUE)
        } else {
          NA_real_
        },
        stringsAsFactors = FALSE
      )
    }
  }

  resumen <- do.call(rbind, resumen_lista)
  if (!dir.exists(carpeta_salida)) {
    dir.create(carpeta_salida, recursive = TRUE)
  }

  marca_tiempo <- format(Sys.time(), "%Y%m%d_%H%M%S")
  archivo_bruto <- file.path(
    carpeta_salida,
    paste0("monte_carlo_UW_detalle_", marca_tiempo, ".csv")
  )
  archivo_resumen <- file.path(
    carpeta_salida,
    paste0("monte_carlo_UW_resumen_", marca_tiempo, ".csv")
  )

  utils::write.csv(bruto, archivo_bruto, row.names = FALSE, na = "")
  utils::write.csv(resumen, archivo_resumen, row.names = FALSE, na = "")

  cat("\nRESUMEN MONTE CARLO\n")
  print(resumen, row.names = FALSE)
  cat("\nArchivos guardados:\n", archivo_bruto, "\n", archivo_resumen, "\n")

  invisible(list(
    detalle = bruto,
    resumen = resumen,
    archivo_detalle = archivo_bruto,
    archivo_resumen = archivo_resumen
  ))
}


# ------------------------------------------------------------
# 2. COMPARACION CON FAMILIAS EXISTENTES DE GAMLSS
# ------------------------------------------------------------

comparar_familias_UW <- function(
    replicas = 30,
    n = 500,
    mu = 0.7,
    sigma = 1.5,
    semilla = 20261109,
    max_cycles = 100,
    carpeta_salida = "resultados_simulacion") {

  if (length(replicas) != 1L || is.na(replicas) ||
      replicas < 1 || replicas != floor(replicas)) {
    stop("'replicas' debe ser un entero positivo.")
  }
  if (length(n) != 1L || is.na(n) || n < 2 || n != floor(n)) {
    stop("'n' debe ser un entero mayor o igual a 2.")
  }
  if (!is.finite(mu) || mu <= 0 ||
      !is.finite(sigma) || sigma <= 0) {
    stop("'mu' y 'sigma' deben ser positivos y finitos.")
  }

  set.seed(semilla)
  resultados <- vector("list", replicas)

  cat("\nCOMPARACION DE FAMILIAS GAMLSS\n")
  cat("Datos generados desde UW(mu =", mu, ", sigma =", sigma, ")\n")
  cat("Tamano de muestra:", n, "\n")
  cat("Replicas:", replicas, "\n\n")

  for (b in seq_len(replicas)) {
    muestra <- rUW(n, mu = mu, sigma = sigma)

    # Las cinco familias se ajustan a exactamente la misma muestra.
    familias <- list(
      UW = UW(),
      BE = gamlss.dist::BE(),
      BEo = gamlss.dist::BEo(),
      LOGITNO = gamlss.dist::LOGITNO(),
      GB1 = gamlss.dist::GB1()
    )

    filas <- vector("list", length(familias))
    nombres <- names(familias)

    for (j in seq_along(familias)) {
      nombre <- nombres[j]
      resultado_ajuste <- .uw_ajustar_gamlss(
        muestra,
        family = familias[[j]],
        max_cycles = max_cycles
      )

      ajuste <- resultado_ajuste$ajuste
      convergio <- isTRUE(resultado_ajuste$convergencia)

      filas[[j]] <- data.frame(
        replica = b,
        n = n,
        familia = nombre,
        convergencia = convergio,
        AIC = if (!is.null(ajuste) && convergio) ajuste$aic else NA_real_,
        BIC = if (!is.null(ajuste) && convergio) ajuste$sbc else NA_real_,
        deviance_global = if (!is.null(ajuste)) ajuste$G.deviance else NA_real_,
        grados_libertad = if (!is.null(ajuste)) ajuste$df.fit else NA_real_,
        iteraciones = if (!is.null(ajuste)) ajuste$iter else NA_integer_,
        error = resultado_ajuste$error,
        advertencias = resultado_ajuste$advertencias,
        stringsAsFactors = FALSE
      )
    }

    tabla_replica <- do.call(rbind, filas)
    tabla_replica$mejor_AIC <- FALSE
    tabla_replica$mejor_BIC <- FALSE

    candidatos_aic <- which(is.finite(tabla_replica$AIC))
    candidatos_bic <- which(is.finite(tabla_replica$BIC))

    if (length(candidatos_aic) > 0L) {
      ganador <- candidatos_aic[
        which.min(tabla_replica$AIC[candidatos_aic])
      ]
      tabla_replica$mejor_AIC[ganador] <- TRUE
    }

    if (length(candidatos_bic) > 0L) {
      ganador <- candidatos_bic[
        which.min(tabla_replica$BIC[candidatos_bic])
      ]
      tabla_replica$mejor_BIC[ganador] <- TRUE
    }

    resultados[[b]] <- tabla_replica
    if (b %% 5 == 0 || b == replicas) {
      cat("Replicas completadas:", b, "de", replicas, "\n")
    }
  }

  bruto <- do.call(rbind, resultados)
  grupos <- split(bruto, bruto$familia)

  resumen_lista <- lapply(grupos, function(grupo) {
    data.frame(
      familia = grupo$familia[1],
      replicas = replicas,
      ajustes_convergentes = sum(grupo$convergencia, na.rm = TRUE),
      porcentaje_convergencia = 100 * mean(grupo$convergencia, na.rm = TRUE),
      AIC_medio = if (any(is.finite(grupo$AIC))) {
        mean(grupo$AIC, na.rm = TRUE)
      } else {
        NA_real_
      },
      AIC_mediano = if (any(is.finite(grupo$AIC))) {
        stats::median(grupo$AIC, na.rm = TRUE)
      } else {
        NA_real_
      },
      BIC_medio = if (any(is.finite(grupo$BIC))) {
        mean(grupo$BIC, na.rm = TRUE)
      } else {
        NA_real_
      },
      BIC_mediano = if (any(is.finite(grupo$BIC))) {
        stats::median(grupo$BIC, na.rm = TRUE)
      } else {
        NA_real_
      },
      victorias_AIC_pct = 100 * sum(grupo$mejor_AIC, na.rm = TRUE) / replicas,
      victorias_BIC_pct = 100 * sum(grupo$mejor_BIC, na.rm = TRUE) / replicas,
      stringsAsFactors = FALSE
    )
  })

  resumen <- do.call(rbind, resumen_lista)
  resumen <- resumen[order(resumen$AIC_medio), , drop = FALSE]

  if (!dir.exists(carpeta_salida)) {
    dir.create(carpeta_salida, recursive = TRUE)
  }

  marca_tiempo <- format(Sys.time(), "%Y%m%d_%H%M%S")
  archivo_bruto <- file.path(
    carpeta_salida,
    paste0("comparacion_familias_UW_detalle_", marca_tiempo, ".csv")
  )
  archivo_resumen <- file.path(
    carpeta_salida,
    paste0("comparacion_familias_UW_resumen_", marca_tiempo, ".csv")
  )

  utils::write.csv(bruto, archivo_bruto, row.names = FALSE, na = "")
  utils::write.csv(resumen, archivo_resumen, row.names = FALSE, na = "")

  cat("\nRESUMEN DE COMPARACION\n")
  print(resumen, row.names = FALSE)
  cat("\nArchivos guardados:\n", archivo_bruto, "\n", archivo_resumen, "\n")

  invisible(list(
    detalle = bruto,
    resumen = resumen,
    archivo_detalle = archivo_bruto,
    archivo_resumen = archivo_resumen
  ))
}


cat("\nFunciones del estudio Unit-Weibull cargadas correctamente.\n")
cat("Use ejecutar_monte_carlo_UW() y comparar_familias_UW().\n")
