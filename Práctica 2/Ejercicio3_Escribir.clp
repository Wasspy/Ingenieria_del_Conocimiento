;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;             EJERCICIO 3 -  Escribir y leer datos a un fichero             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A - Escribir
;;     Supongamos que tenemos en nuestro sistema un tipo de dato con estructura
;;     de vector ordenado de dimensión n+1 (T ?X1 ?X2 … ?Xn). Crea un trozo de
;;     código en CLIPS (cuantas menos reglas se usen mejor) que escriba todos
;;     los hechos de ese tipo al fichero de texto DatosT.txt, ordenados por el
;;     valor de la posición Xi. Los datos se escribirán uno por línea, separando
;;     en cada línea cada dato del vector por un espacio en blanco. Así
;;     (T x1 x2 … xn) aparecería en el fichero de texto como la línea x1 x2 … xn

;; Se abre el archivo "Datos.txt" para escritura
(defrule AbrirEscritura
  (declare (salience -20))

  =>
  (open "DatosT.txt" mydata "w")
  (assert (FicheroAbierto))
 )

;; Se escribe en el fichero el dato con menor valor
(defrule EscribirDato1
  (declare (salience -30))
  (FicheroAbierto)
  (not (UltimoEscrito ?H ?v))
  ?Hecho <- (T ?v1 ?n)
  (not (T ?v2 & :(< ?v2 ?v1) ?n2))

  =>
  (assert (UltimoEscrito ?Hecho ?v1))
  (printout mydata ?v1 " " ?n crlf)
)

;; Se escriben el resto de datos desde el más pequeño al mayor
(defrule EscribirDato2
  (declare (salience -30))
  (FicheroAbierto)

  ?Borrar <- (UltimoEscrito ?H ?v)
  ?Hecho <- (T ?v1 & :(< ?v ?v1) ?n)

  (not (T ?v2 & :(> ?v2 ?v) & :(< ?v2 ?v1) ?))

  =>
  (retract ?Borrar)
  (assert (UltimoEscrito ?Hecho ?v1))
  (printout mydata ?v1 " " ?n crlf)
)

;; Se cierra el archivo en el que se estaba escribiendo
(defrule CerrarEscritura
  (declare (salience -40))

  =>
  (close mydata)
)

;; Se elimina el hecho que indica el valor del último que se ha escrito
(defrule BorrarUltimoEscrito
  (declare (salience -30))
  ?Borrar1 <- (FicheroAbierto)
  ?H <- (T ?v1 ?n)
  ?Borrar2 <- (UltimoEscrito ?H ?v1)

  (not (T ?v2 & :(> ?v2 ?v1) ?n1))

  =>
  (retract ?Borrar1)
  (retract ?Borrar2)
)
