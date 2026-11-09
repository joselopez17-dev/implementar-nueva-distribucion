# ============================================================
# Revision de familias de GAMLSS con soporte unitario
# Proyecto: Unit-Weibull en GAMLSS
#
# Objetivo:
#   1. Verificar que las familias de referencia existen en
#      la version instalada de gamlss.dist.
#   2. Identificar familias continuas en (0,1).
#   3. Separarlas de familias con masa puntual en 0 y/o 1.
#   4. Mostrar como comparar familias con fitDist() cuando
#      se disponga de una muestra real.
# ============================================================

# Instalar una sola vez si hace falta:
# install.packages(c("gamlss", "gamlss.dist"))

if (!requireNamespace("gamlss", quietly = TRUE)) {
  stop("Falta instalar el paquete 'gamlss'.")
}

if (!requireNamespace("gamlss.dist", quietly = TRUE)) {
  stop("Falta instalar el paquete 'gamlss.dist'.")
}

library(gamlss)
library(gamlss.dist)

cat("\nVersion de gamlss:", as.character(packageVersion("gamlss")), "\n")
cat("Version de gamlss.dist:",
    as.character(packageVersion("gamlss.dist")), "\n\n")

# ------------------------------------------------------------
# 1. Familias con soporte continuo en el intervalo (0,1)
# ------------------------------------------------------------

familias_continuas <- c("BE", "BEo", "GB1", "LOGITNO")

# ------------------------------------------------------------
# 2. Familias que admiten inflacion en cero y/o uno
# ------------------------------------------------------------

familias_infladas <- c(
  "BEINF0", "BEINF1", "BEOI", "BEZI", "BEINF"
)

# ------------------------------------------------------------
# 3. Familias de referencia para la transformacion
# ------------------------------------------------------------

familias_referencia <- c("WEI2")

# Comprobar que cada funcion existe en el namespace instalado.
verificar_funciones <- function(nombres) {
  data.frame(
    familia = nombres,
    disponible = vapply(
      nombres,
      function(nombre) exists(
        nombre,
        envir = asNamespace("gamlss.dist"),
        inherits = FALSE
      ),
      logical(1)
    ),
    row.names = NULL
  )
}

cat("Familias continuas con soporte (0,1):\n")
print(verificar_funciones(familias_continuas))

cat("\nFamilias con inflacion en los extremos:\n")
print(verificar_funciones(familias_infladas))

cat("\nDistribuciones de referencia:\n")
print(verificar_funciones(familias_referencia))

# ------------------------------------------------------------
# 4. Mostrar el objeto de familia de WEI2
# ------------------------------------------------------------

cat("\nEstructura de WEI2():\n")
print(WEI2())

# La familia WEI2 tiene soporte y.valid(y): y > 0.
# Unit-Weibull tendra soporte y.valid(x): 0 < x < 1.

# ------------------------------------------------------------
# 5. Comparacion de familias con una muestra real
# ------------------------------------------------------------

# Cuando se tenga una muestra real en el intervalo (0,1),
# asignarla al objeto datos_unitarios.
#
# Ejemplo:
# datos_unitarios <- mi_base$proporcion
#
# Verificar antes:
# stopifnot(
#   is.numeric(datos_unitarios),
#   all(is.finite(datos_unitarios)),
#   all(datos_unitarios > 0 & datos_unitarios < 1)
# )
#
# fitDist() compara las familias incluidas en type="real0to1".
# LOGITNO no forma parte de esa lista predeterminada, por eso
# se agrega por separado mediante el argumento extra.
#
# ajuste <- fitDist(
#   datos_unitarios,
#   type = "real0to1",
#   extra = "LOGITNO",
#   trace = TRUE
# )
#
# print(ajuste$fits)
# print(ajuste$failed)
#
# Importante:
# - No se puede elegir la mejor distribucion sin datos.
# - AIC/BIC solo deben compararse sobre la misma muestra.
# - Las familias infladas se consideran si hay masa en 0 o 1.

cat("\nRevision terminada. Consulte docs/familias_0_1_en_gamlss.md.\n")
