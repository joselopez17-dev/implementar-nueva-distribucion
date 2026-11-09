# Implementación de la distribución Unit-Weibull en GAMLSS

Implementación de la distribución **Unit-Weibull (UW)** como una nueva familia en el paquete **GAMLSS de R**.

## Descripción matemática

La distribución Unit-Weibull tiene soporte en el intervalo abierto `(0, 1)`. Se obtiene al transformar una variable Weibull:

$$
X = e^{-Y}, \qquad Y=-\log(X).
$$

La función de distribución acumulada es:

$$
F(x;\mu,\sigma)=\exp\left[-\mu(-\log x)^\sigma\right],
\qquad 0<x<1,\quad \mu,\sigma>0.
$$

La función de densidad es:

$$
f(x;\mu,\sigma)=\frac{\mu\sigma}{x}(-\log x)^{\sigma-1}
\exp\left[-\mu(-\log x)^\sigma\right].
$$

## Relación con WEI2

La distribución WEI2 de `gamlss.dist` tiene soporte positivo y densidad:

$$
f_Y(y;\mu,\sigma)=\mu\sigma y^{\sigma-1}
\exp(-\mu y^\sigma),\qquad y>0.
$$

Aplicando la transformación `Y = -log(X)` y el jacobiano `|dY/dX| = 1/X`, obtenemos:

$$
f_X(x;\mu,\sigma)=\frac{1}{x}f_Y(-\log x;\mu,\sigma).
$$

La transformación conserva los parámetros: `mu = alpha` y `sigma = beta`. WEI2 se utiliza como referencia matemática y computacional; la familia UW tiene funciones propias para la respuesta en `(0,1)`.

## Familias existentes para respuestas unitarias

La revisión de familias disponibles y sus soportes se encuentra en [`docs/familias_0_1_en_gamlss.md`](docs/familias_0_1_en_gamlss.md).

Entre las referencias continuas que conviene comparar están `BE()`, `BEo()`, `GB1()` y `LOGITNO()`. Las familias infladas en cero o uno deben considerarse cuando existan observaciones en esos extremos.

El script [`examples/verificar_familias_gamlss.R`](examples/verificar_familias_gamlss.R) comprueba qué funciones están instaladas en la versión local de `gamlss.dist`.

## Archivos iniciales de la distribución UW

Los cinco archivos principales del prototipo están en la carpeta `R/`:

| Archivo | Contenido |
|---|---|
| `dUW.R` | Funciones de densidad, distribución acumulada, cuantiles y generación aleatoria: `dUW()`, `pUW()`, `qUW()`, `rUW()`. |
| `examples_dUW.R` | Comprobación de densidad, integral, CDF, cuantiles y comparación con WEI2. |
| `UW.R` | Objeto de familia `gamlss.family`, enlaces, derivadas, desviancia, residuos e inicialización. |
| `examples_UW.R` | Comprobación numérica de las primeras derivadas y ejemplo de ajuste en GAMLSS. |
| `utils.R` | Funciones auxiliares, validación, transformaciones e inicialización. |

### Orden de carga en RStudio

Desde la carpeta raíz del repositorio:

```r
install.packages(c("gamlss", "gamlss.dist"))

library(gamlss)
library(gamlss.dist)

source("R/utils.R")
source("R/dUW.R")
source("R/UW.R")
```

Después se pueden ejecutar los ejemplos:

```r
source("R/examples_dUW.R")
source("R/examples_UW.R")
```

También puede probarse la familia directamente con:

```r
set.seed(2026)
x <- rUW(1000, mu = 0.7, sigma = 1.5)
datos <- data.frame(x = x)

ajuste <- gamlss(
  x ~ 1,
  sigma.fo = ~ 1,
  family = UW(),
  data = datos
)

summary(ajuste)
```

## Pruebas

Desde la carpeta raíz del repositorio, ejecutar:

```r
source("tests/run_all_tests.R")
```

El conjunto de pruebas incluye:
- Soporte y validación de parámetros.
- Densidad frente a la transformación de WEI2.
- Integral numérica igual a uno.
- Consistencia de CDF, cuantiles y colas.
- Simulación dentro del intervalo unitario.
- Estructura del objeto `gamlss.family`.
- Comparación de scores analíticos con diferencias finitas.

También se configuró GitHub Actions para ejecutar las pruebas con R en cada actualización de `main`. Los resultados deben revisarse en la pestaña **Actions** del repositorio.

## Consideraciones de validación

- La familia UW debe recibir observaciones estrictamente dentro de `(0,1)`.
- Las funciones iniciales se construyeron usando la variable transformada `z = -log(x)`.
- Las segundas derivadas esperadas de la familia se basan en las expresiones de WEI2, ya que el término del logaritmo del jacobiano no depende de los parámetros.
- El código es un **prototipo inicial**. Debe ejecutarse en RStudio, revisar las advertencias de convergencia y comparar las derivadas analíticas con las numéricas antes de considerarlo validado.
- La familia se puede pasar directamente como `family = UW()`. La lista predeterminada interna de `fitDist(type = "real0to1")` no se modifica automáticamente al definir una familia externa.

## Estado del proyecto

**En desarrollo.** Se creó una primera versión de los cinco archivos R. Quedan pendientes la ejecución y depuración en RStudio, la validación completa del ajuste, el estudio Monte Carlo y el póster académico.

## Referencia principal

Mazucheli, J., Menezes, A. F. B. y Ghitany, M. E. (2018). *The Unit-Weibull Distribution and Associated Inference*. Journal of Applied Probability and Statistics.

## Referencias técnicas

- [Código fuente de WEI2 en gamlss.dist](https://rdrr.io/cran/gamlss.dist/src/R/WEI2.R).
- [Manual de gamlss](https://cran.r-project.org/web/packages/gamlss/refman/gamlss.html).
- [Manual de gamlss.dist](https://cran.r-project.org/web/packages/gamlss.dist/refman/gamlss.dist.html).

## Contexto académico

Ingeniería Industrial — Universidad de Antioquia  
2026

## Autor

José Miguel López Doria
