# Revisión de familias existentes en GAMLSS para respuestas unitarias

## Alcance de la revisión

Se revisó la documentación de los paquetes `gamlss` y `gamlss.dist` disponibles en CRAN. Esta revisión distingue las familias cuya respuesta es continua dentro de `(0, 1)) de las familias que permiten masa puntual en cero y/o uno.

## Familias continuas en el intervalo unitario

| Familia | Número de parámetros | Observación |
|---|---:|---|
| `BE()` | 2 | Beta; soporte continuo `0 < x < 1`. |
| `BEo()` | 2 | Parametrización alternativa/original de Beta; soporte unitario. |
| `GB1()` | 4 | Beta generalizada tipo 1; soporte `0 < x < 1`. |
| `LOGITNO()` | 2 | Logit-Normal; soporte `0 < x < 1`. |

## Familias con inflación en los extremos

Estas familias son útiles cuando los datos pueden tener probabilidad puntual en cero, uno o ambos:

- `BEZI()`: Beta con inflación en cero.
- `BEOI()`: Beta con inflación en uno.
- `BEINF0()`: parametrización inflada en cero.
- `BEINF1()`: parametrización inflada en uno.
- `BEINF()`: Beta inflada en los extremos.

No deben confundirse con una distribución absolutamente continua en el intervalo abierto `(0,1)`, porque incluyen masa puntual en uno o ambos extremos.

## Ubicación de WEI2

La documentación clasifica `WEI2()` entre las distribuciones continuas de soporte positivo (`y > 0`), no entre las familias unitarias. Su densidad es:

```math
f_Y(y;\\mu,\\sigma)=\\mu\\sigma y^{\\sigma-1}
\\exp(-\\mu y^\\sigma), \\qquad y>0.
```

La Unit-Weibull se obtiene mediante la transformación `X = exp(-Y)`; por tanto, su soporte es `0 < x < 1`. WEI2 se utiliza como referencia matemática y computacional para la transformación, pero la familia UW debe validar su propio soporte, densidad, acumulada, cuantiles, simulación y objeto `gamlss.family`.

## Nota sobre `fitDist()`

En la clasificación documentada para `fitDist(type = "real0to1")) aparecen:

`BE`, `BEo`, `BEINF0`, `BEINF1`, `BEOI`, `BEZI`, `BEINF` y `GB1`.

`LOGITNO()` también está documentada como una distribución con soporte `0 < x < 1`, pero no figura en esa lista predeterminada de `real0to1`. Se puede considerar por separado al comparar modelos, usando el argumento `extra` de `fitDist()` cuando haya datos disponibles.

## Recomendación para la comparación

Para una muestra estrictamente interior (`0 < x_i < 1`) y una nueva distribución Unit-Weibull de dos parámetros, conviene comenzar la comparación con:

1. `BE()` como referencia beta de dos parámetros.
2. `BEo()` como otra parametrización beta.
3. `LOGITNO()` como alternativa continua de dos parámetros.
4. `GB1()` como alternativa más flexible de cuatro parámetros.

Las familias infladas se agregan si el conjunto de datos contiene observaciones exactamente iguales a cero o uno, o si el análisis requiere modelar explícitamente masas en los extremos.

La comparación empírica con AIC/BIC requiere una muestra real. Sin datos, esta revisión identifica familias candidatas, pero no permite afirmar cuál ajusta mejor.

## Fuentes

- Documentación CRAN de `gamlss`, sección `fitDist()`: https://cran.r-project.org/web/packages/gamlss/refman/gamlss.html
- Documentación CRAN de `gamlss.dist`: https://cran.r-project.org/web/packages/gamlss.dist/refman/gamlss.dist.html
- GAMLSS, listado de distribuciones: https://www.gamlss.com/information/distributions/
- WEI2 en `gamlss.dist`: https://cran.r-project.org/web/packages/gamlss.dist/refman/gamlss.dist.html
