  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 2 - Obtener el valor mínimo de entre los campos de los hechos de un tipo ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A - En datos definidos por templates
;;     Supongamos que tenemos en nuestro sistema un deftemplate T que incluya un
;;     slot S de tipo numérico. Diseñar una función minSdeT de CLIPS que calcule
;;     el valor de SSS en la instancia de TTT con un menor valor de SSS.

;; Se define el Template que se va a usar
;; Para este ejercicio, se supone un Template TTT de un único campo, SSS, el valor
(deftemplate TTT
  (field SSS)
)

;; Se busca el hecho con el valor más pequeño. Ese valor será aquel que es menor a
;; todos los valores de los otros hechos. Si el menor valor está repetido, es decir,
;; hay dos hechos que tienen el mismo valor y no hay ningún valor menor que ellos,
;; se guarda ese valor.
;; En este ejemplo definido, no puede darse el caso ya que CLIPS no permite que
;; hayan dos hechos iguales
(defrule minSdeT
  (TTT (SSS ?v))
  (not (TTT (SSS ?v1 & :(< ?v1 ?v))))

  =>
  (assert (TTTMenorValor ?v))
)

;; Si se calcula un hecho como menor, hay dos hechos de menor valor y ninguno de
;; ellos se ha eliminado de la lista de hechos, se elimina el que representa mayor valor
(defrule ActualizarMinS_1
  ?Borrar <- (TTTMenorValor ?v1)
  ?Hecho <- (TTTMenorValor ?v2 & :(<= ?v2 ?v1))

  (test (neq ?Borrar ?Hecho))
  (not (Eliminar TTT ?v2))

  =>
  (retract ?Borrar)
)

;; Si se elimina el hecho que tenía el menor valor y n hay ningun otro hecho con
;; el mismo valor, se elimina el menor valor
(defrule ActualizarMinS_2
  ?Borrar1 <- (Eliminar TTT ?v1)
  ?Borrar2 <- (TTTMenorValor ?v1)
  (not (TTT (SSS ?v1)))

  =>
  (retract ?Borrar1)
  (retract ?Borrar2)
)

;; B - En datos de tipo vector ordenado
;;      Supongamos que tenemos en nuestro sistema un tipo de dato con estructura
;;      de vector ordenado de dimensión n+1 (T ?X1 ?X2 .. ?Xn), y supongamos que
;;      ?Xi siempre es un valor numérico. Diseñar una función minXiT de CLIPS
;;      que calcule el valor de ?Xi en el hecho de la memoria de trabajo con esa
;;      estructura con un menor valor de ?Xi.

;; Se busca el hecho con el valor más pequeño. Ese valor será aquel que es menor a
;; todos los valores de los otros hechos. Si el menor valor está repetido, es decir,
;; hay dos hechos que tienen el mismo valor y no hay ningún valor menor que ellos,
;; se guarda ese valor.
;; En este ejemplo definido, no puede darse el caso ya que CLIPS no permite que
;; hayan dos hechos iguales
(defrule minXiT
  (T ?v)
  (not (T ?v1 & :(< ?v1 ?v)))

  =>
  (assert (TMenorValor ?v))
)

;; Si se calcula un hecho como menor, hay dos hechos de menor valor y ninguno de
;; ellos se ha eliminado de la lista de hechos, se elimina el que representa mayor valor
(defrule ActualizarMinX_1
  ?Borrar <- (TMenorValor ?v1)
  ?Hecho <- (TMenorValor ?v2 & :(< ?v2 ?v1))

  (test (neq ?Borrar ?Hecho))
  (not (Eliminar T ?v2))

  =>
  (retract ?Borrar)
)

;; Si se elimina el hecho que tenía el menor valor y n hay ningun otro hecho con
;; el mismo valor, se elimina el menor valor
(defrule ActualizarMinX_2
  ?Borrar1 <- (Eliminar T ?v1)
  ?Borrar2 <- (TMenorValor ?v1)
  (not (T ?v1))

  =>
  (retract ?Borrar1)
  (retract ?Borrar2)
)
