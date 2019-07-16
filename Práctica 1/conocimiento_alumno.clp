;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Laura Rabadán Ortega
;; 
;; Nombre Fichero: conocimiento_alumno.clp
;; Contenido Fichero: 
;;		-> Manejo inteligente de luces de una habitación:
;;			- Datos: 
;;				* Número de personas dentro de una habitación. 
;;			- Reglas:
;;				* encender_luz: se enciende la luz de una habitación activa. 
;;				* apagar_luz_inactiva: se apaga la luz de una habitación inactiva. 
;;				* apagar_luz_exceso: se apaga la luz cuando hay exceso de luminosidad. 
;;				* habitacion_activa: se cambia el estado de una habitación a
;;								     activa. 
;;				* habitacion_parece_inactiva: se cambia el estado de una habitación
;;											  a parece_inactiva. 
;;				* habitacion_inactiva: se cambia el estado de una habitación a 
;; 									   inactiva. 
;;				* paso_habitacion_una_persona: solo hay una persona en la nueva
;;											   habitación activa. 
;;				* paso_habitacion_varias_personas: hay más de una persona en la 
;;												   nueva habitación activa. 
;; 				* ajustar_personas:	se ajusta el mínimo de perosnas a 0. 
;;				* habitacion_cero_personas: si no quedan personas en la habitación,
;;											se pasa a inactiva.  
;;				* posible_paso_habitacion: se determina un posible paso de una 
;;										   habitación a otra. 
;;				* no_posible_paso: se elimina un posible paso de una habitación 
;;								   a otra. 
;;				* no_parece_inactiva: se cambia el estado de una habitación a 
;;									  activa. 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cargar los datos del conocimiento que se va a usar

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DATOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Declaración del número de personas dentro de una habitación. Inicialmente, no 
;; hay ninguna persona en ninguna habitación. 
(deffacts NumeroPersonas
	(personas entrada 0)
	(personas comedor 0)
	(personas salon 0)
	(personas salita 0) 
	(personas cocina 0)
	(personas lavadora 0)
	(personas baniococina 0)
	(personas pasillo 0)
	(personas banio 0)
	(personas dormitorioinvitados 0)
	(personas patiointerior 0)
	(personas dormitorioninios 0)
	(personas despacho 0)
	(personas vestidor 0)
	(personas dormitorio 0)
	(personas baniodormitorio 0)
	(personas jardin 0)
	(personas garaje 0)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; REGLAS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Si una habitación no está vacía y hay poca luz, se enciende la luz.  
(defrule encender_luz
	(Manejo_inteligente_luces ?h)
	(luz_minimo ?h ?v1)
	
	(estado ?h activa ?)
	
	(ultimo_registro luminosidad ?h ?t)
	(valor_registrado ?t luminosidad ? ?v2 & :(< ?v2 ?v1))

    (ultimo_registro estadoluz ?h ?t1)
	(valor_registrado ?t1 estadoluz ?h off)
	
	=>
	(assert (accion pulsador_luz ?h encender))
)

;; Si una habitación está vacía y la luz está encendida, se apaga la luz. 
(defrule apagar_luz_inactiva
	(Manejo_inteligente_luces ?h)
	(estado ?h inactiva ?)
	
	(ultimo_registro estadoluz ?h ?t)
	(valor_registrado ?t estadoluz ?h on)

	=>
	(assert (accion pulsador_luz ?h apagar))
)

;; Si la luz está encendida y hay mucha luminosidad, se apaga la luz.  
(defrule apagar_luz_exceso 
	(Manejo_inteligente_luces ?h)
	(luz_minimo ?h ?v1)
	
	(ultimo_registro luminosidad ?h ?t1)
	(valor_registrado ?t1 luminosidad ? ?v2 & :(> ?v2 (* ?v1 2)))
	
    (ultimo_registro estadoluz ?h ?t2)
	(valor_registrado ?t2 estadoluz ?h on)
	
	=>
	(assert (accion pulsador_luz ?h apagar))
)

;; Si se detecta movimiento, se cambia el estado de la habitación a activa.
(defrule habitacion_activa
	?Borrar1 <- (estado ?h inactiva ?)
	?Borrar2 <- (personas ?h 0)
	
	(ultimo_registro movimiento ?h ?t)
	(valor_registrado ?t movimiento ?h on)
	
	=>
	(assert (estado ?h activa (totalsegundos ?*hora* ?*minutos* ?*segundos*)))
	(assert (personas ?h 1))
	(retract ?Borrar1)
	(retract ?Borrar2)
)	
	
;; Si una habitación está activa activa y no se detecta movimiento, se cambia a 
;; parece_inactiva
(defrule habitacion_parece_inactiva
	?Borrar <- (estado ?h activa ?)
	
	(ultimo_registro movimiento ?h ?t)
	(valor_registrado ?t movimiento ?h off)
	
	=>
	(assert (estado ?h parece_inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*)))
	(retract ?Borrar)
)	

;; Si una habitación está en parece_inactiva por más de 10 segundos, se cambia
;; el estado a inactiva.  
(defrule habitacion_inactiva
	?Borrar <- (estado ?h parece_inactiva ?t1 & :(> (- (totalsegundos ?*hora* ?*minutos* ?*segundos*) ?t1) 10))
	
	=>
	(assert (estado ?h inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*)))
	(retract ?Borrar)
)	
 
;; Si solo hay un posible paso desde una habitación parece_inactiva a otra activa 
;; (de hace menos de 3 segundos), se determina que se produjo un paso desde esa
;; habitación (activación de una habitación).
(defrule paso_habitacion_una_persona
	?Borrar1 <- (personas ?h1 ?n1)
	?Borrar2 <- (personas ?h2 ?n2)
	?Borrar3 <- (posible_paso ?h1 ?h2 ?t1 & :(< (- (totalsegundos ?*hora* ?*minutos* ?*segundos*) ?t1) 3))
	(estado ?h2 activa ?t2 & :(<= (- ?t2 ?t1) 10))	
	
	(not (posible_paso ?h ?t3 & :(< (- ?t3 ?t1) 3)))
	
	=> 
	(assert (personas ?h1 (- ?n1 1)))
	(retract ?Borrar1)
	(retract ?Borrar2)
	(retract ?Borrar3) 
)

;; Si solo hay un posible paso desde una habitación parece_inactiva a otra activa 
;; (de hace menos de 3 segundos), se determina que se produjo un paso desde esa
;; habitación (la habitación ya estaba activada). 
(defrule paso_habitacion_varias_personas
	?Borrar1 <- (personas ?h1 ?n1)
	?Borrar2 <- (personas ?h2 ?n2)
	?Borrar3 <- (posible_paso ?h1 ?h2 ?t1 & :(< (- (totalsegundos ?*hora* ?*minutos* ?*segundos*) ?t1) 3))
	(estado ?h2 activa ?t2 & :(> (- ?t2 ?t1) 10))	
	
	(not (posible_paso ?h ?t3 & :(< (- ?t3 ?t1) 3)))
	
	=> 
	(assert (personas ?h1 (- ?n1 1)))
	(assert (personas ?h2 (+ ?n2 1)))
	(retract ?Borrar1)
	(retract ?Borrar2)
	(retract ?Borrar3)
)	

;; Si el número de personas de una habitación es menor a 0, se ajusta a 0. 
(defrule ajustar_personas
	?Borrar <- (personas ?h ?v & :(< ?v 0))
	
	=>
	(assert (personas ?h 0))
	(retract ?Borrar)
)

;; Si no quedan personas en la habitación, su estado es parece_inactiva y han
;; pasado menos de 3 segundos en ese estado, se pasa el estado de la habitación 
;; a inactiva. 
(defrule habitacion_cero_personas
	?Borrar1 <- (estado ?h1 parece_inactiva ?t1 & :(> (- (totalsegundos ?*hora* ?*minutos* ?*segundos*) ?t1) 3))
	?Borrar2 <- (posible_pasar ?h1 ?h2 ?t2)
	(personas ?h1 0)
	?Borrar3 <- (personas ?h2 ?n)	
	
	=>
	(assert (estado ?h1 inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*)))
	(assert (personas ?h2 (+ ?n 1)))
	(retract ?Borrar1)
	(retract ?Borrar2)
	(retract ?Borrar3)
)

;; Si pudo haber un posible paso de varias habitaciones, se deducen pasos hacia 
;; todas las habitaciones.
(defrule posible_paso_habitacion 
	(estado ?h1 parece_inactiva ?t1)
	(estado ?h2 activa ?t2)
	
	(posible_pasar ?h1|?h2 ?h1|?h2)
	
	=>
	(assert (posible_paso ?h1 ?h2 (totalsegundos ?*hora* ?*minutos* ?*segundos*)))
)
 
;; Si pasa más de 3 segundos de un posible_paso, no se afirma.
(defrule no_posible_paso
	?Borrar <- (posible_paso ?h1 ?h2 ?t & :(> (- (totalsegundos ?*hora* ?*minutos* ?*segundos*) ?t) 3))
	
	=>
	(retract ?Borrar)
)

;; Si está en parece_inactiva y pasan 3 segundos, y no hay ningun posible paso 
;; ni es salida a la calle, se activa.
(defrule no_parece_inactiva 
	?Borrar <- (estado ?h1 & ~entrada parece_inactiva ?t1 & :(> (- (totalsegundos ?*hora* ?*minutos* ?*segundos*) ?t1) 3))
	(not (posible_paso ?h1 ?h ?t))
	
	=> 
	(assert (estado ?h1 ctiva (totalsegundos ?*hora* ?*minutos* ?*segundos*)))
	(retract ?Borrar)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
