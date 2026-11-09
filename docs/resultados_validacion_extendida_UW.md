# Resultados de validacion extendida y aplicacion a datos reales

## 1. Estudio Monte Carlo factorial extendido

Se ejecuto el diseno factorial 3 x 3 propuesto para los parametros de Unit-Weibull:

- mu en {0.5, 1, 2}
- sigma en {0.5, 1, 1.5}
- tamanos muestrales n en {100, 300, 800}
- 50 replicaciones por cada combinacion de parametros y tamano.

El total fue de 9 x 3 x 50 = 1,350 ajustes GAMLSS de la familia UW.

### Convergencia

Los 1,350 ajustes terminaron correctamente: en las 54 combinaciones de escenario, tamano y parametro se registraron 50 ajustes exitosos de 50 (100 % de exito).

### Recuperacion de parametros

Las medias de las estimaciones se mantuvieron generalmente cercanas a los valores verdaderos en las nueve combinaciones. Por ejemplo, para mu = 0.5 y sigma = 0.5, al aumentar n de 100 a 800:

- La estimacion media de mu paso de 0.5029 a 0.4987.
- La estimacion media de sigma paso de 0.5058 a 0.4994.
- El ECM de mu paso de 0.00545 a 0.00046.
- El ECM de sigma paso de 0.00156 a 0.00021.

En general, la dispersion de las estimaciones y el ECM tendieron a disminuir al crecer el tamano muestral. La tendencia no fue estrictamente monotona en todas las combinaciones; con 50 replicas por celda puede existir variabilidad Monte Carlo apreciable.

### Cobertura de intervalos

La cobertura empirica de los intervalos Wald aproximados al 95 % estuvo entre 88 % y 100 % en las 54 filas de resumen. Estos valores deben interpretarse como diagnosticos iniciales: con solo 50 replicas, la cobertura cambia en incrementos de dos puntos porcentuales y tiene incertidumbre Monte Carlo importante.

### Conclusiones del estudio extendido

- La familia UW convergio en todos los ajustes ejecutados en los nueve escenarios y tres tamanos muestrales.
- Las estimaciones medias estuvieron, en general, cerca de los valores generadores.
- El ECM tendio a reducirse al aumentar n, aunque no en todas las celdas de forma estrictamente monotona.
- La cobertura observada fue cercana al nivel nominal en la mayoria de las celdas, pero requiere mas replicaciones para una evaluacion precisa.

Para una version final del estudio se recomienda aumentar a 500 o 1,000 replicas por combinacion si los recursos de computo lo permiten.

## 2. Aplicacion ilustrativa a datos reales: GasolineYield

Se utilizo el conjunto GasolineYield del paquete R betareg. La variable respuesta es yield y el modelo de covariable utiliza temp. La inspeccion ejecutada en R reporto:

| Estadistico | Resultado |
|---|---:|
| Numero de observaciones | 32 |
| Minimo de yield | 0.028 |
| Maximo de yield | 0.457 |
| Media | 0.1965938 |
| Mediana | 0.178 |
| Desviacion estandar | 0.1072242 |
| Observaciones en (0,1) | Todas |

Por tanto, esta respuesta satisface el soporte abierto requerido por UW.

### Modelos de intercepto

Se ajustaron UW, GB1, LOGITNO, BE y BEo a las mismas 32 observaciones.

| Familia | Convergencia | AIC | BIC/SBC | Iteraciones |
|---|---|---:|---:|---:|
| UW | Si | -49.43888 | -46.50741 | 17 |
| GB1 | Si | -48.89928 | -43.03634 | 154 |
| LOGITNO | Si | -51.41828 | -48.48681 | 2 |
| BE | Si | **-52.77074** | **-49.83927** | 5 |
| BEo | Si | -52.76969 | -49.83822 | 19 |

En el modelo de intercepto, BE obtuvo el menor AIC y BIC, seguido muy de cerca por BEo. UW no fue el modelo seleccionado por estos criterios en este conjunto de datos; su AIC fue menor que el de GB1, pero mayor que los de LOGITNO, BE y BEo.

Los parametros estimados por UW en el modelo de intercepto fueron:

- mu estimado = 0.1224151
- sigma estimado = 2.967199

### Modelos con temperatura como predictor de mu

Se comparo una estructura con yield ~ temp para el parametro mu y sigma con intercepto, manteniendo la misma estructura para las cinco familias.

| Familia | Convergencia | AIC | BIC/SBC | Iteraciones |
|---|---|---:|---:|---:|
| UW | Si | -70.86859 | -66.47138 | 22 |
| GB1 | Si | -70.31880 | -62.99012 | 30 |
| LOGITNO | Si | -73.35769 | -68.96048 | 2 |
| BE | Si | **-74.22644** | **-69.82923** | 5 |
| BEo | Si | -73.78538 | -69.38818 | 35 |

En esta especificacion, BE volvio a presentar los menores AIC y BIC, seguido por BEo y LOGITNO. UW no fue el modelo con mejor criterio de informacion, aunque obtuvo criterios menores que GB1.

La inclusion de temperatura redujo el AIC y BIC de los modelos frente a sus versiones de intercepto. Esto describe un mejor ajuste dentro de cada familia al incorporar el predictor; por si solo no demuestra una relacion causal.

### Interpretacion de la aplicacion real

La aplicacion a GasolineYield muestra que UW puede ajustarse correctamente a una variable real con soporte en (0,1), y que el algoritmo convergio para las cinco familias en las dos especificaciones probadas. Sin embargo, en este conjunto concreto los criterios AIC y BIC favorecieron a la familia BE (y en segundo lugar a BEo) en ambos modelos.

Este resultado no contradice el estudio Monte Carlo: los datos simulados fueron generados desde UW, mientras que GasolineYield es un conjunto real cuya distribucion subyacente no se conoce como UW. La comparacion real permite observar que UW es una alternativa viable, pero no necesariamente la seleccionada para todos los datos.

## 3. Limitaciones y trabajo pendiente

1. GasolineYield contiene solo 32 observaciones; las conclusiones son ilustrativas y exploratorias.
2. Se requiere complementar AIC/BIC con diagnosticos de residuos cuantiles, worm plots y revision de valores ajustados.
3. La especificacion con temperatura requiere analizar el coeficiente estimado y su incertidumbre antes de hacer afirmaciones sobre asociacion.
4. El estudio extendido Monte Carlo tiene 50 replicaciones por celda; aumentar a 500 o 1,000 mejoraria la precision de sesgo, ECM y cobertura.
5. La comparacion de familias se realizo en dos especificaciones comunes (intercepto y predictor temp), pero no demuestra superioridad universal de ninguna familia.

## 4. Archivos de resultados generados en Posit Cloud

Los nombres de archivos observados en la ejecucion fueron:

- `monte_carlo_UW_resumen_20261109_053627.csv`
- `monte_carlo_UW_detalle_20261109_053627.csv`
- `GasolineYield_comparacion_intercepto_20261109_053635.csv`
- `GasolineYield_comparacion_temperatura_20261109_053635.csv`
- `GasolineYield_curvas_UW_20261109_053635.csv`
- `aplicacion_GasolineYield_densidad_UW_20261109_053635.png`
- `aplicacion_GasolineYield_CDF_UW_20261109_053635.png`

Los archivos permanecen en el proyecto Posit Cloud del usuario; no se han subido automaticamente a este repositorio.
