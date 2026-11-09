# Resultados de comparacion pareada de familias para UW

## Diseno del experimento

Se generaron 30 muestras independientes de tamano 500 desde la distribucion Unit-Weibull con parametros:

- mu = 0.7
- sigma = 1.5
- semilla = 20261109

En cada muestra se ajustaron cinco familias GAMLSS: UW, GB1, LOGITNO, BE y BEo. Se utilizo un maximo de 1,000 ciclos para el algoritmo de ajuste.

Las 30 muestras resultaron comunes a las cinco familias: todos los ajustes convergieron en las 30 replicas. Por tanto, las comparaciones de AIC y BIC se realizaron sobre exactamente las mismas muestras.

## Comparacion de criterios de informacion

Se define:

- Delta AIC = AIC de la competidora menos AIC de UW.
- Delta BIC = BIC de la competidora menos BIC de UW.

Un valor positivo indica un criterio de informacion menor para UW.

| Competidora | Delta AIC medio | Victorias UW por AIC | Delta BIC medio | Victorias UW por BIC |
|---|---:|---:|---:|---:|
| BE | 10.236940 | 27/30 | 10.236940 | 27/30 |
| BEo | 10.237223 | 27/30 | 10.237223 | 27/30 |
| LOGITNO | 6.455208 | 26/30 | 6.455208 | 26/30 |
| GB1 | 2.562401 | 26/30 | 10.991617 | 30/30 |

En el resumen global de seleccion entre las cinco familias, UW obtuvo el menor AIC en 23 de 30 replicas (76.67 %) y el menor BIC en 25 de 30 replicas (83.33 %).

El promedio de Delta AIC frente a GB1 es menor que frente a las demas familias, mientras que la diferencia de BIC es mayor. Este comportamiento es compatible con la penalizacion mas fuerte de BIC para modelos con mayor numero de parametros.

## Contrastes pareados

Se aplico la prueba de rangos con signo de Wilcoxon, con alternativa unilateral de que las diferencias competidora - UW son mayores que cero. Se utilizo la aproximacion con `exact = FALSE`.

Los valores p sin ajustar fueron:

| Competidora | p AIC | p BIC |
|---|---:|---:|
| BE | 2.483564e-06 | 2.483564e-06 |
| BEo | 2.483564e-06 | 2.483564e-06 |
| LOGITNO | 2.772344e-05 | 2.772344e-05 |
| GB1 | 3.300075e-05 | 9.126857e-07 |

El ajuste Benjamini-Hochberg realizado por separado para las cuatro comparaciones de AIC y las cuatro de BIC produjo:

| Competidora | p ajustado AIC | p ajustado BIC |
|---|---:|---:|
| BE | 4.967128e-06 | 3.311419e-06 |
| BEo | 4.967128e-06 | 3.311419e-06 |
| LOGITNO | 3.300075e-05 | 2.772344e-05 |
| GB1 | 3.300075e-05 | 3.311419e-06 |

Como comprobacion mas conservadora, tambien se aplico Benjamini-Hochberg conjuntamente a los ocho contrastes. Los valores de la tabla siguiente se recalcularon a partir de los valores p impresos en la consola (redondeados); para el reporte definitivo deben regenerarse con la precision completa desde el objeto de R usando el codigo incluido abajo:

| Contraste | p ajustado global |
|---|---:|
| AIC - BE | 3.973703e-06 |
| AIC - BEo | 3.973703e-06 |
| AIC - LOGITNO | 3.168393e-05 |
| AIC - GB1 | 3.300075e-05 |
| BIC - BE | 3.973703e-06 |
| BIC - BEo | 3.973703e-06 |
| BIC - LOGITNO | 3.168393e-05 |
| BIC - GB1 | 3.973703e-06 |

Los ocho valores ajustados globalmente obtenidos directamente en R son inferiores a 0.001. Esto aporta evidencia de que las diferencias pareadas competidora - UW tienden a ser positivas en el escenario de simulacion analizado. El contraste de Wilcoxon evalua la localizacion de las diferencias pareadas y no debe interpretarse como una prueba de superioridad universal.

Para obtener los valores globales exactos desde R, aplicar el ajuste a los ocho valores p originales almacenados en el objeto:

```r
p_global <- p.adjust(
  c(comparacion_pareada$p_AIC, comparacion_pareada$p_BIC),
  method = "BH"
)

comparacion_pareada$p_AIC_ajustado_global <-
  p_global[seq_len(nrow(comparacion_pareada))]

comparacion_pareada$p_BIC_ajustado_global <-
  p_global[nrow(comparacion_pareada) + seq_len(nrow(comparacion_pareada))]

print(comparacion_pareada, row.names = FALSE)
```


---

# Segundo escenario de simulacion: mu = 1.5 y sigma = 0.7

## Diseno

Se repitio la comparacion con 30 muestras independientes de tamano 500 generadas desde UW con `mu = 1.5` y `sigma = 0.7`. Se utilizo la semilla 20261109 y un maximo de 1,000 ciclos. Las cinco familias convergieron en las 30 replicas, por lo que la comparacion pareada incluyo las 30 muestras.

## Comparacion de AIC y BIC

| Competidora | Delta AIC medio | Victorias UW por AIC | Delta BIC medio | Victorias UW por BIC |
|---|---:|---:|---:|---:|
| BE | 8.387206 | 28/30 | 8.387206 | 28/30 |
| BEo | 8.387264 | 28/30 | 8.387264 | 28/30 |
| LOGITNO | 31.135521 | 29/30 | 31.135521 | 29/30 |
| GB1 | 2.089716 | 26/30 | 10.518932 | 30/30 |

En el resumen de seleccion entre las cinco familias, UW obtuvo el menor AIC en 25 de 30 replicas (83.33 %) y el menor BIC en 27 de 30 replicas (90.00 %).

## Contrastes de Wilcoxon y ajuste global

Se aplico la prueba de rangos con signo de Wilcoxon con alternativa unilateral de que las diferencias competidora - UW son mayores que cero. Los ocho valores p se ajustaron conjuntamente mediante Benjamini-Hochberg.

| Competidora | p global AIC | p global BIC |
|---|---:|---:|
| BE | 1.911127e-06 | 1.911127e-06 |
| BEo | 1.911127e-06 | 1.911127e-06 |
| LOGITNO | 1.911127e-06 | 1.911127e-06 |
| GB1 | 5.065849e-05 | 1.911127e-06 |

Los ocho valores ajustados globalmente son inferiores a 0.001. En este segundo escenario tambien se observa evidencia de diferencias pareadas favorables a UW.

## Sintesis de los dos escenarios

| Escenario | mu | sigma | Victorias AIC de UW | Victorias BIC de UW | Replicas comunes |
|---|---:|---:|---:|---:|---:|
| A | 0.7 | 1.5 | 23/30 (76.67 %) | 25/30 (83.33 %) | 30/30 |
| B | 1.5 | 0.7 | 25/30 (83.33 %) | 27/30 (90.00 %) | 30/30 |

En ambos escenarios las cinco familias convergieron en todas las muestras. UW obtuvo el menor AIC y BIC con mayor frecuencia que las familias competidoras y los contrastes pareados ajustados fueron inferiores a 0.001.

## Conclusion limitada al diseno evaluado

Los dos escenarios simulados aportan evidencia consistente de que UW recupera una ventaja de ajuste segun AIC y BIC cuando los datos provienen de la propia distribucion Unit-Weibull, para las combinaciones de parametros y el tamano muestral considerados.

Estos resultados no prueban superioridad universal de UW. La comparacion sigue condicionada a dos configuraciones de parametros, muestras de tamano 500 y 30 replicaciones por escenario. Para fortalecer la generalizacion se recomienda estudiar mas combinaciones de parametros y, si se dispone de ellos, conjuntos de datos reales con soporte en (0,1).


---

# Ajuste global de los 16 contrastes de ambos escenarios

Para controlar conjuntamente la multiplicidad de todas las comparaciones realizadas, se reunieron los ocho valores p del escenario A y los ocho del escenario B y se aplico Benjamini-Hochberg una sola vez a los 16 contrastes.

Los siguientes valores se obtuvieron directamente en R a partir de los valores p originales almacenados en los objetos `comparacion_pareada` y `comparacion_B`.

| Escenario | Competidora | p ajustado global AIC | p ajustado global BIC |
|---|---|---:|---:|
| A: mu = 0.7, sigma = 1.5 | BE | 3.311419e-06 | 3.311419e-06 |
| A: mu = 0.7, sigma = 1.5 | BEo | 3.311419e-06 | 3.311419e-06 |
| A: mu = 0.7, sigma = 1.5 | LOGITNO | 3.168393e-05 | 3.168393e-05 |
| A: mu = 0.7, sigma = 1.5 | GB1 | 3.520080e-05 | 3.311419e-06 |
| B: mu = 1.5, sigma = 0.7 | BE | 3.311419e-06 | 3.311419e-06 |
| B: mu = 1.5, sigma = 0.7 | BEo | 3.311419e-06 | 3.311419e-06 |
| B: mu = 1.5, sigma = 0.7 | LOGITNO | 3.311419e-06 | 3.311419e-06 |
| B: mu = 1.5, sigma = 0.7 | GB1 | 5.065849e-05 | 3.311419e-06 |

El mayor valor p ajustado entre los 16 contrastes fue 5.065849e-05. Por tanto, los 16 contrastes permanecen por debajo de 0.001 tras el ajuste conjunto.

## Interpretacion conjunta

En los dos escenarios simulados, las diferencias pareadas de AIC y BIC (criterio de la competidora menos criterio de UW) favorecen a UW. Esta conclusion se mantiene al controlar conjuntamente la tasa de falsos descubrimientos de los 16 contrastes.

La evidencia se limita a los dos escenarios de parametros, a muestras de tamano 500 y a 30 replicaciones por escenario. No implica superioridad universal ni reemplaza una evaluacion con otros escenarios y datos reales.


---

# Tercer y cuarto escenarios de simulacion

Se completaron dos escenarios adicionales, ambos con 30 replicas de tamano 500, un maximo de 1,000 ciclos y convergencia de las cinco familias en las 30 replicas.

## Escenario C: mu = 0.7 y sigma = 0.7

| Familia | AIC medio | BIC medio | Victorias UW AIC | Victorias UW BIC |
|---|---:|---:|---:|---:|
| UW | -490.7401 | -482.3108 | 27/30 (90.00 %) | 30/30 (100 %) |
| GB1 | -488.5656 | -471.7072 | 3/30 (10.00 %) | 0/30 (0 %) |
| BE | -472.1506 | -463.7214 | 0/30 (0 %) | 0/30 (0 %) |
| BEo | -472.1506 | -463.7214 | 0/30 (0 %) | 0/30 (0 %) |
| LOGITNO | -321.6707 | -313.2414 | 0/30 (0 %) | 0/30 (0 %) |

UW obtuvo el menor AIC en 27 de 30 replicas y el menor BIC en las 30 replicas.

## Escenario D: mu = 1.5 y sigma = 1.5

| Familia | AIC medio | BIC medio | Victorias UW AIC | Victorias UW BIC |
|---|---:|---:|---:|---:|
| UW | -168.9657 | -160.5365 | 24/30 (80.00 %) | 26/30 (86.67 %) |
| GB1 | -166.1275 | -149.2691 | 2/30 (6.67 %) | 0/30 (0 %) |
| BE | -163.8302 | -155.4010 | 4/30 (13.33 %) | 4/30 (13.33 %) |
| BEo | -163.8298 | -155.4006 | 0/30 (0 %) | 0/30 (0 %) |
| LOGITNO | -152.2902 | -143.8610 | 0/30 (0 %) | 0/30 (0 %) |

UW obtuvo el menor AIC en 24 de 30 replicas y el menor BIC en 26 de 30 replicas.

## Resumen descriptivo de los cuatro escenarios

| Escenario | mu | sigma | Victorias UW AIC | Victorias UW BIC | Convergencia de todas las familias |
|---|---:|---:|---:|---:|---:|
| A | 0.7 | 1.5 | 23/30 (76.67 %) | 25/30 (83.33 %) | 30/30 |
| B | 1.5 | 0.7 | 25/30 (83.33 %) | 27/30 (90.00 %) | 30/30 |
| C | 0.7 | 0.7 | 27/30 (90.00 %) | 30/30 (100 %) | 30/30 |
| D | 1.5 | 1.5 | 24/30 (80.00 %) | 26/30 (86.67 %) | 30/30 |

En los cuatro escenarios, todas las familias convergieron en las 30 replicas y UW obtuvo el menor AIC y BIC con mayor frecuencia. Estos son resultados descriptivos de seleccion por replica; aun falta aplicar pruebas pareadas de Wilcoxon a los escenarios C y D y un ajuste global conjunto de los 32 contrastes de los cuatro escenarios.

## Alcance

Los cuatro escenarios corresponden a un diseno factorial 2 x 2 de parametros generadores (`mu` en {0.7, 1.5} y `sigma` en {0.7, 1.5}), con 30 muestras de tamano 500 por escenario. Este diseno explora cuatro combinaciones, pero no representa todos los posibles valores de los parametros ni sustituye una evaluacion con datos reales.


---

# Ajuste global de los 32 contrastes de los cuatro escenarios

Se reunieron los 32 valores p: cuatro competidoras por dos criterios de informacion (AIC y BIC) en cada uno de los cuatro escenarios. Se aplico el procedimiento Benjamini-Hochberg conjuntamente a este conjunto de 32 contrastes. Este procedimiento controla la tasa de falsos descubrimientos (FDR), no el error familiar (FWER).

Los valores siguientes se obtuvieron directamente en R:

| Escenario | Competidora | p ajustado global AIC | p ajustado global BIC |
|---|---|---:|---:|
| A (mu=0.7, sigma=1.5) | BE | 3.455394e-06 | 3.455394e-06 |
| A (mu=0.7, sigma=1.5) | BEo | 3.455394e-06 | 3.455394e-06 |
| A (mu=0.7, sigma=1.5) | LOGITNO | 2.957167e-05 | 2.957167e-05 |
| A (mu=0.7, sigma=1.5) | GB1 | 3.406529e-05 | 2.310018e-06 |
| B (mu=1.5, sigma=0.7) | BE | 2.816398e-06 | 2.816398e-06 |
| B (mu=1.5, sigma=0.7) | BEo | 2.816398e-06 | 2.816398e-06 |
| B (mu=1.5, sigma=0.7) | LOGITNO | 2.310018e-06 | 2.310018e-06 |
| B (mu=1.5, sigma=0.7) | GB1 | 5.065849e-05 | 2.310018e-06 |
| C (mu=0.7, sigma=0.7) | BE | 2.310018e-06 | 2.310018e-06 |
| C (mu=0.7, sigma=0.7) | BEo | 2.310018e-06 | 2.310018e-06 |
| C (mu=0.7, sigma=0.7) | LOGITNO | 2.310018e-06 | 2.310018e-06 |
| C (mu=0.7, sigma=0.7) | GB1 | 2.035069e-05 | 2.310018e-06 |
| D (mu=1.5, sigma=1.5) | BE | 8.446510e-06 | 8.446510e-06 |
| D (mu=1.5, sigma=1.5) | BEo | 8.446510e-06 | 8.446510e-06 |
| D (mu=1.5, sigma=1.5) | LOGITNO | 2.310018e-06 | 2.310018e-06 |
| D (mu=1.5, sigma=1.5) | GB1 | 2.640372e-06 | 2.310018e-06 |

El mayor valor p ajustado fue 5.065849e-05. Por tanto, los 32 contrastes rechazaron la hipotesis nula al nivel de significancia de 0.001. En todos los contrastes la alternativa fue que la diferencia competidora - UW es positiva.

## Conclusion conjunta de los cuatro escenarios

En las cuatro combinaciones de parametros estudiadas, las cinco familias convergieron en las 30 muestras de cada escenario. La familia UW obtuvo el menor AIC y BIC con mayor frecuencia que cada competidora, y las pruebas pareadas de Wilcoxon mantuvieron resultados significativos tras el ajuste BH global de los 32 contrastes.

Esta evidencia respalda un mejor ajuste relativo de UW bajo los escenarios simulados considerados. No demuestra que UW sea la mejor distribucion para cualquier poblacion o conjunto de datos: el diseno abarca cuatro puntos de parametros, muestras de tamano 500 y 30 replicas por punto. Se recomienda completar el estudio con mas combinaciones de parametros, otros tamanos de muestra y aplicaciones a datos reales cuando existan observaciones adecuadas.

## Interpretacion y alcance

Los resultados muestran que, cuando los datos se generan desde UW(mu = 0.7, sigma = 1.5), la familia UW obtiene con mayor frecuencia los menores AIC y BIC entre las cinco familias consideradas. La convergencia completa en las 30 muestras permite realizar una comparacion pareada sin excluir replicas.

La prueba de Wilcoxon contrasta la localizacion de las diferencias pareadas; no es una prueba de igualdad de medias. Su interpretacion se refiere a que las diferencias competidora - UW tienden a ser positivas, bajo los supuestos del contraste de rangos con signo.

**El resultado no demuestra superioridad universal de UW.** La simulacion se realizo bajo un unico escenario generador, con un tamano muestral de 500 y cinco familias candidatas. Para generalizar se requieren otros valores de parametros, otros tamanos de muestra y, si estan disponibles, conjuntos de datos reales.

Los resultados anteriores corresponden a una simulacion controlada y no deben presentarse como evidencia de que UW sera la mejor familia para cualquier variable real en (0,1).

## Reproducibilidad

La ejecucion se realizo con:

```r
resultado_comparacion_final <- comparar_familias_UW(
  replicas = 30,
  n = 500,
  mu = 0.7,
  sigma = 1.5,
  semilla = 20261109,
  max_cycles = 1000
)
```

Los archivos CSV generados en Posit Cloud contienen los resultados detallados, el resumen por familia y el resumen pareado.
