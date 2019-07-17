;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Laura Rabadán Ortega                                                       ;;
;;                                                                            ;;
;; Nombre Fichero: MIniciarUbicacion.clp                                      ;;
;; Contenido Fichero:                                                         ;;
;;		-> Ubicacion de los individuos:                                         ;;
;;			- Si es el horario de trabajo de la persona y no está, se ubica.      ;;
;;			- Si es sábado y está en el despacho, se ubica.                       ;;
;;                                                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Ubicación de los individuos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; El dueño está trabajando, por lo que solo debería estar el perro en la casa
(defrule NoDuenio_maniana
    ?Borrar <- (activa iniciar)
    (not (ubicacion perro ?))
    (not (ubicacion persona ?))

    (estado activa ?hab ?)
    (not (estado activa ?hab1 & ~?hab))

    (dia 1|2|3|4|5)
    (hora ?h ?m ?s)

    (test (> ?h 8))
    (test (< ?h 13))

    => 
    (retract ?Borrar)
    (assert 
        (ubicacion perro ?hab)
        (ubicacion persona exterior)
    )
)

;; El dueño está trabajando, por lo que solo debería estar el perro en la casa
(defrule NoDuenio_tarde
    ?Borrar <- (activa iniciar)
    (not (ubicacion perro ?))
    (not (ubicacion persona ?))

    (estado activa ?hab ?)
    (not (estado activa ?hab1 & ~?hab))

    (dia 1|2|3|4|5)
    (hora ?h ?m ?s)

    (test (> ?h 16))
    (test (< ?h 20))

    => 
    (retract ?Borrar)
    (assert 
        (ubicacion perro ?hab)
        (ubicacion persona exterior)
    )
)

;; El dueño debe estar trabajando en el despacho, por lo que, si hay otra 
;; habitación activa, será donde está el perro
(defrule NoDuenio_sabado
    ?Borrar <- (activa iniciar)
    (not (ubicacion perro ?))
    (not (ubicacion persona ?))

    (dia 6)
    (hora ?h ?m ?s)
    (estado activa despacho ?)
    (estado activa ?hab & ~despacho ?)

    (test (> ?h 10))
    (test (< ?h 13))

    => 
    (retract ?Borrar)
    (assert 
        (ubicacion perro ?hab)
        (ubicacion persona despacho)
    )
)
