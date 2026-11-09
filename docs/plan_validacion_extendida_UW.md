# Plan de validacion extendida y aplicacion con datos reales

## A. Ampliacion del estudio de simulacion

Se plantea un diseno factorial 3 x 3 con:

- mu en {0.5, 1, 2}
- sigma en {0.5, 1, 1.5}
- tamanos de muestra n en {100, 300, 800}
- 50 replicaciones por combinacion en la ejecucion inicial.

El diseno permite explorar tres regiones de forma de densidad:

1. 0 < sigma < 1: la densidad diverge en ambos extremos del intervalo.
2. sigma = 1: UW se reduce a F(x) = x^mu y f(x) = mu*x^(mu-1). El caso mu = 1 es uniforme.
3. sigma > 1: la densidad tiende a cero en ambos extremos y tiene un maximo interior.

El total inicial es de 9 escenarios x 3 tamanos x 50 replicaciones = 1,350 ajustes GAMLSS. Para cada parametro se resumen sesgo, sesgo relativo, desviacion estandar, ECM, RMSE, cobertura Wald aproximada del 95 %, longitud media del intervalo y porcentaje de ajustes exitosos.

Script: [simulation/estudio_parametros_UW.R](../simulation/estudio_parametros_UW.R).

Ejecucion desde la raiz del repositorio:

~~~r
source("simulation/estudio_parametros_UW.R")
~~~

Se recomienda comenzar con el numero indicado de replicaciones. Si el estudio es estable, se puede aumentar a 200 o mas para el analisis final.

## B. Aplicacion a datos reales: GasolineYield

Se selecciona el conjunto GasolineYield incluido en el paquete R betareg. Contiene 32 observaciones y seis variables; yield representa la proporcion de petroleo crudo convertida en gasolina y temp es la temperatura a la que se ha vaporizado toda la gasolina. La variable de respuesta es una proporcion continua estrictamente interior a (0,1); la documentacion y la inspeccion de los datos en R deben confirmar el soporte antes de ajustar UW.

La variable yield tiene rango documentado de 0.028 a 0.457, por lo que no contiene extremos 0 ni 1. Debido a que son solo 32 observaciones, la aplicacion se interpreta como ilustrativa y exploratoria.

El script realiza:

1. Verificacion de valores faltantes, finitud y soporte abierto (0,1).
2. Estadisticos descriptivos.
3. Comparacion de UW, GB1, LOGITNO, BE y BEo con modelo de intercepto, usando las mismas 32 observaciones.
4. Ajuste exploratorio con temp como predictor lineal del parametro mu y sigma con intercepto, para las mismas familias.
5. Graficas de histograma con densidad UW ajustada y CDF empirica frente a CDF UW.
6. Exportacion de tablas, datos y curvas a CSV.

Script: [simulation/aplicacion_datos_reales_UW.R](../simulation/aplicacion_datos_reales_UW.R).

En Posit Cloud:

~~~r
install.packages(c("betareg", "gamlss", "gamlss.dist"))
source("simulation/aplicacion_datos_reales_UW.R")
~~~

La comparacion AIC/BIC debe limitarse a modelos convergentes ajustados sobre las mismas observaciones y con la misma especificacion de predictor. El AIC/BIC menor describe mejor compromiso ajuste-complejidad dentro de los modelos considerados, pero no valida por si solo la distribucion ni demuestra superioridad general.

## C. Referencia de los datos

Prater (1956), datos de rendimiento de gasolina a partir de petroleo crudo, difundidos como GasolineYield en el paquete R betareg. La documentacion del paquete describe yield como proporcion de petroleo crudo convertida en gasolina y registra 32 observaciones.

## D. Limites de la aplicacion

- La muestra es pequena (n = 32).
- Se trata de un ejemplo historico de rendimiento de proceso, no de una muestra representativa de todas las operaciones de refinacion.
- El modelo con temperatura es exploratorio; no se debe interpretar causalmente.
- No se deben seleccionar conclusiones a partir de unicamente el AIC/BIC. Es necesario revisar convergencia, residuos, forma de las curvas y el alcance de los datos.


## Fuentes de los datos reales

- Documentacion CRAN del paquete betareg: https://cloud.r-project.org/web/packages/betareg/refman/betareg.html
- Vignette de beta regression que describe GasolineYield y su contexto: https://cran.r-project.org/web/packages/betareg/vignettes/betareg.html
- Resumen de datos y rango de yield reportado por R Observatory: https://observe.rstats.dev/cran/betareg/data/GasolineYield
