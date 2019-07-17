;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Laura Rabadán Ortega 79088745W                                             ;;
;;                                                                            ;;
;; Nombre Fichero: MMovimiento.clp                                            ;;
;; Contenido Fichero:                                                         ;;
;;		-> Representación de la casa:                                         ;;
;;			- Las diferentes habitaciones de la casa.                         ;;
;;			- Las habitaciones que tienen ventanas.                           ;;
;;			- Las puertas entre dos habitaciones.                             ;;
;; 			- Los pasos sin puerta entre dos habitaciones.                    ;;
;;                                                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Módulo para controlar el movimiento entre habitaciones

;; Si se detecta movimiento, se cambia el estado de la habitación a activa.
(defrule habitacion_activa
    ?Borrar0 <- (activa movimiento)
	?Borrar1 <- (estado ?hab inactiva ?)
	?Borrar2 <- (personas ?hab 0)
	
	(ultimo_registro movimiento ?hab ?t)
	(valor_registrado ?t movimiento ?hab on)

	(hora ?h ?m ?s)
	
	=>
	(assert 
        ;;(estado ?hab activa (totalsegundos ?*hora* ?*minutos* ?*segundos*))
		(estado ?hab activa (+ (* ?h 3600) (+ (* ?m 60) ?s)))
        (personas ?hab 1)
		(activacion ?hab)
		(activa ubicacion)
    )
	
    (retract ?Borrar0 ?Borrar1 ?Borrar2)
)

;; Si una habitación está activa activa y no se detecta movimiento, se cambia a 
;; parece_inactiva
(defrule habitacion_parece_inactiva
    (activa movimiento)
	?Borrar <- (estado ?hab activa ?)
	
	(ultimo_registro movimiento ?hab ?t)
	(valor_registrado ?t movimiento ?hab off)

	(hora ?h ?m ?s)

	=>
	(assert 
        ;;(estado ?hab parece_inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
		(estado ?hab parece_inactiva (+ (* ?h 3600) (+ (* ?m 60) ?s)))
    )

	(retract ?Borrar)
)

;; Si una habitación está en parece_inactiva por más de 10 segundos, se cambia
;; el estado a inactiva.  
(defrule habitacion_inactiva
    ?Borrar1 <- (activa movimiento)
	(hora ?h ?m ?s)

	?Borrar2 <- (estado ?hab parece_inactiva ?t1 & :(> (- (+ (* ?h 3600) (+ (* ?m 60) ?s)) ?t1) 10))
	;;?Borrar2 <- (estado ?hab parece_inactiva ?t1 & :(> (- (totalsegundos ?*hora* ?*minutos* ?*segundos*) ?t1) 10))
	
	=>
	(assert 
        ;;(estado ?hab inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
		(estado ?hab inactiva (+ (* ?h 3600) (+ (* ?m 60) ?s)))
		(desactivacion ?hab)
		(activa ubicacion)
    )
	
    (retract ?Borrar1 ?Borrar2)
)

;; Si solo hay un posible paso desde una habitación parece_inactiva a otra activa 
;; (de hace menos de 3 segundos), se determina que se produjo un paso desde esa
;; habitación (activación de una habitación).
(defrule paso_habitacion_una_persona
    (activa movimiento)
	?Borrar1 <- (personas ?hab1 ?n1)
	?Borrar2 <- (personas ?hab2 ?n2)
	
	(hora ?h ?m ?s)

	;;?Borrar3 <- (posible_paso ?hab1 ?hab2 ?t1 & :(< (- (totalsegundos ?*hora* ?*minutos* ?*segundos*) ?t1) 3))
	?Borrar3 <- (posible_paso ?hab1 ?hab2 ?t1 & :(< (- (+ (* ?h 3600) (+ (* ?m 60) ?s)) ?t1) 3))

	(estado ?hab2 activa ?t2 & :(<= (- ?t2 ?t1) 10))	
	
	(not (posible_paso ?hab ?t3 & :(< (- ?t3 ?t1) 3)))
	
	=> 
	(assert 
        (personas ?hab1 (- ?n1 1))
    )

	(retract ?Borrar1 ?Borrar2 ?Borrar3) 
)

;; Si solo hay un posible paso desde una habitación parece_inactiva a otra activa 
;; (de hace menos de 3 segundos), se determina que se produjo un paso desde esa
;; habitación (la habitación ya estaba activada). 
(defrule paso_habitacion_varias_personas
    (activa movimiento)
	?Borrar1 <- (personas ?hab1 ?n1)
	?Borrar2 <- (personas ?hab2 ?n2)

	(hora ?h ?m ?s)

	;;?Borrar3 <- (posible_paso ?hab1 ?hab2 ?t1 & :(< (- (totalsegundos ?*hora* ?*minutos* ?*segundos*) ?t1) 3))
	?Borrar3 <- (posible_paso ?hab1 ?hab2 ?t1 & :(< (- (+ (* ?h 3600) (+ (* ?m 60) ?s)) ?t1) 3))

	(estado ?hab2 activa ?t2 & :(> (- ?t2 ?t1) 10))	
	
	(not (posible_paso ?hab ?t3 & :(< (- ?t3 ?t1) 3)))
	
	=> 
	(assert 
        (personas ?hab1 (- ?n1 1))
        (personas ?hab2 (+ ?n2 1))
    )
	
    (retract ?Borrar1 ?Borrar2 ?Borrar3)
)

;; Si no quedan personas en la habitación, su estado es parece_inactiva y han
;; pasado menos de 3 segundos en ese estado, se pasa el estado de la habitación 
;; a inactiva. 
(defrule habitacion_cero_personas
    ?Borrar0 <- (activa movimiento)

	(hora ?h ?m ?s)

	;;?Borrar1 <- (estado ?hab1 parece_inactiva ?t1 & :(> (- (totalsegundos ?*hora* ?*minutos* ?*segundos*) ?t1) 3))
	?Borrar1 <- (estado ?hab1 parece_inactiva ?t1 & :(> (- (+ (* ?h 3600) (+ (* ?m 60) ?s)) ?t1) 3))

	?Borrar2 <- (posible_pasar ?hab1 ?h2 ?t2)
	(personas ?hab1 0)
	?Borrar3 <- (personas ?hab2 ?n)	
	
	=>
	(assert 
        ;; (estado ?hab1 inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
		(estado ?hab1 inactiva (+ (* ?h 3600) (+ (* ?m 60) ?s)))
	    (personas ?hab2 (+ ?n 1))
		(desactivacion ?hab1)
		(activa ubicacion)
    )

	(retract ?Borrar0 ?Borrar1 ?Borrar2 ?Borrar3)
)

;; Si pudo haber un posible paso de varias habitaciones, se deducen pasos hacia 
;; todas las habitaciones.
(defrule posible_paso_habitacion
    (activa movimiento)
	(estado ?hab1 parece_inactiva ?t1)
	(estado ?hab2 activa ?t2)
	
	(posible_pasar ?hab1|?hab2 ?hab1|?hab2)

	(hora ?h ?m ?s)
	
	=>
	(assert 
        ;;(posible_paso ?hab1 ?hab2 (totalsegundos ?*hora* ?*minutos* ?*segundos*))
		(posible_paso ?hab1 ?hab2 (+ (* ?h 3600) (+ (* ?m 60) ?s)))
    )
)
 
;; Si pasa más de 3 segundos de un posible_paso, no se afirma.
(defrule no_posible_paso
    (activa movimiento)
	(hora ?h ?m ?s)

	;;?Borrar <- (posible_paso ?hab1 ?hab2 ?t & :(> (- (totalsegundos ?*hora* ?*minutos* ?*segundos*) ?t) 3))
	?Borrar <- (posible_paso ?hab1 ?hab2 ?t & :(> (- (+ (* ?h 3600) (+ (* ?m 60) ?s)) ?t) 3))

	=>
	(retract ?Borrar)
)

;; Si está en parece_inactiva y pasan 3 segundos, y no hay ningun posible paso 
;; ni es salida a la calle, se activa.
(defrule no_parece_inactiva
    ?Borrar1 <- (activa movimiento)
	
	(hora ?h ?m ?s)

	;;?Borrar2 <- (estado ?hab1 & ~entrada parece_inactiva ?t1 & :(> (- (totalsegundos ?*hora* ?*minutos* ?*segundos*) ?t1) 3))
	?Borrar2 <- (estado ?hab1 & ~entrada parece_inactiva ?t1 & :(> (- (+ (* ?h 3600) (+ (* ?m 60) ?s)) ?t1) 3))

	(not (posible_paso ?hab1 ?h ?t))
	
	=> 
	(assert 
        ;;(estado ?hab1 activa (totalsegundos ?*hora* ?*minutos* ?*segundos*))
		(estado ?hab1 activa (+ (* ?h 3600) (+ (* ?m 60) ?s)))
		(activacion ?hab1)
		(activa ubicacion)
    )

	(retract ?Borrar1 ?Borrar2)
)
