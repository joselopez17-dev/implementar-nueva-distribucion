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


## Graficas de densidad y distribucion acumulada

El script [simulation/graficar_curvas_UW.R](simulation/graficar_curvas_UW.R) genera graficas de densidad y de la funcion de distribucion acumulada para los cuatro escenarios del diseno factorial. Produce archivos PNG y PDF y una tabla CSV con los valores graficados.

Desde la raiz del proyecto:

```r
source("simulation/graficar_curvas_UW.R")
```

Los archivos quedan en `resultados_simulacion/`. Las graficas usan valores interiores al soporte abierto, sin incluir 0 ni 1.

## Estudio de simulacion

Se agrego el script [simulation/estudio_simulacion_UW.R](simulation/estudio_simulacion_UW.R), que define dos procedimientos:

1. `ejecutar_monte_carlo_UW()`: simula datos desde UW y evalua sesgo, sesgo relativo, desviacion estandar, ECM, RMSE, cobertura de intervalos Wald del 95 %, longitud media de los intervalos y porcentaje de convergencia.
2. `comparar_familias_UW()`: ajusta UW, BE, BEo, LOGITNO y GB1 sobre las mismas muestras simuladas y resume AIC, BIC/SBC y la frecuencia con que cada familia obtiene el menor criterio.

El protocolo, los escenarios y la interpretacion se documentan en [docs/protocolo_estudio_simulacion_UW.md](docs/protocolo_estudio_simulacion_UW.md).

Para ejecutarlo desde la raiz del proyecto en Posit Cloud:

```r
source("simulation/estudio_simulacion_UW.R")

resultado_mc <- ejecutar_monte_carlo_UW(
  B = 100,
  tamanos = c(100, 300, 800)
)

resultado_comparacion <- comparar_familias_UW(
  replicas = 30,
  n = 500,
  mu = 0.7,
  sigma = 1.5
)
```

Los resultados detallados y resumidos se guardan como archivos CSV en `resultados_simulacion/`. La ejecucion inicial usa 100 replicaciones por escenario y tamano de muestra, y 30 replicaciones para la comparacion de familias. Para el poster final se recomienda aumentar las replicaciones cuando se haya comprobado el tiempo de ejecucion.

**Estado de los resultados:** el codigo del estudio ya esta agregado al repositorio, pero los resultados Monte Carlo y la comparacion de familias aun deben ejecutarse y revisarse en Posit Cloud. No se deben presentar conclusiones de sesgo, cobertura o superioridad de UW antes de analizar esos CSV.

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
- Prueba de ajuste de intercepto con una muestra simulada en `gamlss::gamlss()`.

El reporte de los resultados ejecutados en GitHub Actions está en [`docs/reporte_pruebas_iniciales.md`](docs/reporte_pruebas_iniciales.md).

También se configuró GitHub Actions para ejecutar las pruebas con R en cada actualización de `main`. Los resultados deben revisarse en la pestaña **Actions** del repositorio.

## Consideraciones de validación

- La familia UW debe recibir observaciones estrictamente dentro de `(0,1)`.
- Las funciones iniciales se construyeron usando la variable transformada `z = -log(x)`.
- Las segundas derivadas esperadas de la familia se basan en las expresiones de WEI2, ya que el término del logaritmo del jacobiano no depende de los parámetros.
- El código es un **prototipo inicial**. Debe ejecutarse en RStudio, revisar las advertencias de convergencia y comparar las derivadas analíticas con las numéricas antes de considerarlo validado.
- La familia se puede pasar directamente como `family = UW()`. La lista predeterminada interna de `fitDist(type = "real0to1")` no se modifica automáticamente al definir una familia externa.

## Estado del proyecto

**En desarrollo.** La primera versión de los cinco archivos R superó las pruebas automatizadas de densidad, CDF, cuantiles, derivadas y un ajuste inicial de intercepto en GAMLSS dentro de GitHub Actions. Quedan pendientes la reproducción en RStudio, pruebas adicionales, comparación con otras familias, estudio Monte Carlo y póster académico.

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
