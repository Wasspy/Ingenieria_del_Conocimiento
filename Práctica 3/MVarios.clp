;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Laura Rabadán Ortega 79088745W                                             ;;
;;                                                                            ;;
;; Nombre Fichero: MVarios.clp                                                ;;
;; Contenido Fichero:                                                         ;;
;;		-> Temperatura:                                                       ;;
;;			- Nivel poco preocupante.                                         ;;
;;			- Nivel que requiere de control.                                  ;;
;;			- Nivel de peligro.                                               ;;
;; 	    -> Agua:                                                              ;;
;;          - Peligro leve.                                                   ;;
;;			- Peligro alto.                                                   ;;
;;      -> Vibración:                                                         ;;
;;          - Perro solo en la cocina                                         ;;
;;                                                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Temperatura
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Temperatura un poco alta. 
(defrule temperatura_alta_leve
    (activa varios)
    (ubicacion persona exterior)
    (ultimo_registro temperatura ?hab ?t)
    (valor_registrado ?t temperatura ?hab ?valor)

    (test (> ?valor 20))
    (test (<= ?valor 25))

    =>
    (printout t crlf " AVISO: La temperatura de la casa es un poco alta (" ?valor "ºC)" crlf)
)

;; Temperatura bastante alta.
(defrule temperatura_alta_fuerte
    (activa varios)
    (ubicacion persona exterior)
    (ultimo_registro temperatura ?hab ?t)
    (valor_registrado ?t temperatura ?hab ?valor)

    (test (> ?valor 25))
    (test (<= ?valor 30))

    =>
    (printout t crlf " ALERTA: La temperatura de la casa es alta (" ?valor "ºC)" crlf)
)

;; Temperatura peligrosamente alta. 
(defrule temperatura_alta_peligrosa
    (activa varios)
    (ubicacion persona exterior)
    (ultimo_registro temperatura ?hab ?t)
    (valor_registrado ?t temperatura ?hab ?valor)

    (test 
        (> ?valor 30)
    )

    =>
    (printout t crlf " PELIGRO: La temperatura de la casa es peligrosamente alta (" ?valor "ºC)" crlf)
)

;; Temperatura un poco baja
(defrule temperatura_baja_leve
    (activa varios)
    (ubicacion persona exterior)
    (ultimo_registro temperatura ?hab ?t)
    (valor_registrado ?t temperatura ?hab ?valor)

    (test (< ?valor 5))
    (test (>= ?valor -3))

    =>
    (printout t crlf " AVISO: La temperatura de la casa es un poco baja (" ?valor "ºC)" crlf)
)

;; Temperatura bastante baja
(defrule temperatura_baja_fuerte
    (activa varios)
    (ubicacion persona exterior)
    (ultimo_registro temperatura ?hab ?t)
    (valor_registrado ?t temperatura ?hab ?valor)

    (test (< ?valor -3))
    (test (>= ?valor -6))

    =>
    (printout t crlf " ALERTA: La temperatura de la casa es baja (" ?valor "ºC)" crlf)
)

;; Temperatura peligrosamente baja
(defrule temperatura_baja_peligrosa
    (activa varios)
    (ubicacion persona exterior)
    (ultimo_registro temperatura ?hab ?t)
    (valor_registrado ?t temperatura ?hab ?valor)

    (test 
        (< ?valor -6) 
    )

    =>
    (printout t crlf " PELIGRO: La temperatura de la casa es muy baja (" ?valor "ºC)" crlf)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Agua
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Hay poca agua pero no hay peligro por temperaturas
(defrule agua_leve
    ?Borrar <- (activa varios)
    (ultimo_registro agua ?hab ?t)
	(ultima_desactivacion agua ?hab ?t)
    
    (ultimo_registro temperatura ?hab1 ?t1)
    (valor_registrado ?t1 temperatura ?hab1 ?valor)
    
    (hora ?h ?m ?s)

    (test 
        (< ?valor 25)
    )

    => 
    (retract ?Borrar)
    (printout t crlf " AVISO: Cuenco de agua vacio (" ?h ":" ?m ")" crlf)
)

;; Hay poca agua y hay temperaturas altas
(defrule agua_necesaria_temperatura
    (activa varios)
    (ultimo_registro agua ?hab ?t)
	(ultima_desactivacion agua ?hab ?t)
    
    (ultimo_registro temperatura ?hab1 ?t1)
    (valor_registrado ?t1 temperatura ?hab1 ?valor)
    
    (hora ?h ?m ?s)

    (test 
        (>= ?valor 25)
    )

    => 
    (printout t crlf " ALERTA: Cuenco de agua vacio (" ?h ":" ?m ")" crlf)
)

;; El cuenco lleva una hora vacío
(defrule agua_necesaria_tiempo
    (activa varios)
    (ultimo_registro agua ?hab ?t)
	(ultima_desactivacion agua ?hab ?t)
    
    (hora ?h ?m ?s)

    (test 
        (< (- (+ (+ (* ?h 3600) (* ?m 60) ) ?s) ?t) 3600)       ;; Ha pasado 1 hora el cuenco vacío
    )

    => 
    (printout t crlf " ALERTA: Cuenco de agua vacio por más de una hora (" ?h ":" ?m ")" crlf)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Vibración
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; El perro está en la despensa y no hay nadie más en la cocina
(defrule perro_cocina
    (activacion varios)
    (ubicacion perro cocina)
    (not (ubicacion persona cocina))
    (ultimo_registro vibracion ?hab ?t)
    
    (hora ?h ?m ?s)

    (test 
        (< (- (+ (+ (* ?h 3600) (* ?m 60) ) ?s) ?t) 15)
    )

    =>
    (printout t crlf " AVISO: El perro está en la despensa (" ?h ":" ?m ")" crlf)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Limpiar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Si la temperatura y el agua están correctas, se desactiva el módulo
(defrule eliminar_activa
    ?Borrar <- (activacion varios)
    
    (ultimo_registro agua ?hab ?t)
	(ultima_activacion agua ?hab ?t)

    (ultimo_registro temperatura ?hab1 ?t1)
    (valor_registrado ?t1 temperatura ?hab1 ?valor)

    (test (> ?valor 5))
    (test (< ?valor 20))

    =>
    (retract ?Borrar)
)
