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
f_X(x;\mu,\sigma)=\frac{1}{x}
f_Y(-\log x;\mu,\sigma).
$$

Por tanto, la transformación conserva los parámetros: $\mu=\alpha$ y $\sigma=\beta$. El script de comparación algebraica y numérica está en `examples/transformacion_WEI2_UW.R`.

**Importante:** WEI2 se utiliza aquí como distribución de referencia para comprobar la transformación. La familia Unit-Weibull que se desarrolle para GAMLSS debe tener sus propias funciones y derivadas, además de las validaciones correspondientes.

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
│   └── transformacion_WEI2_UW.R
├── simulation/
│   └── resultados/
├── docs/
└── poster/
```

Los cinco archivos R indicados corresponden a los entregables principales del proyecto. El script ubicado en `examples/` es un ejemplo auxiliar de transformación y contraste con WEI2; no reemplaza ninguno de los cinco entregables.

## Estado del proyecto

**En desarrollo.** La equivalencia algebraica con WEI2 está documentada. Falta ejecutar las pruebas en RStudio y validar la familia y sus derivadas dentro de GAMLSS.

## Referencia principal

Mazucheli, J., Menezes, A. F. B. y Ghitany, M. E. (2018). *The Unit-Weibull Distribution and Associated Inference*. Journal of Applied Probability and Statistics.

## Referencia de WEI2

Documentación de `gamlss.dist`: [WEI2 — Weibull parameterization](https://rdrr.io/cran/gamlss.dist/man/WEI2.html).

## Tecnologías

- R
- RStudio
- GAMLSS

## Contexto académico

Ingeniería Industrial — Universidad de Antioquia  
2026

## Autor

José Miguel López Doria
