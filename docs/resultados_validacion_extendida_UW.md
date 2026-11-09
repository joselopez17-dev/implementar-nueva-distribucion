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


### Inferencia de los coeficientes tras ajustar los modelos directamente

Para verificar los errores estandar se volvieron a ajustar los dos modelos directamente en el entorno global de Posit Cloud, usando `datos_gasolina` como objeto de datos. En estas ejecuciones `summary()` ya no produjo la advertencia de que `vcov` habia fallado.

**Modelo Unit-Weibull**

| Parametro | Estimacion | Error estandar | Estadistico t | Valor p |
|---|---:|---:|---:|---:|
| Intercepto de mu | -7.832075 | 1.367552 | -5.727 | 3.38e-06 |
| temp en mu | 0.015303 | 0.003117 | 4.910 | 3.26e-05 |
| Intercepto de sigma | 1.44227 | 0.13200 | 10.93 | 8.51e-12 |

La ecuacion estimada para el parametro mu, con enlace log, es:

[
log(mu_i)=-7.832075+0.015303,temp_i.
]

Por cada unidad adicional de temperatura, el parametro `mu` se multiplica por `exp(0.015303) ≈ 1.0154`, manteniendo la especificacion del modelo. Esto equivale a un aumento aproximado de 1.54 % en `mu` por unidad de temperatura; no es un aumento directo de 1.54 % en `yield`.

**Modelo Beta**

| Parametro | Estimacion | Error estandar | Estadistico t | Valor p |
|---|---:|---:|---:|---:|
| Intercepto de mu | -3.908155 | 0.503810 | -7.757 | 1.49e-08 |
| temp en mu | 0.007308 | 0.001446 | 5.055 | 2.17e-05 |
| Intercepto de sigma | -1.4486 | 0.1508 | -9.605 | 1.63e-10 |

Con enlace logit para `mu`, el coeficiente de temperatura es positivo y significativo. Su exponencial es aproximadamente 1.0073, que representa un cambio multiplicativo en los momios del parametro de media, no en la respuesta `yield` misma.

Los dos modelos muestran una asociacion positiva entre temperatura y el parametro de localizacion/media correspondiente. La interpretacion es asociativa, no causal. La muestra contiene solo 32 observaciones.

Los valores p anteriores sustituyen los errores estandar y valores p de las ejecuciones dentro de la funcion auxiliar, en las que se habia mostrado la advertencia `vcov has failed, option qr is used instead`. Los AIC, BIC/SBC y devianzas permanecieron iguales porque las estimaciones del modelo no cambiaron.

### Diagnostico de residuos

Los resumenes de residuos cuantiles fueron:

| Indicador | UW | Beta |
|---|---:|---:|
| Media | -0.0159859 | -0.0053822 |
| Varianza | 0.9215667 | 1.029345 |
| Asimetria | -0.6647822 | -0.1279713 |
| Curtosis | 2.646307 | 2.192978 |
| Correlacion de Filliben | 0.9768882 | 0.9936556 |

La media y varianza residuales de ambos modelos son razonablemente cercanas a 0 y 1, respectivamente. La correlacion de Filliben es mayor para Beta, y su asimetria residual absoluta es menor en esta muestra. Estos indicadores descriptivos sugieren un comportamiento mas cercano a la normalidad para los residuos de Beta en este conjunto de datos.

Los graficos contra valores ajustados y contra indice deben revisarse tambien para buscar patrones sistematicos, curvatura, cambios de dispersion o posibles observaciones influyentes. La correlacion de Filliben por si sola no constituye una prueba formal de normalidad ni garantiza que todos los supuestos del modelo se cumplan.



### Analisis de sensibilidad: observacion 30

La observacion 30 corresponde a:

| Variable | Valor |
|---|---:|
| yield | 0.085 |
| gravity | 31.8 |
| pressure | 0.2 |
| temp10 | 316 |
| temp | 365 |
| batch | 10 |

Sus residuos cuantiles normalizados fueron -2.401568 para UW y -2.075702 para Beta. Por tanto, la observacion fue relativamente inusual para ambos ajustes, aunque no supero el umbral absoluto de 3.

Se compararon las pendientes estimadas de temperatura en el parametro de localizacion/media al ajustar con las 32 observaciones y al retirar temporalmente la observacion 30:

| Modelo | Pendiente completa | Pendiente sin obs. 30 | Cambio absoluto | Cambio relativo aprox. |
|---|---:|---:|---:|---:|
| UW | 0.01530329 | 0.01761164 | +0.00230835 | +15.08 % |
| Beta | 0.007308239 | 0.007512288 | +0.000204049 | +2.79 % |

Los interceptos tambien cambiaron:

- UW: de -7.83207530 a -8.72068843.
- Beta: de -3.908155152 a -3.950461511.

La pendiente de temperatura de UW muestra mayor sensibilidad a la exclusion de esta observacion que la pendiente de Beta. Esto es un analisis de sensibilidad de caso eliminado; por si solo no constituye una medida formal de influencia ni justifica eliminar la observacion.

Antes de clasificarla como influyente debe compararse el cambio con el producido al eliminar cada una de las otras 31 observaciones, examinar medidas de apalancamiento/influencia apropiadas para GAMLSS y revisar la significancia y los intervalos de la pendiente en los modelos sin la observacion 30. La observacion se conserva en el analisis principal, salvo que exista una justificacion independiente de error de registro o exclusion.

### Pruebas adicionales de residuos y worm plots

Se extrajeron los residuos cuantiles normalizados de los modelos finales ajustados directamente en Posit Cloud y se realizaron pruebas Shapiro-Wilk, correlaciones de Spearman frente a temperatura y diagnosticos graficos.

#### Normalidad de residuos

| Indicador | UW | Beta |
|---|---:|---:|
| Shapiro-Wilk W | 0.9513 | 0.98225 |
| Valor p | 0.1569 | 0.8618 |
| Residuos con valor absoluto > 2 | 1 (observacion 30) | 1 (observacion 30) |
| Residuos con valor absoluto > 3 | 0 | 0 |

Con nivel de significancia de 5 %, no se rechaza la hipotesis nula de normalidad de los residuos para ninguno de los dos modelos. Esto no demuestra que los residuos sean exactamente normales; con n = 32 la prueba tiene potencia limitada y debe interpretarse junto con los graficos.

La observacion 30 presenta un residuo cuantitativo con valor absoluto mayor que 2 en ambos modelos. No hay residuos por encima de 3. Al aparecer en los dos ajustes, conviene revisar esa observacion en los datos originales, sin clasificarla automaticamente como error o punto influyente.

#### Asociacion de residuos con temperatura

| Modelo | Correlacion de Spearman | Valor p |
|---|---:|---:|
| UW | -0.02897 | 0.8749 |
| Beta | -0.04841 | 0.7925 |

No se encontro evidencia de una asociacion monotona entre los residuos y la temperatura para ninguno de los modelos. Los diagramas de dispersion tampoco muestran un patron monotono marcado. Esta prueba no reemplaza la inspeccion de otros patrones ni constituye una prueba completa de independencia.

#### Worm plots y graficos de diagnostico

En los worm plots generales, los puntos se mantienen en general dentro de las bandas de confianza. El worm plot de UW muestra una curvatura suave mas visible, mientras que el de Beta se observa mas cercano a la linea horizontal de referencia.

En los worm plots condicionados por tres intervalos de temperatura, no se aprecia una desviacion sistematica grande en ninguno de los modelos; los puntos permanecen en general dentro de las bandas graficadas. La lectura es exploratoria debido al tamano reducido de la muestra y al numero de observaciones por intervalo.

#### Conclusion del diagnostico

Ambos modelos presentan diagnosticos residuales globalmente aceptables para esta aplicacion exploratoria: no se rechazo normalidad mediante Shapiro-Wilk, no se detecto asociacion monotona significativa entre residuos y temperatura y los worm plots no muestran desviaciones grandes fuera de las bandas. Beta presenta indicadores descriptivos mas cercanos a la normalidad (mayor correlacion de Filliben, menor asimetria absoluta y mayor valor p de Shapiro-Wilk) y tambien obtuvo menores AIC/BIC en este conjunto de datos. Por tanto, para GasolineYield, la evidencia de ajuste favorece a Beta; UW sigue siendo un modelo convergente y razonable, pero no el seleccionado por los criterios de informacion ni por los indicadores residuales comparados.

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
