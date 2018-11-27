; modulo de identificacion del usuario
; el objectivo es obtener un perfil de salud del anciano
(defrule identify-user:get-name "Obtiene el nombre del usuario"
  (declare (salience 10))
  (not (object (name [Usuario])))
 =>
  (bind ?name (pregunta-general "Cómo se llama"))
  (make-instance Usuario of Anciano
                 (nombre ?name)
  )
)

(defrule identify-user:activity-level "Obtiene el nivel de actividad del usuario"
  (object (name [Usuario]) (nivel-actividad undefined))
 =>
  (bind ?act (pregunta "Cúal es su nivel de actividad"
                       (delete-member$ (slot-allowed-values Anciano nivel-actividad) undefined)
                       ))
  (send [Usuario] put-nivel-actividad ?act)
)

(defrule identify-user:dependency "Obtiene el grado de dependencia del usuario"
  (object (name [Usuario]) (dependencia undefined))
 =>
  (bind ?grade (pregunta "Cúal es su nivel de dependencia"
                         (delete-member$ (slot-allowed-values Anciano dependencia) undefined)
                         ))
  (send [Usuario] put-dependencia ?grade)
)

(defrule identify-user:borg "Obtiene el nivel de esfuerzo posible del usuario"
 (not (borg walk-1h))
 =>
  (bind ?borg (pregunta-numerica "En la escala de Borg, como se siente después de caminar tranquilamente durante una hora" 1 10))
  (assert (borg walk-1h ?borg))
)

(defrule identify-user:days1 "Define el #dias"
  (not (days))
  (borg walk-1h 1)
 =>
  (assert (days 7))
)
(defrule identify-user:days2 "Define el #dias"
  (not (days))
  (borg walk-1h 2)
 =>
  (assert (days 6))
)
(defrule identify-user:days3 "Define el #dias"
  (not (days))
  (borg walk-1h 3)
 =>
  (assert (days 5))
)
(defrule identify-user:days4 "Define el #dias"
  (not (days))
  (borg walk-1h 4|5)
 =>
  (assert (days 4))
)
(defrule identify-user:days5 "Define el #dias"
  (not (days))
  (borg walk-1h ?)
 =>
  (assert (days 3))
)


(defrule identify-user:done "Finaliza la recopilación de info del usuario"
  (declare (salience -100))
  (object (name [Usuario]) (dependencia ~undefined) (nivel-actividad ~undefined))
 =>
  (printout t "Procesando datos..." crlf)
  (focus generate-recom)
)