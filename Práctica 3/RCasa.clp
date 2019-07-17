;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Laura Rabadán Ortega                                                            ;;
;;                                                                                 ;;
;; Nombre Fichero: RCasa.clp                                                       ;;
;; Contenido Fichero:                                                              ;;
;;		-> Descripción de la casa:                                                   ;;
;;			- Habitaciones desde las que se puede pasar a otra.                        ;;
;;			- Habitaciones desde las que solo se puede acceder desde una concetra.     ;;
;;			- Habitaciones interiores.                                                 ;;
;;                                                                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Determinar de los pasos directos entre dos habitaciones por medio de una
;; puerta. 
(defrule posible_pasar_puerta 
	(declare (salience 10000))
	
	(puerta ?Hab1 ?Hab2)
	(habitacion ?Hab1)
	(habitacion ?Hab2)
	
	(not (posible_pasar ?Hab1|?Hab2 ?Hab2|?Hab1))
	
	=> 
	(assert (posible_pasar ?Hab1 ?Hab2))
)

;; Determinar de los pasos directos entre dos habitaciones por medio de un
;; paso sin puerta. 
(defrule posible_pasar_paso 
	(declare (salience 10000))
	
	(paso ?Hab1 ?Hab2)
	(habitacion ?Hab1)
	(habitacion ?Hab2)
	
	(not (posible_pasar ?Hab1|?Hab2 ?Hab2|?Hab1))
	
	=> 
	(assert (posible_pasar ?Hab1 ?Hab2))
)

;; Derteminar de las habitaciones desde las que solo se puede llegar desde 
;; una habitación y desde que habitación se puede acceder a ella. 
(defrule necesario_pasar
    (declare (salience 1000)) 
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
	
;; Determinar de las habitaciones que son interiores, sin ventanas al exterior. 
(defrule habitaciones_interiores
    (declare (salience 1000))
	(habitacion ?hab & ~jardin)
	(not (ventana ?hab))
	
	(not (habitacion_interior ?hab))
	
	=>
	(assert (habitacion_interior ?hab))
)
