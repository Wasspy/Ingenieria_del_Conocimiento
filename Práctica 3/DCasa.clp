;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Laura Rabadán Ortega                                                       ;;
;;                                                                            ;;
;; Nombre Fichero: DCasa.clp                                                  ;;
;; Contenido Fichero:                                                         ;;
;;		-> Representación de la casa:                                           ;;
;;			- Las diferentes habitaciones de la casa.                             ;;
;;			- Las habitaciones que tienen ventanas.                               ;;
;;			- Las puertas entre dos habitaciones.                                 ;;
;; 			- Los pasos sin puerta entre dos habitaciones.                        ;;
;;		-> Sensores de la casa:                                                 ;;
;;			- Sensores de movimiento.                                             ;;
;;			- Sensores magnéticos.                                                ;;
;;			- Sensores de luminosidad.                                            ;;
;; 			- Sensores de humedad.                                                ;;
;;			- Sensores de temperatura.                                            ;;
;;			- Sensores de agua.                                                   ;;
;;			- Detector de vibración.                                              ;;
;; 			- Enchufes inteligentes.                                              ;;
;;                                                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Representación de la casa 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Habitaciones de la casa. 
(deffacts habitaciones
	(habitacion entrada)
	(habitacion comedor)
	(habitacion salon)
	(habitacion cocina)
	(habitacion lavadora)
	(habitacion baniococina)
	(habitacion pasillo)
	(habitacion banio)
	(habitacion dormitorioinvitados)
	(habitacion patiointerior)
	(habitacion dormitorioninios)
	(habitacion despacho)
	(habitacion vestidor)
	(habitacion dormitorio)
	(habitacion baniodormitorio)
	(habitacion jardin)
	(habitacion garaje)
)

;; Puertas entre dos habitaciones. 
(deffacts Puertas
	(puerta entrada    jardin)
	(puerta entrada    cocina)
	(puerta cocina     baniococina)
	(puerta entrada    pasillo)
	(puerta pasillo    banio)
	(puerta pasillo    dormitorioinvitados)
	(puerta pasillo    patiointerior)
	(puerta pasillo    dormitorioninios)
	(puerta pasillo    despacho)
	(puerta pasillo    dormitorio)
	(puerta dormitorio vestidor)
	(puerta dormitorio baniodormitorio)
	(puerta garaje     jardin)
)

;; Pasos sin puertas entre dos habitaciones. 
(deffacts Pasos
	(paso entrada comedor)
	(paso comedor salon)
	(paso cocina  lavadora)
)

;; Habitaciones con ventanas. 
(deffacts Ventanas
	(ventana comedor)
	(ventana cocina)
	(ventana despacho)
	(ventana dormitorio)
	(ventana dormitorioinvitados)
	(ventana dormitorioninios)
	(ventana pasillo)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Sensores de la casa
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Sensores de movimiento.
(deffacts SensoresMovimiento
	(dispositivo movimiento entrada)
	(dispositivo movimiento comedor)
	(dispositivo movimiento salon)
	(dispositivo movimiento cocina)
	(dispositivo movimiento lavadora)
	(dispositivo movimiento baniococina)
	(dispositivo movimiento pasillo)
	(dispositivo movimiento banio)
	(dispositivo movimiento dormitorioinvitados)
	(dispositivo movimiento patiointerior)
	(dispositivo movimiento dormitorioninios)
	(dispositivo movimiento despacho)
	(dispositivo movimiento vestidor)
	(dispositivo movimiento dormitorio)
	(dispositivo movimiento baniodormitorio)
	(dispositivo movimiento garaje)
)

;; Sensores magnéticos.
;; Se asume que, si hay un sensor magnetico en una habitación en la que hay varias
;; puertas, hay un sensor mágnetico en todas las puertas con habitaciones accesibles
;; desde otra habitación distinta. Es decir, si se pone un sensor en la puerta de un
;; dormitorio que cuenta con baño propio, el sensor estará en la puerta con la habitación
;; desde la que se puede acceder, ya que se supone que para poder entrar desde el baño
;; se tenía que estar ya en la habitación.  
(deffacts SensoresMagneticos
    (dispositivo magnetico entrada)
	(dispositivo magnetico cocina)
	(dispositivo magnetico despacho)
)

;; Sensores de humedad
(deffacts SensoresHumedad
    (dispositivo humedad pasillo)
)

;; Sensores de luminosidad
(deffacts SensoresLuminosidad
    (dispositivo luminosidad salon)
)

;; Sensores de temperatura.
(deffacts SensoresTemperatura
    (dispositivo temperatura salon)
)

;; Sensores de agua.
;; El sensor de agua está dentro del bebedero del perro, pero 
;; se le indica la habitación en la que se encuentra el bebedero.
;; Se supone que el bebedero no se mueve.
(deffacts SensoresAgua
    (dispositivo agua patiointerior)
)

;; Detector de vibración.
;; El sensor está en la despensa, pero se le indica la habitación 
;; en la que se encuentra la despensa, ya que se supone que no se
;; va a mover 
(deffacts SensoresVibracion
    (dispositivo vibracion cocina)
)

;; Enchufes inteligentes.
(deffacts EnchufeInteligente
    (dispositivo enchufe salon)
)
