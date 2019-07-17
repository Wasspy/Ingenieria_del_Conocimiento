;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Laura Rabadán Ortega 79088745W                                             ;;
;;                                                                            ;;
;; Nombre Fichero: MHumedad.clp                                               ;;
;; Contenido Fichero:                                                         ;;
;;		-> Detectar posible pis en el pasillo:                                ;;
;;			- Comprobar si fue el perro (y mostrar mensaje).                  ;;
;;			- Descartar que fue el perro.                                     ;;
;;			- Asumir error del sensor.                                        ;;
;;                                                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Si el perro está en el pasillo y no está el dueño y se detecta humedad, se manda un aviso
(defrule perro_solo_pasillo
    (activa humedad)
    (ubicacion perro pasillo)
    (not (ubicacion persona pasillo))

    (hora ?h ?m ?s)
    
    =>
    (printout t crlf " AVISO: El perro se ha orinado en el pasillo a las " ?h ":" ?m crlf)
    (assert (mensaje_pis))
)

;; Si está el dueño solo en el pasillo, no se hace nada
(defrule persona_sola_pasillo
    (activa humedad)
    (ubicacion persona pasillo)
    (not (ubicacion perro pasillo))

    (hora ?h ?m ?s)
    
    =>
    (assert (mensaje_pis))
)

;; Si está el dueño en el pasillo con el perro, no se hace nada
(defrule todos_pasillo
    (activa humedad)
    (ubicacion perro pasillo)
    (ubicacion persona pasillo)
    
    =>
    (assert (mensaje_pis))
)

;; Si no hay nadie en el pasillo, se comprueba las habitaciones 
;; activas para saber quien pudo haber sido
(defrule nadie_pasillo
    (activa humedad)
    (not (ubicacion persona pasillo))
    (not (ubicacion perro pasillo))

    (estado ?hab activa ?t)
    (posible pasar ?hab|pasillo pasillo|?hab)

    (hora ?h ?m ?s)
    
    =>
    (assert 
        (posible_pis ?hab (+ (* ?h 3600) (+ (* ?m 60) ?s)))
    )
)

;; Si solo está el perro en la casa, se deduce que fue el perro
(defrule solo_perro
    (activa humedad)
    ?Borrar <- (posible_pis ?hab ?t)
    (not (posible_pis ?hab1 & ~?hab ?t2))

    (ubicacion persona exterior)

    (hora ?h ?m ?s)

    => 
    (retract ?Borrar)
    (printout t crlf " AVISO: El perro se ha orinado en el pasillo a las " ?h ":" ?m crlf)
    (assert (mensaje_pis))
)

;; Si solo hay una habitación conectada activa y está el dueño, se
;; deduce que seguramente fuera el dueño
(defrule es_duenio
    (activa humedad)
    ?Borrar <- (posible_pis ?hab ?t)
    (not (posible_pis ?hab1 & ~?hab ?t2))

    (estado ?hab2 & ~?hab activa ?t1)
    (ubicacion persona ?hab)

    (hora ?h ?m ?s)
    
    (test 
        (> (- (+ (* ?h 3600) (+ (* ?m 60) ?s)) ?t1) 60)
    )

    => 
    (retract ?Borrar)
    (assert 
        (muy_posible_pis persona ?hab ?t)
    )
)

;; Si solo hay una habitación conectada activa y está el perro, se
;; deduce que seguramente fuera el perro
(defrule es_perro
    (activa humedad)
    ?Borrar <- (posible_pis ?hab ?t1)
    (not (posible_pis ?hab1 & ~?hab))

    (estado ?hab2 & ~?hab activa ?t)
    (ubicacion perro ?hab)

    (hora ?h ?m ?s)
    
    (test 
        (< (- (+ (* ?h 3600) (+ (* ?m 60) ?s)) ?t1) 30)
    )

    => 
    (retract ?Borrar)
    (assert 
        (muy_posible_pis perro ?hab ?t1)
    )
)

;; Si hay una habitación conectada pero lleva más
;; tiempo activa que la otra habitación activa, se
;; piensa que puede ser el de la otra habitación
(defrule no_es_duenio 
    (activa humedad)
    ?Borrar <- (muy_posible_pis persona ?hab ?t)
    
    (estado ?hab activa ?t2)
    (estado ?hab1 activa ?t1)
    (ubicacion perro ?hab1)

    (hora ?h ?m ?s)
    
    (test 
        (> ?t2 ?t1)
    )

    => 
    (retract ?Borrar)
    (assert 
        (muy_posible_pis perro ?hab1 ?t)
    )
)

;; Si hay una habitación conectada pero lleva más
;; tiempo activa que la otra habitación activa, se
;; deduce que fue el dueño
(defrule no_es_perro 
    (activa humedad)
    ?Borrar <- (muy_posible_pis perro ?hab ?t2)
    
    (estado ?hab activa ?t)
    (estado ?hab1 activa ?t1)
    (ubicacion persona ?hab1)

    (hora ?h ?m ?s)
    
    (test 
        (> ?t ?t1)
    )

    => 
    (retract ?Borrar)
)

;; Si tras 15s solo queda el perro como posibilidad,
;; deduce que fue el perro
(defrule solo_queda_perro
    (activa humedad)
    ?Borrar <- (muy_posible_pis perro ?hab ?t)
    (not (muy_posible_pis persona ?hab1))
    (not (posible_pis ?$))

    (hora ?h ?m ?s)

    (test 
        (> (- (+ (* ?h 3600) (+ (* ?m 60) ?s)) ?t) 15)
    )

    =>
    (retract ?Borrar)
    (printout t crlf " AVISO: El perro se ha orinado en el pasillo a las " ?h ":" ?m crlf)
    (assert (mensaje_pis))
)

;; Si hay dos habitaciones activas conectadas al pasillo y en la
;; que está el perro lleva menos tiempo activa, se deduce que fue 
;; el perro
(defrule mas_posible_perro
    (activa humedad)
    ?Borrar1 <- (posible_pis ?hab1 ?t1)
    ?Borrar2 <- (posible_pis ?hab2 ?t2)
    
    (estado ?hab1 activa ?t3)
    (estado ?hab2 activa ?t4)
    
    (ubicacion perro ?hab1)
    
    (hora ?h ?m ?s)
    
    (test 
        (> ?t3 ?t4)
    )
    
    =>
    (retract ?Borrar1 ?Borrar2)
    (printout t crlf " AVISO: El perro se ha orinado en el pasillo a las " ?h ":" ?m crlf)
    (assert (mensaje_pis))
)

;; Si hay dos habitaciones activas conectadas al pasillo y en la
;; que está el dueño lleva menos tiempo activa, se deduce que fue 
;; el dueño
(defrule mas_posible_persona
    (activa humedad)
    ?Borrar1 <- (posible_pis ?hab1 ?t1)
    ?Borrar2 <- (posible_pis ?hab2 ?t2)
    
    (estado ?hab1 activa ?t3)
    (estado ?hab2 activa ?t4)
    
    (ubicacion persona ?hab1)
    
    (test 
        (> ?t3 ?t4)
    )
    
    =>
    (retract ?Borrar1 ?Borrar2)
    (assert (mensaje_pis))
)

;; Si los dos están en la misma habitacion, se manda un mensaje de 
;; posibilidad, ya que no hay manera de descartar
(defrule indecidible
    (activa humedad)
    ?Borrar1 <- (posible_pis ?hab ?t1)
    ?Borrar2 <- (posible_pis ?hab ?t2)
    
    (ubicacion persona ?hab)
    (ubicacion perro ?hab)

    (hora ?h ?m ?s)

    => 
    (retract ?Borrar1 ?Borrar2)
    (printout t crlf " AVISO: El perro se ha orinado en el pasillo a las " ?h ":" ?m crlf)
    (assert (mensaje_pis))
)

;; Si tras 10 segundos no se ha podido deducir nada
;; del responsable, no se deduce nada
(defrule error_sensor 
    (activa humedad)
    ?Borrar <- (posible_pis ?hab ?t)

    (hora ?h ?m ?s)

    (test 
        (> (- (+ (* ?h 3600) (+ (* ?m 60) ?s)) ?t) 10)
    )

    => 
    (retract ?Borrar)
)

;; Hasta que no se seque, estará mandando avisos, por lo que no se desactiva el módulo hasta
;; que el sensor reciba que ya no hay líquido. 
(defrule desactivar_modulo
    ?Borrar1 <- (activa humedad)
    ?Borrar2 <- (mensaje_pis)

    (ultimo_registro humedad ?hab ?t)
	(valor_registrado ?t humedad ?hab ?valor)

    (test 
        (>= ?valor 500)
    )
    
    =>
    (retract ?Borrar1 ?Borrar2) 
)