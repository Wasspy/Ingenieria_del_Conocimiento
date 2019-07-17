;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Laura Rabadán Ortega                                                       ;;
;;                                                                            ;;
;; Nombre Fichero: DSensores.clp                                              ;;
;; Contenido Fichero:                                                         ;;
;;		-> Estados iniciales:                                                   ;;
;;          - Estado inicial de las habitaciones.                             ;;
;;			- Actividad de una habitación.                                        ;;
;;			- Estado inicial de un sensor en una habitación.                      ;;
;;                                                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Estados iniciales 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Declaración del estado inicial de una habitación y la marca de tiempo de ese 
;; estado. 
(deffacts estados
	(estado entrada             inactiva 0)
	(estado comedor             inactiva 0)
	(estado salon               inactiva 0)
	(estado cocina              inactiva 0)
	(estado lavadora            inactiva 0)
	(estado baniococina         inactiva 0)
	(estado pasillo             inactiva 0)
	(estado banio               inactiva 0)
	(estado dormitorioinvitados inactiva 0)
	(estado patiointerior       inactiva 0)
	(estado dormitorioninios    inactiva 0)
	(estado despacho            inactiva 0)
	(estado vestidor            inactiva 0)
	(estado dormitorio          inactiva 0)
	(estado baniodormitorio     inactiva 0)
	(estado jardin              inactiva 0)
	(estado garaje              inactiva 0)
)

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

;; Estado inicial de las puertas 
(deffacts EstadoPuertas
	(estado_puerta entrada         cerrada)
	(estado_puerta cocina          cerrada)
	(estado_puerta despacho        cerrada)
)

;; Estado de los sensores (todos empiezan desactivados)
(deffacts InicializarSensores
    (valor movimiento entrada             off)
	(valor movimiento comedor             off)
	(valor movimiento salon               off)
	(valor movimiento cocina              off)
	(valor movimiento lavadora            off)
	(valor movimiento baniococina         off)
	(valor movimiento pasillo             off)
	(valor movimiento banio               off)
	(valor movimiento dormitorioinvitados off)
	(valor movimiento patiointerior       off)
	(valor movimiento dormitorioninios    off)
	(valor movimiento despacho            off)
	(valor movimiento vestidor            off)
	(valor movimiento dormitorio          off)
	(valor movimiento baniodormitorio     off)
	(valor movimiento garaje              off)
    
    (valor magnetico entrada         on)
	(valor magnetico cocina          on)
	(valor magnetico baniococina     on)
	(valor magnetico banio           on)
	(valor magnetico patiointerior   on)
	(valor magnetico despacho        on)
	(valor magnetico baniodormitorio on)
    
    (valor agua patiointerior off)
)
