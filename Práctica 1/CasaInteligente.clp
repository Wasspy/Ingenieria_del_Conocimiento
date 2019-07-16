;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Laura Rabadán Ortega
;; 
;; Nombre Fichero: CasaInteligente.clp
;; Contenido Fichero: 
;;		-> Cargar los datos del conocimiento que se va a usar: 
;;			- Se debe comentar el que se quiere usar, si el dado por el profesor
;;			  o el del alumno. 
;; 		-> Representación de la casa:
;;			- Datos:
;;				* Las diferentes habitaciones de la casa.
;;				* Las habitaciones que tienen ventanas. 
;;				* Las puertas entre dos habitaciones. 
;; 				* Los pasos sin puerta entre dos habitaciones. 
;;			- Reglas:
;;				* posible_pasar_puerta: se puede pasar de una habitación a otra 
;;										habitación por medio de una puerta.
;;				* posible_pasar_paso: se puede pasar de una habitación a otra
;;									  habitación por medio de un paso sin puerta. 
;;				* necesario_pasar: solo se puede acceder a una habitación por 
;;								   medio de otra habitación. 
;;				* habitaciones_interiores: habitación que no da al exterior (no
;;										   tiene ventanas al exterior). 
;; 		-> Registro de los datos de los sensores:
;;			- Datos:
;;				* Las habitaciones que tienen sensores de movimientos. 
;;				* Las habitaciones que tienen pulsadores de luz.
;;				* Las habitaciones que tienen detectores de luminosidad. 
;; 			- Reglas:
;; 				* registrar_valor: registra el valor recibido por un sensor y el
;;								   tiempo en segundos en el que se recibe ese 
;;								   valor. 
;; 				* limpiar_registros: mantiene actualizado el último registro.
;; 				* activacion: guarda la última vez que el sensor de movimiento 
;;							  cambió de OFF a ON. 
;; 				* desactivacion: guarda la última vez que el sensor de movimiento
;;								 cambió de ON a OFF. 
;; 				* eliminar_activacion: mantiene actualizada la última activación.
;; 				* eliminar_desactivacion: mantiene actualizada la última desactivación. 
;; 				* mostrar_informe_1: muestra por pantalla el último registro de 
;;									 cualquier sensor de una habitación especifica
;;									 (el último registro de la habitación). 
;; 				* mostrar_informe_2: muestra por pantalla los registros de una
;;									 habitación, del más reciente al más antiguo,
;; 									 menos el primero y el último.
;; 				* mostrar_informe_3: muestra por pantalla el registro más antiguo
;;									 de una habitación. 
;; 				* borrar_infor_informe_1: se borran los hechos auxiliares 
;;								          utilizados para poder generar el 
;;										  informe. 
;; 				* borrar_infor_informe_2: se termina de borrar los hechos auxiliares
;;										  para generar el informe.
;; 		-> Manejo inteligente de luces de una habitación:
;;			- Datos:
;;				* Habitaciones en las que se controlan las luces de manera inteligente. 
;;				* Valores mínimos de la luz necesaria en las habitaciones. 
;;				* Estado de las habitaciones al inicio. 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cargar los datos del conocimiento que se va a usar
;; NOTA: comentar y descomentar en función del conocimiento que se quiere usar. 
 
(defrule cargardatosasimular
	
	=>
	(load conocimiento_profesor.clp)
;	(load conocimiento_alumno.clp)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Representación de la casa
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DATOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Declaración de las habitaciones de la casa. 
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

;; Declaración de las puertas entre dos habitaciones. 
(deffacts Puertas
	(puerta entrada jardin)
	(puerta entrada cocina)
	(puerta cocina banioCocina)
	(puerta entrada pasillo)
	(puerta pasillo banio)
	(puerta pasillo dormitorioinvitados)
	(puerta pasillo patiointerior)
	(puerta pasillo dormitorioninios)
	(puerta pasillo despacho)
	(puerta pasillo dormitorio)
	(puerta dormitorio vestidor)
	(puerta dormitorio baniodormitorio)
	(puerta garaje jardin)
)

;; Declaración de los pasos sin puertas entre dos habitaciones. 
(deffacts Pasos
	(paso entrada comedor)
	(paso comedor salon)
	(paso cocina lavadora)
)

;; Declaración de las habitaciones con ventanas. 
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
;; REGLAS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Determinación de los pasos directos entre dos habitaciones por medio de una
;; puerta. 
(defrule posible_pasar_puerta 
	(declare (salience 1))
	
	(puerta ?Hab1 ?Hab2)
	(habitacion ?Hab1)
	(habitacion ?Hab2)
	
	(not (posible_pasar ?Hab1|?Hab2 ?Hab2|?Hab1))
	
	=> 
	(assert (posible_pasar ?Hab1 ?Hab2))
)

;; Determinación de los pasos directos entre dos habitaciones por medio de un
;; paso sin puerta. 
(defrule posible_pasar_paso 
	(declare (salience 1))
	
	(paso ?Hab1 ?Hab2)
	(habitacion ?Hab1)
	(habitacion ?Hab2)
	
	(not (posible_pasar ?Hab1|?Hab2 ?Hab2|?Hab1))
	
	=> 
	(assert (posible_pasar ?Hab1 ?Hab2))
)

;; Derteminación de las habitaciones desde las que solo se puede llegar desde 
;; una habitación y desde que habitación se puede acceder a ella. 
(defrule necesario_pasar 
	(posible_pasar ?Hab1 ?Hab2)
	(habitacion ?Hab1 & ~jardin)
	(habitacion ?Hab2 & ~jardin)
	
	(not (posible_pasar ?Hab2 ~?Hab1))
	(not (posible_pasar ~?Hab1 ?Hab2))
	(not (necesario_pasar ?Hab2 ?Hab1))
	
	=>
	;; Necesario pasar por Hab1 para ir a Hab2
	(assert (necesario_pasar ?Hab1 ?Hab2)) 
)
	
;; Determinación de las habitaciones que son interiores, sin ventanas al exterior. 
(defrule habitaciones_interiores 
	(habitacion ?hab & ~jardin)
	(not (ventana ?hab))
	
	(not (habitacion_interior ?hab))
	
	=>
	(assert (habitacion_interior ?hab))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Registro de los datos de los sensores
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DATOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Declaración de los sensores de movimiento de las habitaciones.
(deffacts SensMovimiento
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
	(dispositivo movimiento jardin)
	(dispositivo movimiento garaje)
)

;; Declaración de los pulsadores de luz de las habitaciones.
(deffacts Pulsadores
	(dispositivo estadoluz entrada)
	(dispositivo estadoluz comedor)
	(dispositivo estadoluz salon)
	(dispositivo estadoluz cocina)
	(dispositivo estadoluz lavadora)
	(dispositivo estadoluz baniococina)
	(dispositivo estadoluz pasillo)
	(dispositivo estadoluz banio)
	(dispositivo estadoluz dormitorioinvitados)
	(dispositivo estadoluz patiointerior)
	(dispositivo estadoluz dormitorioninios)
	(dispositivo estadoluz despacho)
	(dispositivo estadoluz vestidor)
	(dispositivo estadoluz dormitorio)
	(dispositivo estadoluz baniodormitorio)
	(dispositivo estadoluz jardin)
	(dispositivo estadoluz garaje)
)

;; Declaración de los sensores de luminosidad de las habitaciones.
(deffacts Luminosidad
	(dispositivo luminosidad entrada)
	(dispositivo luminosidad comedor)
	(dispositivo luminosidad salon)
	(dispositivo luminosidad salita) 
	(dispositivo luminosidad cocina)
	(dispositivo luminosidad lavadora)
	(dispositivo luminosidad baniococina)
	(dispositivo luminosidad pasillo)
	(dispositivo luminosidad banio)
	(dispositivo luminosidad dormitorioinvitados)
	(dispositivo luminosidad patiointerior)
	(dispositivo luminosidad dormitorioninios)
	(dispositivo luminosidad despacho)
	(dispositivo luminosidad vestidor)
	(dispositivo luminosidad dormitorio)
	(dispositivo luminosidad baniodormitorio)
	(dispositivo luminosidad jardin)
	(dispositivo luminosidad garaje)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; REGLAS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Registra el valor de un sensor y el momento, en segundos, de cuando se recibió
;; la señal. 
(defrule registrar_valor
	?Borrar <- (valor ?tipo ?hab ?v)

	(habitacion ?hab)
	(dispositivo ?tipo ?hab)
	
	=>
	;; Para guardar el tiempo y que sea igual en los dos casos
	(bind ?t (totalsegundos ?*hora* ?*minutos* ?*segundos*))	
	
	(retract ?Borrar)
	(assert (valor_registrado ?t ?tipo ?hab ?v))
	(assert (ultimo_registro ?tipo ?hab ?t))
)

;; Se eliminan los registros desactualizados de 'ultimo_registro' de los sensores
;; de una habitación. 
(defrule limpiar_registros 
	(ultimo_registro ?tipo ?hab ?t1)
	(ultimo_registro ?tipo ?hab ?t2 & ~?t1)
	
	(test (< ?t1 ?t2))
	
	?Borrar <- (ultimo_registro ?tipo ?hab ?t1)
	
	=>
	(retract ?Borrar)
)

;; Registra el último paso del sensor de movimiento de una habitación de OFF a ON.
(defrule activacion
	(declare (salience 1))
	
	(valor movimiento ?hab on)
	(ultimo_registro movimiento ?hab ?t)
	(valor_registrado ?t movimiento ?hab off)
	=>
	(assert (ultima_activacion movimiento ?hab ?t))
)

;; Registra el último paso del sensor de movimiento de una habitación de ON a OFF.
(defrule desactivacion
	(declare (salience 1))
	
	(valor movimiento ?hab off)
	(ultimo_registro movimiento ?hab ?t)
	(valor_registrado ?t movimiento ?hab on)
	=>
	(assert (ultima_desactivacion movimiento ?hab ?t))
)

;; Se eliminan los registros desactualizados de 'ultima_activacion' de los 
;; sensores de una habitación.
(defrule eliminar_activacion
	(ultima_activacion movimiento ?hab ?t1)
	(ultima_activacion movimiento ?hab ?t2 & ~?t1)
	
	(test (< ?t1 ?t2))
	
	?Borrar <- (ultima_activacion movimiento ?hab ?t1)
	=>
	(retract ?Borrar)
)

;; Se eliminan los registros desactualizados de 'ultima_desactivacion' de los 
;; sensores de una habitación.
(defrule eliminar_desactivacion
	(ultima_desactivacion movimiento ?hab ?t1)
	(ultima_desactivacion movimiento ?hab ?t2 & ~?t1)
	
	(test (< ?t1 ?t2))
	
	?Borrar <- (ultima_desactivacion movimiento ?hab ?t1)
	=>
	(retract ?Borrar)
)


;; Se muestra por pantalla el ultimo registro de los sensores de una habitacion. 
(defrule mostrar_informe_1
	?Borrar <- (informe ?h)
	(ultimo_registro ?tipo ?h ?t)
	
	
	(not (ultimo_registro ? ?h >?t))		;; Que no haya otro 'ultimo_registro' de otro sensor con tiempo menor
	
	(valor_registrado ?t ?tipo ?h ?v)
	=> 
	(retract ?Borrar)
	(assert (ultimo_pintado ?h ?t ?tipo))
	(assert (ya_pintado ?h ?t ?tipo))
	(printout t crlf "Informe habitacion " ?h)
	(printout t crlf (hora-segundos ?t) ":" (minuto-segundos ?t) ":" (segundo-segundos ?t) " - " ?tipo " - " ?v)
)

;; Se muestra por pantalla los registros de los sensores de un habitación, del
;; más reciente al más antiguo, menos el más reciente y el más antiguo. 
(defrule mostrar_informe_2
	?Borrar <- (ultimo_pintado ?h ?t1 ?tipo1)
	(valor_registrado ?t2 ?tipo2 & ~?tipo1 ?h ?v)
	
	(not (ya_pintado ?h ?t2 ?tipo2))
	(test (>= ?t1 ?t2))

	(not (valor_registrado ?t3 & :(and (< ?t2 ?t3) (> ?t1 ?t3)) ? ?h ?))

	=>
	(retract ?Borrar)
	(assert (ultimo_pintado ?h ?t2 ?tipo2))
	(assert (ya_pintado ?h ?t2 ?tipo2))
	(printout t crlf (hora-segundos ?t2) ":" (minuto-segundos ?t2) ":" (segundo-segundos ?t2) " - " ?tipo2 " - " ?v)
)

;; Muestra por pantalla el registro más antigo de los sensores de una habitación. 
(defrule mostrar_informe_3 
	?Borrar <- (ultimo_pintado ?h ?t1 ?tipo1)
	
	(not (valor_registrado ?t2 & :(<= ?t2 ?t1) ?tipo2 & ~?tipo1 ?h ?))

	=>
	(retract ?Borrar)
	(assert (borrar_pintado ?h))
)

;; Se borran los hechos auxiliares utilizados para generar el informe de una 
;; habitación. 
(defrule borrar_infor_informe_1
	(borrar_pintado ?h)
	?Borrar <- (ya_pintado ?h ? ?)
	
	=>
	(retract ?Borrar)
)

;; Se terminan de borrar los hechos auxiliares utilizados para generar el informe
;; de una habitación. 
(defrule borrar_infor_informe_2
	?Borrar <- (borrar_pintado ?h)
	(not (ya_pintado ?h ? ?))
	
	=> 
	(retract ?Borrar)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Manejo inteligente de luces de una habitación
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DATOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Declaración de las habitaciones en las que se van a manejar las luces de manera
;; inteligente. 
(deffacts LucesInteligentes
	(Manejo_inteligente_luces salon)
	(Manejo_inteligente_luces entrada)
	(Manejo_inteligente_luces cocina)
	(Manejo_inteligente_luces baniococina)
	(Manejo_inteligente_luces pasillo)
	(Manejo_inteligente_luces banio)
	(Manejo_inteligente_luces vestidor)
	(Manejo_inteligente_luces baniodormitorio)
)

;; Declaración de los valores de luz mínimos de una habitación.
(deffacts LuzMinimo
	(luz_minimo salon 300)
	(luz_minimo dormitorio 150)
	(luz_minimo cocina 200)
	(luz_minimo banio 200)
	(luz_minimo pasillo 200)
	(luz_minimo despacho 500)
)

;; Declaración del estado inicial de una habitación y la marca de tiempo de ese 
;; estado. 
(deffacts estados
	(estado entrada inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
	(estado comedor inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
	(estado salon inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
	(estado cocina inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
	(estado lavadora inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
	(estado baniococina inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
	(estado pasillo inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
	(estado banio inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
	(estado dormitorioinvitados inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
	(estado patiointerior inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
	(estado dormitorioninios inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
	(estado despacho inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
	(estado vestidor inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
	(estado dormitorio inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
	(estado baniodormitorio inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
	(estado jardin inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
	(estado garaje inactiva (totalsegundos ?*hora* ?*minutos* ?*segundos*))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
