;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;             EJERCICIO 3 -  Escribir y leer datos a un fichero             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; B - Leer
;;     Crea un trozo de programa en CLIPS que lea los datos guardados en el
;;     fichero del ejercicio anterior y añada los hechos correspondientes.

;; Se abre el fichero del que se va a leer los datos
(defrule AbrirLectura
  (declare (salience 30))

  =>
  (open "DatosT.txt" mydata "r")
  (assert (SeguirLeyendo))
)

;; Se leen los datos del fichero y se va guardando el dato que se lee. En este
;; caso cada hecho solo tiene dos valores, por lo que el primer valor se lee y
;; en esta regla
(defrule LeerValores
  (declare (salience 20))
   ?Borrar <- (SeguirLeyendo)

   =>
   (bind ?Leido (read mydata))
   (retract ?Borrar)

   (assert (ValorLeido ?Leido))
)

;; si el valor leído no es un fin de fichero, se agrega el hecho formado por el
;; valor leído en "LeerValores" y el siguiente valor, que se lee en esta regla
(defrule AniadirValores
  ?Borrar <- (ValorLeido ?Leido)
  (test (neq ?Leido EOF))

  =>
  (assert (T ?Leido (read mydata)))
  (assert (SeguirLeyendo))
  (retract ?Borrar)
)

;; Si se lee un fín de fichero, se elimina el Valor Leído
(defrule BorrarHechoValorLeido
  ?Borrar <- (ValorLeido ?Leido)
  (test (eq ?Leido EOF))

  =>
  (retract ?Borrar)
)

;; Si no quedan más valores por leer, se cierra el fichero. 
(defrule CerrarLectura
  (declare (salience -10))
  (not (SeguirLeyendo))

  =>
  (close mydata)
)
