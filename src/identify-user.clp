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

(defrule identify-user:get-height "Obtiene la altura del usuario"
  (object (name [Usuario]) (altura 0))
 =>
  (bind ?h (pregunta-numerica "Cuál es su altura (en cm)" 1 300))
  (send [Usuario] put-altura ?h)
)

(defrule identify-user:get-weight "Obtiene el peso del usuario"
  (object (name [Usuario]) (peso 0))
 =>
  (bind ?w (pregunta-numerica "Cuál es su peso (en kg)" 1 600))
  (send [Usuario] put-peso ?w)
)

(defrule identify-user:compute-BMI "Calcula el IMG del usuario"
  (object (name [Usuario]) (peso ?w&~0) (altura ?h&~0) (IMC 0))
 =>
  (send [Usuario] put-IMC (round (/ ?w (** (/ ?h 100) 2))))
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
 (not (borg walk-1h ?))
 =>
  (bind ?borg (pregunta-numerica "En la escala de Borg, como se siente después de caminar tranquilamente durante una hora" 1 10))
  (assert (borg walk-1h ?borg))
)

(defrule identify-user:need-priority "Pregunta por necesidades especiales"
  (object (name [Usuario]))
  ?o <- (object (is-a Necesidad) (necesidad ?need&"resistencia"|"fuerza"|"flexibilidad"))
 =>
  (if (si-o-no-p (str-cat "Necesitas mejorar tu " ?need))
   then (assert (need-extra ?o)))
)

(defrule identify-user:done "Finaliza la recopilación de info del usuario"
  (declare (salience -100))
  (object (name [Usuario]) (dependencia ~undefined) (nivel-actividad ~undefined))
 =>
  (printout t "Procesando datos..." crlf)
  (focus generate-recom)
)