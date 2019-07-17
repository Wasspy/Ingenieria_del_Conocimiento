;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Laura Rabadán Ortega                                                       ;;
;;                                                                            ;;
;; Nombre Fichero: MLuminosidad.clp                                           ;;
;; Contenido Fichero:                                                         ;;
;;		-> Controlar el enchufe del salón para encender o apagar una lámpara:   ;;
;;			- Si el perro no está solo.                                           ;;
;;			- Si el perro está solo y hay poca luz.                               ;;
;;			- Si el perro está solo y hay mucha luz.                              ;;
;; 			- Ejecutar las acciones de concectar/desconectar el enchufe.          ;;
;;                                                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Si el perro no está solo, no se hace nada y el enchufe está conectado, se 
;; desconecta 
(defrule no_perro_solo
    (activa luminosidad)
    (not (ubicacion persona exterior))
    
    (ultimo_registro enchufe ?hab ?t1)
    (valor_registrado ?t1 enchufe ?hab conectado)

    (hora ?h ?m ?s)

    =>
    (printout t crlf " ACCION: Se desconecta el enchufe del " ?hab " a las " ?h ":" ?m crlf)
    (assert (accion enchufe ?hab desconectado))
)

;; Si el perro está solo y hay poca luz, se conecta el enchufe
(defrule poca_luz 
    (activa luminosidad)
    (ubicacion persona exterior)
    (ultimo_registro enchufe ?hab ?t1)
    (valor_registrado ?t1 enchufe ?hab desconectado)

    (ultimo_registro luminosidad ?hab ?t2)
	(valor_registrado ?t2 luminosidad ?hab ?valor)

    (hora ?h ?m ?s)
	
	(test 
		(< ?valor 200)
	)

    =>
    (printout t crlf " ACCION: Se conecta el enchufe del " ?hab " a las " ?h ":" ?m crlf)
    (assert (accion enchufe ?hab conectado))
)

;; Si el perro está solo y hay mucha luz , se desconecta el enchufe
(defrule mucha_luz 
    (activa luminosidad)
    (ubicacion persona exterior)
    (ultimo_registro enchufe ?hab ?t1)
    (valor_registrado ?t1 enchufe ?hab conectado)

    (ultimo_registro luminosidad ?hab ?t2)
	(valor_registrado ?t2 luminosidad ?hab ?valor)

    (hora ?h ?m ?s)
	
	(test 
		(> ?valor 400)
	)

    =>
    (printout t crlf " ACCION: Se desconecta el enchufe del " ?hab " a las " ?h ":" ?m crlf)
    (assert (accion enchufe ?hab desconectado))
)

;; Si se tiene la acción de conectar el enchufe, se conecta
(defrule conectar_enchufe
    ?Borrar1 <- (activa luminosidad)
    ?Borrar2 <- (accion enchufe ?hab conectado)

    (ultimo_registro luminosidad ?hab ?t)
	(valor_registrado ?t luminosidad ?hab ?valor)
    
    =>
    (retract ?Borrar1 ?Borrar2)
    (assert 
        (valor enchufe ?hab conectado)
        (valor luminosidad ?hab (+ ?valor 200))
        (luz_encendida ?hab 200)
    )
)

;; Si se tiene la acción de desconectar el enchufe, se desconecta
(defrule desconectar_enchufe
    ?Borrar1 <- (activa luminosidad)
    ?Borrar2 <- (accion enchufe ?hab desconectado)
    ?Borrar3 <- (luz_encendida ?hab ?lux)

    (ultimo_registro luminosidad ?hab ?t)
	(valor_registrado ?t luminosidad ?hab ?valor)
    
    =>
    (retract ?Borrar1 ?Borrar2 ?Borrar3)
    (assert 
        (valor enchufe ?hab desconectado)
        (valor luminosidad ?hab (- ?valor ?lux))
    )
)

