;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Laura Rabadán Ortega                                                       ;;
;;                                                                            ;;
;; Nombre Fichero: ControlSemana.clp                                          ;;
;; Contenido Fichero:                                                         ;;
;;		-> Inicialización:                                                      ;;
;;			- Se inicializa el día en el que empieza el programa.                 ;; 
;;          - Se inicializa la hora a la que empieza el programa.             ;;
;;          - Se guarda la hora del sistema.                                  ;;
;;      -> Ajuste:                                                            ;;
;;          - Se ajusta el día de la semana en función al paso de las horas.  ;;
;;          - Se ajustan los segundos en función a la hora del sistema.       ;;
;;          - Se ajustan los minutos en función a la hora del sistema.        ;;
;;          - Se ajustan las horas en función a la hora del sistema.          ;;
;;                                                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Inicialización
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Preguntar a la persona que día es hoy
(defrule InicializarSemana
    (declare (salience 1000))
    (not (dia ?$))
    
    =>
    (printout t crlf "Que dia de la semana es hoy?")
    (printout t crlf "(L = 1 / M = 2 / X = 3 / J = 4 / V = 5 / S = 6 / D = 7): ")
    (assert 
        (dia (read))
    )
)

;; Preguntar a la persona que hora es
(defrule InicializarHora
    (declare (salience 1000))
    (not (hora ?$))
    
    =>
    (printout t crlf "Que hora es? (hora - numero): ")
    (bind ?hora (read))

    (printout t crlf "Que minuto es? (minuto - numero): ")
    (bind ?min (read))

    (assert 
        (hora ?hora ?min 0)
        (hora_inicio 0)
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Control de los dias de la semana
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Se cambia el día de la semana
(defrule CambioDia
    (declare (salience 100))
    ?Borrar1 <- (dia ?dia)
    ?Borrar2 <- (cambio_dia)
    ?Borrar3 <- (hora_inicio ?t)
    
    => 
    (retract ?Borrar1 ?Borrar2 ?Borrar3)
    (assert 
        (dia (+ ?dia 1))
        (hora_inicio (+ ?t 86400))      ;; Número de segundos de un día
    )
)

;; Se ajusta el código a los permitidos (Lunes es 1, no 8)
(defrule AjustarDia
    (declare (salience 10))
    ?Borrar <- (dia ?dia)
    (test 
        (> ?dia 7)
    )
    
    =>
    (retract ?Borrar)
    (assert
        (dia 1)
    )
)

;; Se aumentan los segundos en función al paso del tiempo
(defrule CambioHora
    (declare (salience -100))
    ?Borrar <- (hora ?h ?m ?s)

    =>
    (retract ?Borrar)
    (assert
        ;;(hora ?h ?m (div (+ ?s (/ (- (time) ?t) 10) ) 1))
        (hora ?h ?m (+ ?s 60))
    )
)

;; Se ajustan los segundos para que estén entre [0,60[
(defrule AjusteHora_segundos
    (declare (salience 100))
    ?Borrar <- (hora ?h ?m ?s)

    
    (test 
        (> ?s 59)
    )

    =>
    (retract ?Borrar)
    (assert 
        (hora ?h
            (+ ?m (div ?s 60))
            (- ?s (* 60 (div ?s 60)))
        )
    )
)

;; Se ajustan los minutos para que estén entre [0,60[
(defrule AjusteHora_minutos
    (declare (salience 100))
    ?Borrar <- (hora ?h ?m ?s)

    
    (test 
        (> ?m 59)
    )

    =>
    (retract ?Borrar)
    (assert 
        (hora (+ ?h (div ?m 60)) (- ?m (* 60 (div ?m 60))) ?s)
    )
)

;; Se ajustan las horas para que estén entre [0,24[
(defrule AjusteHora_horas
    (declare (salience 100))
    ?Borrar <- (hora ?h ?m ?s)

    (test 
        (> ?h 23)
    )

    =>
    (retract ?Borrar)
    (assert 
        (hora (- ?h (* 24 (div ?h 24))) ?m ?s) 
        (cambio_dia)
    )
)
