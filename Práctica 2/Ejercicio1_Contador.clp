;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                EJERCICIO 1 - Contar hechos de un tipo                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; B - Mediante contador
;;     Crea un trozo de código en CLIPS (cuantas menos reglas se usen mejor),
;;     de forma que la memoria de trabajo siempre tenga el hecho
;;     (NumeroHechos XXX n) con la semántica indicada en el apartado anterior.

;; Agregar un nuevo hecho por cada hecho del tipo XXX añadido
(defrule ContarHechosContador
  ?Hecho <- (XXX $?)

  =>
  (assert (Sumar XXX ?Hecho))
)

;; Incrementar el contador por cada hecho del tipo 'Sumar XXX' en la base de hechos
(defrule IncrementarContador
  ?Borrar1 <- (Sumar XXX ?)
  ?Borrar2 <- (NumeroHechos XXX ?n)

  =>
  (retract ?Borrar1)
  (retract ?Borrar2)
  (assert (NumeroHechos XXX (+ ?n 1)))
)

;; Decrementar el contador por cada hecho del tipo 'Eliminar XXX' en la base de hechos
(defrule DecrementarContador
  ?Borrar1 <- (Eliminar XXX ?)
  ?Borrar2 <- (NumeroHechos XXX ?n)

  =>
  (retract ?Borrar1)
  (retract ?Borrar2)
  (assert (NumeroHechos XXX (- ?n 1)))
)

;; Si no hay contador del número de hechos del tipo XXX, añadirlo
(defrule InicializarContador
  (not (NumeroHechos XXX ?n))

  =>
  (assert (NumeroHechos XXX 0))
)
