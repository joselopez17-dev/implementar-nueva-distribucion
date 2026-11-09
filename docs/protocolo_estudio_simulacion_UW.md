# Protocolo del estudio de simulacion de Unit-Weibull

## 1. Proposito

Evaluar el comportamiento de la familia Unit-Weibull (UW) implementada en GAMLSS y comparar su ajuste con distribuciones existentes para respuestas continuas en el intervalo abierto (0,1).

El estudio sigue los indicadores planteados en el avance del proyecto y en el articulo base de Mazucheli, Menezes y Ghitany (2018): sesgo, error cuadratico medio y cobertura de intervalos de confianza.

## 2. Estudio Monte Carlo

Se generan muestras independientes desde:

\[
F(x;\mu,\sigma)=\exp\{-\mu[-\log(x)]^\sigma\},
\quad 0<x<1,\quad \mu,\sigma>0.
\]

La estimacion se realiza mediante un modelo GAMLSS con intercepto para ambos parametros:

- mu.fo = ~ 1
- sigma.fo = ~ 1
- family = UW()

Configuracion inicial propuesta:

| Escenario | mu verdadero | sigma verdadero |
|---|---:|---:|
| A | 0.7 | 1.5 |
| B | 1.5 | 0.7 |

Tamanos de muestra: 100, 300 y 800. El numero inicial de replicaciones es 100 por combinacion. Para el informe final o poster se recomienda aumentar el numero de replicaciones, por ejemplo a 500 o 1,000, despues de comprobar el tiempo de ejecucion y la estabilidad del codigo.

Para cada parametro se calculan:

- Sesgo: promedio de la diferencia entre estimacion y valor verdadero.
- Sesgo relativo porcentual.
- Desviacion estandar empirica de las estimaciones.
- Error cuadratico medio (ECM).
- Raiz del ECM (RMSE).
- Cobertura porcentual del intervalo de confianza del 95 %.
- Longitud media del intervalo de confianza.
- Porcentaje de ajustes exitosos/convergentes.

### Intervalos de confianza

Los intervalos son aproximaciones de Wald en escala logaritmica, transformadas a la escala original. Se utiliza la informacion de Fisher esperada correspondiente a la parametrizacion de UW y a los enlaces logaritmicos. Por tanto, la cobertura estimada es asintotica y debe interpretarse con cautela en muestras pequenas.

## 3. Comparacion de familias

En cada replica se genera una muestra desde UW con mu = 0.7, sigma = 1.5 y n = 500. A esa misma muestra se ajustan:

- UW(): familia nueva del proyecto.
- BE(): distribucion beta en parametrizacion de media y dispersion.
- BEo(): beta en parametrizacion original.
- LOGITNO(): logit-normal.
- GB1(): beta generalizada tipo 1.

La comparacion se realiza con:

- AIC: criterio de informacion de Akaike.
- BIC/SBC: criterio bayesiano de informacion reportado por GAMLSS.
- Frecuencia con que cada familia obtiene el menor AIC o BIC.
- Porcentaje de ajustes convergentes.

Todos los modelos se ajustan a las mismas observaciones dentro de cada replica. GB1() tiene cuatro parametros; AIC y BIC penalizan la complejidad mediante los grados de libertad del modelo.

La comparacion no presupone que UW deba ganar. Un menor AIC/BIC en las muestras estudiadas indica mejor compromiso entre ajuste y complejidad para esos datos simulados, no superioridad universal.

## 4. Ejecucion en Posit Cloud

Desde la raiz del repositorio:

~~~r
install.packages(c("gamlss", "gamlss.dist"))

source("simulation/estudio_simulacion_UW.R")

# Estudio Monte Carlo inicial
resultado_mc <- ejecutar_monte_carlo_UW(
  B = 100,
  tamanos = c(100, 300, 800)
)

# Comparacion de familias sobre 30 muestras simuladas
resultado_comparacion <- comparar_familias_UW(
  replicas = 30,
  n = 500,
  mu = 0.7,
  sigma = 1.5
)
~~~

Los archivos CSV se guardan automaticamente en resultados_simulacion/. Las tablas pueden abrirse desde el panel Files de Posit Cloud o importarse a R para elaborar graficos y el poster.

## 5. Recomendaciones para el informe

1. Informar el numero total de replicaciones, tamanos de muestra, escenarios y semilla.
2. Reportar el porcentaje de convergencia; no ocultar ajustes fallidos.
3. Presentar sesgo, ECM y cobertura por separado para mu y sigma.
4. Analizar si el sesgo y el ECM disminuyen al aumentar el tamano de muestra.
5. Comparar AIC/BIC y frecuencia de seleccion por familia.
6. No afirmar que UW es superior si los resultados no lo respaldan.
7. Para conclusiones finales, aumentar las replicaciones y complementar con aplicaciones a datos reales si el proyecto dispone de un conjunto de datos adecuado.

## 6. Referencia

Mazucheli, J., Menezes, A. F. B. y Ghitany, M. E. (2018). *The Unit-Weibull Distribution and Associated Inference*. Journal of Applied Probability and Statistics, 13(2), 1-22.
