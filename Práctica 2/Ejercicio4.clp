;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                       EJERCICIO 4 -  Bucle de espera                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Crea un trozo de código en clips que cuando ya no se pueda ejecutar ninguna
;; otra regla, el sistema siga esperando nuevos hechos y vaya imprimiendo cada
;; 1 minuto el mensaje “Estoy esperando nueva información”

;; Se inicializa el tiempo de inicio del primer intervalo
(defrule Bucle_1
  (declare (salience 999))
  (not (InicioTiempo ?t))

  =>
  (assert (InicioTiempo (time)))
)

;; Se inicializa la marca de tiempo
(defrule Bucle_2
  (declare (salience 999))
  (not (Tiempo ?t))

  =>
  (assert (Tiempo (time)))
)

;; Se inicializa el contador
(defrule Bucle_3
  (declare (salience 999))
  (not (Contador ?c))

  =>
  (assert (Contador 0))
  (assert (Seguir))
)

;; Se va actualizando el tiempo mientras se quiera seguir con el bucle
(defrule Bucle_4
  (declare (salience -999))
  (not (Acabar))
  ?Borrar <- (Tiempo ?t)

  =>
  (retract ?Borrar)
  (assert (Tiempo (time)))
)

;; Se pinta cada minuto por pantalla que se esperan nuevos hechos
(defrule Bucle_5
  (declare (salience -998))
  ?Borrar1 <- (InicioTiempo ?t1)
  ?Borrar2 <- (Tiempo ?t2)
  ?Borrar3 <- (Contador ?c)
  (test (> (- ?t2 ?t1) 60))

  =>
  (retract ?Borrar1)
  (retract ?Borrar2)
  (retract ?Borrar3)

  (assert (InicioTiempo (time)))
  (assert (Contador (+ ?c 1)))
  (printout t crlf "Estoy esperando nueva informacion")
)

;; Cuando pasan un número determinado de minutos (se ha pintado x veces por pantalla)
;; se pregunta si se quiere continuar el bucle
(defrule PreguntarSeguirBucle
  ?Borrar1 <- (Contador ?c & :(>= ?c 2))
  ?Borrar2 <- (Seguir)

  =>
  (retract ?Borrar1)
  (retract ?Borrar2)
  (assert (Contador 0))

  (printout t crlf "Quiere seguir esperando? (S/N)")
  (assert (Seguir (read)))
)

;; Si se responde que si, se añade el hecho "Seguir"
(defrule SeguirBucle
  ?Borrar <- (Seguir S)

  =>
  (retract ?Borrar)
  (assert (Seguir))
)

;; Si se responde que se qiere acabar, se añade el hecho "Acabar"
(defrule TerminarBucle
  ?Borrar <- (Seguir N)

  =>
  (retract ?Borrar)
  (assert (Acabar))
)
