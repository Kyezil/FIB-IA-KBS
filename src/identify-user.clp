; modulo de identificacion del usuario
; el objectivo es obtener un perfil de salud del anciano
(defrule identify-user:get-name "Obtiene el nombre del usuario"
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

(defrule identify-user:done "Finaliza la recopilación de info del usuario"
  (object (name [Usuario]) (dependencia ~undefined) (nivel-actividad ~undefined))
 =>
  (printout t "Procesando datos..." crlf)
  (focus generate-recom)
)