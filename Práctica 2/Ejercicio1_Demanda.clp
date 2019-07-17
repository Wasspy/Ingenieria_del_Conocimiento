;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                EJERCICIO 1 - Contar hechos de un tipo                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A - Bajo Demanda
;;     Crea un trozo de código en CLIPS (cuantas menos reglas se usen mejor)
;;     que cuando en la base de hechos aparezca (ContarHechos XXX) acabe
;;     añadiendo el hecho (NumeroHechos XXX n), siendo n el número de hechos de
;;     la memoria de la forma vector ordenado que empieza por XXX, es decir de
;;     la forma (XXX ? … ? ), asegurándose que no haya varios
;;     (NumeroHechos XXX n) en la memoria de trabajo.

;; Agregar un nuevo hecho por cada hecho del tipo XXX que haya en la base de hechos
(defrule ContarHechosDemanda_1
  (ContarHechos XXX)
  ?Hecho <- (XXX $?)

  =>
  (assert (Contado XXX ?Hecho))
)

;; Se agrega un contador de hechos a 0
(defrule ContarHechosDemanda_2
  (declare (salience 10))
  (ContarHechos XXX)

  =>
  (assert (NumeroHechos XXX 0))
)

;; Se borran los contadores antiguos
(defrule ContarHechosDemanda_3
  (declare (salience 10))
  (NumeroHechos XXX 0)
  ?Borrar <- (NumeroHechos XXX ?n & :(> ?n 0))

  =>
  (retract ?Borrar)
)

;; Se cuenta el número de hechos que hay del tipo XXX
(defrule ContarHechosDemanda_4
  (ContarHechos XXX)
  ?Borrar1 <- (Contado XXX ?)
  ?Borrar2 <- (NumeroHechos XXX ?n)

  =>
  (retract ?Borrar1)
  (retract ?Borrar2)
  (assert (NumeroHechos XXX (+ ?n 1)))
)

;; Se borra el hecho de 'ContarHechos XXX' cuando se hayan contado todos
(defrule ContarHechosDemanda_5
  (declare (salience -10))
  ?Borrar <- (ContarHechos XXX)
  (not(Contado XXX ?))

  =>
  (retract ?Borrar)
)
