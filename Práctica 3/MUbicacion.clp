;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Laura Rabadán Ortega                                                       ;;
;;                                                                            ;;
;; Nombre Fichero: Mubicacion.clp                                             ;;
;; Contenido Fichero:                                                         ;;
;;		-> Actualizar la ubicacion:                                             ;;
;;			- Se estudian todos los posibles pasos.                               ;;
;;			- Se elige el paso más posible.                                       ;;
;;                                                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Si se desactiva la habitación en la que estaba el perro o el dueño y se activa
;; otra desde la que se puede pasar, se plantea un posible paso
(defrule posibles_ubicaciones
    (activa ubicacion)
    ?Borrar1 <- (ubicacion ?ind ?hab)

    ?Borrar2 <- (desactivacion ?hab)
    ?Borrar3 <- (activacion ?hab1 & ~?hab)

    (posible_pasar ?hab|?hab1 ?hab1|?hab)

    =>
    (retract ?Borrar1 ?Borrar2 ?Borrar3)
    (assert (posible_ubicacion ?ind ?hab1))
)

;; Si se tiene un único posible paso, se deduce el paso
(defrule una_posible_ubicacion
    (activa ubicacion)
    ?Borrar <- (posible_ubicacion ?ind ?hab)
    (not (posible_ubicacion ?ind ?hab1 & ~?hab))
    
    =>
    (retract ?Borrar)
    (assert (ubicacion ?ind ?hab))
)

;; Si hay dos posibles pasos y en uno está el otro, se deduce un
;; paso a la otra habitación
(defrule dos_posibles_ubicacion
    (activa ubicacion)
    ?Borrar1 <- (posible_ubicacion ?ind ?hab1)
    ?Borrar2 <- (posible_ubicacion ?ind ?hab21 & ~?hab1)
    
    (ubicacion ?ind1 & ~?ind ?hab1)
    
    (estado ?hab1 activa ?t1)
    (estado ?hab2 activa ?t2)

    => 
    (retract ?Borrar1 ?Borrar2)
    (assert (ubicacion ?ind ?hab2))
)

;; No se detecta ningun posible paso, por lo que l apersona o 
;; el perro deben seguir en la habitación
(defrule ninguna_posibilidad
    (activa ubicacion)
    (ubicacion ?ind ?hab)

    ?Borrar <- (desactivacion ?hab)
    (not (activacion ?hab1 & ~?hab))

    =>
    (retract ?Borrar)
)

;; Se desconecta el módulo
(defrule desactivar_modulo_ubicacion
    ?Borrar <- (activa ubicacion)
    (not (activacion ?hab1))
    (not (desactivacion ?hab2))
    (not (posible_ubicacion ?ind ?hab3))
    
    =>
    (retract ?Borrar)
)

