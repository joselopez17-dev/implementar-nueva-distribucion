# Interpretacion de las curvas de la distribucion Unit-Weibull

## 1. Distribucion estudiada

La distribucion Unit-Weibull (UW) tiene soporte abierto:

[
0 < x < 1,
]

con parametros (mu>0) y (sigma>0). Sus funciones son:

[
F(x;mu,sigma)=exp{-mu[-ln(x)]^sigma}
]

y

[
f(x;mu,sigma)=
rac{musigma}{x}[-ln(x)]^{sigma-1}
exp{-mu[-ln(x)]^sigma}.
]

Las figuras se generaron para cuatro combinaciones de parametros, con una malla de valores interiores al soporte: (x) desde 0.0005 hasta 0.999. Por tanto, los extremos 0 y 1 no aparecen como puntos evaluados en las graficas.

## 2. Interpretacion de las funciones de densidad

### Escenarios A y D: sigma = 1.5

- Escenario A: mu = 0.7 y sigma = 1.5.
- Escenario D: mu = 1.5 y sigma = 1.5.

En ambos casos la densidad se aproxima a cero cuando x se acerca a 0 y cuando x se acerca a 1. Presenta un maximo interior, por lo que la curva tiene una forma de monticulo.

Al comparar A y D, sigma se mantiene fijo y aumenta mu de 0.7 a 1.5. La concentracion de la distribucion se desplaza hacia valores mas grandes de x. Esto es coherente con la funcion acumulada: para un x fijo en (0,1), al aumentar mu disminuye F(x), lo que corresponde a una distribucion estocasticamente desplazada hacia valores mayores.

### Escenarios B y C: sigma = 0.7

- Escenario B: mu = 1.5 y sigma = 0.7.
- Escenario C: mu = 0.7 y sigma = 0.7.

En ambos escenarios la densidad aumenta al aproximarse a los extremos 0 y 1 y presenta un minimo interior. La curva tiene una forma de U.

Este comportamiento se explica por los limites de la densidad:
- Cuando x tiende a 1 por la izquierda, el factor ([-ln(x)]^{sigma-1}) tiende a infinito si (0<sigma<1).
- Cuando x tiende a 0 por la derecha, el termino exponencial no domina el factor (1/x) para (0<sigma<1), y la densidad tambien tiende a infinito.

Las graficas no muestran literalmente valores infinitos porque el script evita evaluar x = 0 y x = 1. El crecimiento observado cerca de los extremos es la representacion numerica de esos limites.

Una densidad que diverge en un extremo puede seguir siendo una funcion de densidad valida: lo que se requiere es que sea no negativa e integre uno sobre su soporte. No significa que haya una probabilidad positiva concentrada exactamente en 0 o en 1. La distribucion es continua y no asigna masa puntual a los extremos.

### Papel de sigma

Las cuatro figuras permiten observar una diferencia cualitativa asociada a sigma:
- Si sigma es mayor que 1, la densidad tiene un maximo interior y tiende a cero en ambos extremos.
- Si sigma esta entre 0 y 1, la densidad tiene un minimo interior y diverge al acercarse a ambos extremos.
- Si sigma = 1, la funcion se simplifica a (F(x)=x^mu) y (f(x)=mu x^{mu-1}). Este caso especial es monotono si mu es distinto de 1 y uniforme si mu = 1.

## 3. Interpretacion de las funciones de distribucion acumulada

Las cuatro curvas acumuladas son crecientes y van desde valores cercanos a 0 hasta valores cercanos a 1 al recorrer x de izquierda a derecha. Esto es lo esperado para una funcion de distribucion acumulada sobre (0,1).

- Para sigma = 1.5 (A y D), la curva tiene una forma sigmoidal: crece lentamente en los extremos y mas rapidamente en la zona donde la densidad es mayor.
- Para sigma = 0.7 (B y C), la pendiente es grande cerca de los extremos y mas pequena en la region donde la densidad presenta su minimo.

Para un x fijo, aumentar mu reduce F(x). En consecuencia, una mayor mu desplaza la distribucion hacia valores mas altos de X.

## 4. Consistencia entre densidad y acumulada

La relacion teorica es:

[
rac{d}{dx}F(x;mu,sigma)=f(x;mu,sigma).
]

Por ello:
- Donde la densidad es alta, la acumulada aumenta rapidamente.
- Donde la densidad es baja, la acumulada aumenta lentamente.
- La acumulada siempre es no decreciente y sus limites en los extremos del soporte son 0 y 1.

Las figuras generadas muestran cualitativamente esta correspondencia entre la densidad y la acumulada.

## 5. Conclusiones de las figuras

Las curvas evidencian que los parametros (mu) y (sigma) controlan aspectos distintos de la forma de UW. En las combinaciones estudiadas, (sigma) determina si la densidad tiene forma de monticulo ((sigma>1)) o forma de U ((0<sigma<1)), mientras que (mu) modifica la ubicacion de la distribucion dentro del intervalo unitario.

Estas observaciones corresponden a las cuatro combinaciones simuladas y no sustituyen un analisis exhaustivo para todos los valores posibles de los parametros.
