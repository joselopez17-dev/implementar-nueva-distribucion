# Reporte de pruebas iniciales: Unit-Weibull en GAMLSS

## Entorno de ejecución

Las pruebas automatizadas se ejecutaron mediante GitHub Actions en un entorno Linux Ubuntu 24.04.

- R: 4.6.2
- `gamlss`: 5.5-5
- `gamlss.dist`: 6.1-11
- Workflow: [Unit-Weibull R tests](https://github.com/joselopez17-dev/implementar-nueva-distribucion/actions)

## Pruebas de las funciones de distribución

El script `tests/test_dUW.R` comprobó:

1. Densidad positiva dentro del soporte y cero fuera de `(0,1)`.
2. Comportamiento de la densidad en escala natural y logarítmica.
3. Validación de parámetros positivos.
4. Equivalencia numérica entre `dUW(x)` y `dWEI2(-log(x))/x`.
5. Integral numérica de la densidad igual a uno.
6. Monotonicidad y límites de la función de distribución acumulada.
7. Complementariedad de las colas inferior y superior.
8. Inversión entre las funciones de cuantiles y acumulada.
9. Escala logarítmica de las probabilidades.
10. Reciclaje de parámetros y generación de observaciones dentro de `(0,1)`.

Para tres combinaciones de parámetros, las integrales numéricas se imprimieron como:

```text
1 1 1
```

Las pruebas utilizaron tolerancias numéricas explícitas; el resultado anterior se presenta redondeado por la consola.

## Pruebas de la familia GAMLSS

El script `tests/test_UW.R` comprobó:

- La clase `gamlss.family` y los dos parámetros.
- La validación del soporte `0 < y < 1`.
- La positividad de `mu` y `sigma`.
- La coincidencia de las primeras derivadas analíticas con diferencias finitas.
- Un ajuste de intercepto de la familia `UW()` sobre una muestra simulada.

### Comparación de derivadas

Para una evaluación puntual, las salidas fueron:

| Derivada | Analítica | Diferencias finitas |
|---|---:|---:|
| `dldm` | 0.5514698 | 0.5514698 |
| `dldd` | 0.6329194 | 0.6329194 |

### Prueba de ajuste GAMLSS

Se simuló una muestra de tamaño 800 con semilla 2026 a partir de:

```r
rUW(800, mu = 0.7, sigma = 1.5)
```

Los parámetros utilizados y estimados fueron:

| Parámetro | Valor usado para simular | Estimación |
|---|---:|---:|
| `mu` | 0.7000 | 0.7266541 |
| `sigma` | 1.5000 | 1.5370610 |

El ajuste terminó sin error y devolvió estimaciones positivas y finitas. La diferencia entre los valores verdaderos y estimados es esperable en una muestra finita; esta prueba es un ensayo de integración de software, no un estudio Monte Carlo ni una evaluación formal del sesgo.

## Resultado

**Las pruebas automatizadas de esta versión inicial terminaron correctamente en GitHub Actions.**

Ejecución de referencia: [ver ejecución satisfactoria](https://github.com/joselopez17-dev/implementar-nueva-distribucion/actions/runs/42559747319).

## Qué no demuestra todavía esta validación

- No sustituye la revisión de la profesora ni la integración de los archivos en su instalación de GAMLSS.
- No valida el comportamiento para todos los valores posibles de los parámetros.
- No valida todavía un estudio de simulación Monte Carlo.
- No compara el ajuste de UW con Beta, Beta original, Logit-Normal o GB1 en una muestra real.
- No demuestra que la distribución sea superior a otras familias.

## Reproducción local

Desde la carpeta raíz del repositorio, en RStudio:

```r
install.packages(c("gamlss", "gamlss.dist"))
source("tests/run_all_tests.R")
```
