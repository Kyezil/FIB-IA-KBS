; modulo de identificacion del usuario
; el objectivo es obtener un perfil de salud del anciano
(defrule identify-user:get-name "Obtiene el nombre del usuario"
  (not (object (is-a Anciano)))
 =>
  (bind ?name (pregunta-general "Cómo se llama"))
  (make-instance [Usuario] of Anciano (nombre ?name))
)

(defrule identify-user:greet "Saluda al usuario"
  (object (is-a Anciano) (nombre ?name))
 =>
  (printout t "Bienvenido " ?name crlf)
)
