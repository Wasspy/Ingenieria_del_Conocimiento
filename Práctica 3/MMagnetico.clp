;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Laura Rabadán Ortega 79088745W                                             ;;
;;                                                                            ;;
;; Nombre Fichero: MMagnetico.clp                                             ;;
;; Contenido Fichero:                                                         ;;
;;		-> Detectar entradas a zonas restringidas:                            ;;
;;			- El perro entra.                                                 ;;
;;			- El dueño entra.                                                 ;;
;;                                                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; El perro está solo en la casa, por lo que solo puede ser el el que entra
(defrule perro_solo_entra
    (activa magnetico)
    (ultimo_registro magnetico ?hab & ~entrada ?t)
    (ultima_desactivacion magnetico ?hab ?t)
    (ubicacion persona exterior)
    ?Borrar <- (ubicacion perro ?hab1)
    
    (hora ?h ?m ?s)

    =>
    (retract ?Borrar)
    (printout t crlf " AVISO: El perro entro en en una zona restringida (" ?hab " - " ?h ":" ?m ")" crlf)
    (assert (ubicacion perro ?hab))
)

;; El perro y el dueño están en la casa, pero solo el perro estaba en una habitación
;; desde la que se podía acceder a la zona restringida
(defrule perro_entra   
    (activa magnetico)
    (ultimo_registro magnetico ?hab & ~entrada ?t)
    (ultima_desactivacion magnetico ?hab ?t)
    
    (not (ubicacion persona exterior))
    (ubicacion persona ?hab1)
    ?Borrar <- (ubicacion perro ?hab2)

    (not (posible_pasar ?hab|?hab1 ?hab1|?hab))
    (posible_pasar ?hab|?hab2 ?hab2|?hab)

    (hora ?h ?m ?s)

    =>
    (retract ?Borrar)
    (printout t crlf " AVISO: El perro entro en en una zona restringida (" ?hab2 " - " ?h ":" ?m ")" crlf)
    (assert (ubicacion perro ?hab))
)

;; El perro y el dueño están en la casa, pero solo el dueño estaba en una habitación
;; desde la que se podía acceder a la zona restringida
(defrule persona_entra   
    (activa magnetico)
    (ultimo_registro magnetico ?hab & ~entrada ?t)
    (ultima_desactivacion magnetico ?hab ?t)
    
    (not (ubicacion persona exterior))
    ?Borrar <- (ubicacion persona ?hab1)
    (ubicacion perro ?hab2)

    (posible_pasar ?hab|?hab1 ?hab1|?hab)
    (not (posible_pasar ?hab|?hab2 ?hab2|?hab))

    =>
    (retract ?Borrar)
    (assert (ubicacion persona ?hab))
)

;; Tanto el perro como la persona pueden acceder a la zona restringida
(defrule perro_persona_puede_entrar
    (activa magnetico)
    (ultimo_registro magnetico ?hab & ~entrada ?t)
    (ultima_desactivacion magnetico ?hab ?t)
    
    (not (ubicacion persona exterior))
    (ubicacion persona ?hab1)
    (ubicacion perro ?hab2)

    (posible_pasar ?hab|?hab1 ?hab1|?hab)
    (posible_pasar ?hab|?hab2 ?hab2|?hab)

    =>
    (assert 
        (posible_puerta perro ?hab2 ?hab)
        (posible_puerta persona ?hab1 ?hab)
    )
)

;; Se baja la probabilidad de que es el perro el que pasa
(defrule semi_descartar_perro
    (activa magnetico)
    ?Borrar <- (posible_puerta perro ?origen ?destino)
    
    (ultimo_registro magnetico ?origen ?t)
    (ultima_activacion magnetico ?origen ?t)
    
    => 
    (retract ?Borrar)
    (assert (poco_posible perro ?origen ?destino))
)

;; Se baja la probabilidad de que e el perro el que pasa
(defrule semi_descartar_persona
    (activa magnetico)
    ?Borrar <- (posible_puerta persona ?origen ?destino)
    
    (ultimo_registro movimiento ?origen ?t)
    (ultima_activacion ?origen ?t)
    
    => 
    (retract ?Borrar)
    (assert (poco_posible persona ?origen ?destino))
)

;; El perro y el dueño están en la misma habitación
(defrule misma_habitacion
    ?Borrar0 <- (activa magnetico)
    ?Borrar1 <- (posible_puerta perro ?origen ?destino)
    ?Borrar2 <- (posible_puerta persona ?origen ?destino)
    ?Borrar3 <- (ubicacion persona ?origen)
    
    =>
    (retract ?Borrar0 ?Borrar1 ?Borrar2 ?Borrar3)
    (assert (ubicacion persona ?destino))
)

;; Se descarta al perro
(defrule descartar_perro
    ?Borrar1 <- (activa magnetico)
    ?Borrar2 <- (poco_posible perro ?origen ?destino)
    ?Borrar3 <- (ubicacion persona ?origen)
    
    (utlimo_registro magnetico ?destino ?t)
    (ultima_desactivacion magnetico ?destino ?t)
    
    =>
    (retract ?Borrar1 ?Borrar2 ?Borrar3)
    (assert (ubicacion persona ?destino))
)

;; Se afirma que fue el perro
(defrule no_descartar_perro
    ?Borrar1 <- (activa magnetico)
    ?Borrar2 <- (posible_puerta perro ?origen ?destino)
    (not (posible_puerta persona ?$))
    
    (ubicacion perro ?origen)

    (hora ?h ?m ?s)

    =>
    (retract ?Borrar1 ?Borrar2)
    (printout t crlf " AVISO: El perro entro en en una zona restringida (" ?destino " - " ?h ":" ?m ")" crlf)
    (assert (ubicacion perro ?destino))
)

;; Se afirma que fue el dueño
(defrule no_descartar_persona
    ?Borrar1 <- (activa magnetico)
    ?Borrar2 <- (posible_puerta persona ?origen ?destino)
    (not (posible_puerta perro ?$))
    
    (ubicacion persona ?origen)

    =>
    (retract ?Borrar1 ?Borrar2)
    (assert (ubicacion persona ?destino))
)

;; Se afirma que fue el dueño
(defrule resuleto_persona
    ?Borrar1 <- (activa magnetico)
    ?Borrar2 <- (posible_puerta perro ?origen1 ?destino)
    ?Borrar3 <- (posible_puerta persona ?origen2 ?destino)
    
    (ubicacion persona ?destino)
    
    =>
    (retract ?Borrar1 ?Borrar2 ?Borrar3)
)

;; Se afirma que fue el perro
(defrule resuelto_perro_solo
    ?Borrar1 <- (activa magnetico)
    ?Borrar2 <- (posible_puerta perro ?origen1 ?destino)
    ?Borrar3 <- (posible_puerta persona ?origen2 ?destino)
    
    (ubicacion perro ?destino)
    (not (ubicacion persona ?destino))

    (hora ?h ?m ?s)
    
    =>
    (retract ?Borrar1 ?Borrar2 ?Borrar3)
    (printout t crlf " AVISO: El perro entro en en una zona restringida (" ?destino " - " ?h ":" ?m ")" crlf)
)

;; El dueño ha salido de la casa
(defrule persona_sale_casa
    ?Borrar1 <- (activa magnetico)
    
    (ultimo_registro magnetico entrada ?t)
    
    ?Borrar2 <- (ubicacion persona entrada)

    => 
    (retract ?Borrar1 ?Borrar2)
    (assert (ubicacion persona exterior))
)

;; El dueño entra en la casa
(defrule persona_entra_casa
    ?Borrar1 <- (activa magnetico)
    
    (ultimo_registro magnetico entrada ?t)
    
    ?Borrar2 <- (ubicacion persona exterior)

    => 
    (retract ?Borrar1 ?Borrar2)
    (assert (ubicacion persona entrada))
)