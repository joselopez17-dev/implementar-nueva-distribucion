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

La parametrización $(\mu,\sigma)$ se plantea siguiendo la convención de GAMLSS. La correspondencia con la familia WEI2 se encuentra pendiente de contrastación con su implementación y documentación.

## Objetivo general

Implementar la distribución Unit-Weibull como una nueva familia en el paquete GAMLSS de R y validar su comportamiento mediante ejemplos de estimación y un estudio de simulación.

## Objetivos específicos

- Implementar y validar la función de densidad, incluyendo el cálculo en escala logarítmica.
- Contrastar la parametrización con la distribución WEI2 de GAMLSS.
- Derivar y verificar las funciones de primeras derivadas requeridas por GAMLSS.
- Construir la familia Unit-Weibull y evaluar su ajuste.
- Desarrollar ejemplos reproducibles.
- Realizar un estudio de simulación Monte Carlo y presentar sus resultados en un póster académico.

## Estructura prevista

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
├── simulation/
│   └── resultados/
├── docs/
└── poster/
```

Los cinco archivos R indicados corresponden a los entregables principales del proyecto. Las carpetas adicionales permitirán organizar pruebas, aplicaciones, simulaciones, documentación y el póster.

## Estado del proyecto

**En desarrollo.** La parametrización, las derivadas y el comportamiento de la familia deben verificarse antes de considerar terminada la implementación.

## Referencia principal

Mazucheli, J., Menezes, A. F. B. y Ghitany, M. E. (2018). *The Unit-Weibull Distribution and Associated Inference*. Journal of Applied Probability and Statistics.

## Tecnologías

- R
- RStudio
- GAMLSS

## Contexto académico

Ingeniería Industrial — Universidad de Antioquia  
2026

## Autor

José Miguel López Doria
