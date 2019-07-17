;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Laura Rabadán Ortega                                                       ;;
;;                                                                            ;;
;; Nombre Fichero: MLecturaSensores.clp                                       ;;
;; Contenido Fichero:                                                         ;;
;;		-> Lectura de los valores de los sensores:                              ;;
;;			- Registrar el valor y la marca de tiempo de un sensor.               ;;
;;			- Actualizar el último registro de un sensor.                         ;;
;;	    -> Interpretación de los valores del sensor:                          ;;
;; 			- Cambio de estado de sensor de movimiento.                           ;;
;;		-> Llamada a los módulos:											                          ;;
;;			- Activar los módulos correspondientes para tratar los datos.	        ;;
;;                                                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Lectura de los valores de los sensores
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Registar el valor y la marca de tiempo de un sensor. 
(defrule registrar_valor
	?Borrar <- (valor ?tipo ?hab ?valor)           ;; Valor enviado por el sensor
	(hora ?h ?m ?s)
	(hora_inicio ?t)

    ;; Se comprueba que existe ese sensor en esa habitación.
	(dispositivo ?tipo ?hab)
	
	=>
	;; Para guardar el tiempo y que sea igual en los dos casos
	;;(bind ?tiempo (totalsegundos ?*hora* ?*minutos* ?*segundos*))	
	
	(retract ?Borrar)
	(assert                                                 
        (valor_registrado (+ (+ (+ (* ?h 3600) (* ?m 60)) ?s) ?t) ?tipo ?hab ?valor)
        (ultimo_registro ?tipo ?hab (+ (+ (+ (* ?h 3600) (* ?m 60)) ?s) ?t))
    )
)

;; Actualizar el último registro de un sensor.  
(defrule limpiar_registros 

	?Borrar <- (ultimo_registro ?tipo ?hab ?t1)      ;; Registro anterior
	(ultimo_registro ?tipo ?hab ?t2 & ~?t1)         ;; Nuevo registro
	
	(test               ;; Se comprueba que se va a eliminar el 
        (< ?t1 ?t2)     ;; ultimo_registro correcto (el más antiguo)
    )
	
	=>
	(retract ?Borrar)
)

;; Interpretación de los valores del sensor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Cambio de estado de los sensores
;; Sensor magnético
;; OFF -> Abierta ; ON -> Cerrada
;; Sensor de agua
;; OFF -> No hay agua ; ON -> Hay agua

;; Paso de OFF a ON.
(defrule activacion_sensor
	(declare (salience 10))      
	
	(hora ?h ?m ?s)
	(hora_inicio ?t)

	(valor ?tipo ?hab on)                    
	(ultimo_registro ?tipo ?hab ?t1)       ;; Se comprueba que el estado anterior
	(valor_registrado ?t1 ?tipo ?hab off)  ;; el estado fuera OFF

	=>
	(assert 
        (ultima_activacion ?tipo ?hab (+ (+ (+ (* ?h 3600) (* ?m 60)) ?s) ?t))
    )
)

;; Paso de ON a OFF
(defrule desactivacion_sensor
	(declare (salience 10))

	(hora ?h ?m ?s)
	(hora_inicio ?t)
	
	(valor ?tipo ?hab off)
	(ultimo_registro ?tipo ?hab ?t1)
	(valor_registrado ?t1 ?tipo ?hab on)
	=>
	(assert 
		(ultima_desactivacion ?tipo ?hab (+ (+ (+ (* ?h 3600) (* ?m 60)) ?s) ?t))
	)
)

;; Se eliminan los registros desactualizados de 'ultima_activacion' de los 
;; sensores de una habitación.
(defrule eliminar_activacion
	(ultima_activacion ?dispositivo ?hab ?t1)
	(ultima_activacion ?dispositivo ?hab ?t2 & ~?t1)
	
	(test (< ?t1 ?t2))
	
	?Borrar <- (ultima_activacion ?dispositivo ?hab ?t1)
	=>
	(retract ?Borrar)
)

;; Se eliminan los registros desactualizados de 'ultima_desactivacion' de los 
;; sensores de una habitación.
(defrule eliminar_desactivacion
	(ultima_desactivacion ?dispositivo ?hab ?t1)
	(ultima_desactivacion ?dispositivo ?hab ?t2 & ~?t1)
	
	(test (< ?t1 ?t2))
	
	?Borrar <- (ultima_desactivacion ?dispositivo ?hab ?t1)
	=>
	(retract ?Borrar)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Interpretación de los sensores
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Llamada al módulo inicial
(defrule llamada_inicial
	(declare (salience 1))
	(not (activa iniciar))
	(not (ubicacion perro ?$))
	(not (ubicacion persona ?$))
	
	=>
	(assert 
		(activa iniciar)
	)
)

;; Llamada al módulo de movimiento y de ubicación 
(defrule llamada_movimiento
	(not (activa movimiento))
	(ultimo_registro movimiento ?hab ?t)
	(ultima_activacion movimiento ?hab ?t)
	
	=>
	(assert
		(activa movimiento)
	)
)

;; Llamada al módulo magnético
(defrule llamada_magnetico
	(not (activa magnetico))
	(ultimo_registro magnetico ?hab ?t)
	(ultima_desactivacion magnetico ?hab ?t)
	
	=>
	(assert 
		(activa magnetico)
	)
)

;; Llamada al módulo de luminosidad
(defrule llamada_luminosidad_baja
	(not (activa luminosidad))
	(ultimo_registro luminosidad ?hab ?t)
	(valor_registrado ?t luminosidad ?hab ?valor)
	
	(test 
		(< ?valor 200)
	)

	=> 
	(assert 
		(activa luminosidad)
	)
)

(defrule llamada_luminosidad_alta
	(not (activa luminosidad))
	(ultimo_registro luminosidad ?hab ?t)
	(valor_registrado ?t luminosidad ?hab ?valor)
	
	(test 
		(> ?valor 400)
	)

	=> 
	(assert 
		(activa luminosidad)
	)
)

;; Llamada al módulo de humedad
(defrule llamada_humedad
	(not (activa humedad))
	(ultimo_registro humedad ?hab ?t)
	(valor_registrado ?t humedad ?hab ?valor)
	
	(test 
		(< ?valor 600)				;; A partir de 650 es ligeramente húmedo
	)

	=> 
	(assert 
		(activa humedad)
	)
)

;; Llamada al módulo de Varios
(defrule llamada_varios_agua
	(not (activa varios))
	(ultimo_registro agua ?hab ?t)
	(ultima_desactivacion agua ?hab ?t)
	
	=>
	(assert 
		(activa varios)
	)
)

;; Llamada al módulo de Varios
(defrule llamada_varios_vibracion
	(not (activa varios))
	(ultimo_registro vibracion ?hab ?t) 	;; Se ha detectado una vibración,
											;, inclinación o caída 
	=> 
	(assert 
		(activa varios)
	)
)

;; Llamada al módulo de Varios
(defrule llamada_varios_temperatura_alta
	(not (activa varios))
	(ultimo_registro temperatura ?hab ?t)
	(valor_registrado ?t temperatura ?hab ?valor)
	
	(test 
		(> ?valor 20)					;; Temperatura a partir de la cual empieza  a
	)									;; ser peligroso para los perros grandes
	
	=> 
	(assert 
		(activa varios)
	)
)

;; Llamada al módulo de Varios
(defrule llamada_varios_temperatura_baja
	(not (activa varios))
	(ultimo_registro temperatura ?hab ?t)
	(valor_registrado ?t temperatura ?hab ?valor)
	
	(test 
		(< ?valor 5)					;; Temperatura a partir de la cual empieza  a
	)									;; ser peligroso para los perros pequeños
	
	=> 
	(assert 
		(activa varios)
	)
)
