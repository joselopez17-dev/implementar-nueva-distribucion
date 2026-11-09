# Implementación de la distribución Unit-Weibull en GAMLSS

Implementación de la distribución **Unit-Weibull (UW)** como una nueva familia en el paquete **GAMLSS de R**, siguiendo la guía de trabajo del curso.

## Descripción del proyecto

La distribución Unit-Weibull tiene soporte en el intervalo abierto (0, 1). Se obtiene mediante la transformación de una variable Weibull, $X = e^{-Y}$.

Su función de distribución acumulada es:

$$
F(x;\mu,\sigma)=\exp\left[-\mu(-\log x)^\sigma\right],
\qquad 0<x<1,\quad \mu,\sigma>0.
$$

La función de densidad es:

$$
f(x;\mu,\sigma)=\frac{\mu\sigma}{x}(-\log x)^{\sigma-1}
\exp\left[-\mu(-\log x)^\sigma\right].
$$

## Relación con WEI2 de GAMLSS

La parametrización de WEI2 es:

$$
f_Y(y;\mu,\sigma)=\sigma\mu y^{\sigma-1}
\exp(-\mu y^\sigma),\qquad y>0.
$$

Aplicando $Y=-\log(X)$ y el jacobiano $|dY/dX|=1/X$, se obtiene:

$$
f_X(x;\mu,\sigma)=\frac{1}{x}f_Y(-\log x;\mu,\sigma).
$$

Por tanto, la transformación conserva los parámetros: $\mu=\alpha$ y $\sigma=\beta$. El script de comparación algebraica y numérica está en [`examples/transformacion_WEI2_UW.R`](examples/transformacion_WEI2_UW.R).

**Importante:** WEI2 se utiliza aquí como distribución de referencia para comprobar la transformación. La familia Unit-Weibull que se desarrolle para GAMLSS debe tener sus propias funciones y derivadas, además de las validaciones correspondientes.

## Familias existentes en GAMLSS para datos unitarios

Se documentaron las familias disponibles para respuestas entre cero y uno y se distinguieron las familias continuas de las que admiten masa puntual en los extremos. Consulta [`docs/familias_0_1_en_gamlss.md`](docs/familias_0_1_en_gamlss.md).

El script [`examples/verificar_familias_gamlss.R`](examples/verificar_familias_gamlss.R) comprueba qué funciones están presentes en la instalación local de `gamlss.dist`. También incluye una plantilla para comparar ajustes con `fitDist()` cuando se disponga de una muestra real.

Entre las referencias que conviene revisar están `BE()`, `BEo()`, `GB1()` y `LOGITNO()`. Las familias infladas, como `BEZI()`, `BEOI()` y `BEINF()`, deben considerarse según exista o no masa puntual en los extremos.

## Objetivo general

Implementar la distribución Unit-Weibull como una nueva familia en el paquete GAMLSS de R y validar su comportamiento mediante ejemplos de estimación y un estudio de simulación.

## Objetivos específicos

- Implementar y validar la función de densidad, incluyendo el cálculo en escala logarítmica.
- Contrastar la parametrización con la distribución WEI2 de GAMLSS.
- Derivar y verificar las funciones de primeras derivadas requeridas por GAMLSS.
- Construir la familia Unit-Weibull y evaluar su ajuste.
- Desarrollar ejemplos reproducibles.
- Realizar un estudio de simulación Monte Carlo y presentar sus resultados en un póster académico.

## Estructura del proyecto

```text
unit-weibull-gamlss/
├── README.md
├── R/
│   ├── dUW.R
│   ├── examples_dUW.R
│   ├── UW.R
│   ├── examples_UW.R
│   └── utils.R
├── tests/
├── examples/
│   ├── transformacion_WEI2_UW.R
│   └── verificar_familias_gamlss.R
├── simulation/
│   └── resultados/
├── docs/
│   └── familias_0_1_en_gamlss.md
└── poster/
```

Los cinco archivos R indicados corresponden a los entregables principales del proyecto. Los scripts de `examples/` son auxiliares y no reemplazan ninguno de los cinco entregables.

## Estado del proyecto

**En desarrollo.** La equivalencia algebraica con WEI2 está documentada. Se inició la revisión de familias existentes en GAMLSS para el intervalo unitario. Falta ejecutar las pruebas en RStudio y construir y validar la familia UW.

## Referencia principal

Mazucheli, J., Menezes, A. F. B. y Ghitany, M. E. (2018). *The Unit-Weibull Distribution and Associated Inference*. Journal of Applied Probability and Statistics.

## Referencia de WEI2

Documentación de `gamlss.dist`: [WEI2 — Weibull parameterization](https://cran.r-project.org/web/packages/gamlss.dist/refman/gamlss.dist.html).

## Tecnologías

- R
- RStudio
- GAMLSS

## Contexto académico

Ingeniería Industrial — Universidad de Antioquia  
2026

## Autor

José Miguel López Doria
