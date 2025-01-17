; modulo de identificacion del usuario
; el objectivo es obtener un perfil de salud del anciano
(defrule identify-user::get-name "Obtiene el nombre del usuario"
  (declare (salience 10))
  (not (object (name [Usuario])))
 =>
  (bind ?name (pregunta-general "Cómo se llama"))
  (make-instance Usuario of Anciano (nombre ?name))
)

(defrule identify-user::get-height "Obtiene la altura del usuario"
  (object (name [Usuario]) (altura 0))
 =>
  (bind ?h (pregunta-numerica "Cuál es su altura (en cm)" 1 300))
  (send [MAIN::Usuario] put-altura ?h)
)

(defrule identify-user::get-weight "Obtiene el peso del usuario"
  (object (name [Usuario]) (peso 0))
 =>
  (bind ?w (pregunta-numerica "Cuál es su peso (en kg)" 1 600))
  (send [MAIN::Usuario] put-peso ?w)
)

(defrule identify-user::compute-BMI "Calcula el IMG del usuario"
  (object (name [Usuario]) (peso ?w&~0) (altura ?h&~0) (IMC 0))
 =>
  (send [MAIN::Usuario] put-IMC (round (/ ?w (** (/ ?h 100) 2))))
)

(defrule identify-user::dependency "Obtiene el grado de dependencia del usuario"
  (object (name [Usuario]) (dependencia undefined))
 =>
  (bind ?grade independiente)
  (if (si-o-no-p (str-cat "Es usted dependiente"))
   then
  (bind ?grade (pregunta "Cuál es su nivel de dependencia"
                         (delete-member$ (slot-allowed-values Anciano dependencia) undefined independiente)
                         )))
  (send [MAIN::Usuario] put-dependencia ?grade)
)

(defrule identify-user::borg "Obtiene el nivel de esfuerzo posible del usuario"
 (not (borg walk-1h ?))
 =>
  (bind ?borg (pregunta-numerica "En la escala de Borg, como de cansado se siente después de caminar a ritmo moderado durante una hora" 1 10))
  (assert (borg walk-1h ?borg))
)


;; Pregunta por el estado de salut del paciente
(defrule identify-user::health-state "Detecta problemas de salud"
 =>
  (if (si-o-no-p "Tiene problemas cardíacos")
   then (assert (heart-problems)))
     ; (assert (change-priority "resistencia" 10))
     ;    (assert (change-priority "fuerza" 10)))
  (if (si-o-no-p "Sufre de incontinencia urinaria")
   then (assert (incontinency)))
     ; (assert (change-priority "equilibrio" 35)))
  (if (si-o-no-p "Tiene osteoporosis o artrosis")
   then (assert (osteoporosis)))
   ; (assert (change-priority "equilibrio" 25))
   ;      (assert (change-priority "flexibilidad" 25)))
  (if (si-o-no-p "Le da miedo caerse")
   then (assert (falling-fear)))
     ; (assert (change-priority "equilibrio" 35))
     ;    (assert (change-priority "coordinacion" 20)))
   ;; si diu que si v preguntar per parts del cos
  (if (si-o-no-p "Ha caído recientemente")
   then (assert (has-fallen)))
     ; (assert (change-priority "equilibrio" 25))
     ;    (assert (change-priority "resitencia" 5)))
  (if (si-o-no-p "Tiene hipertensión")
   then (assert (hypertension)))
  (if (si-o-no-p "Se siente estresado")
   then (assert (stress)))
  (if (si-o-no-p "Está deprimido")
   then (assert (depression)))
  (if (si-o-no-p "Le duele alguna parte del cuerpo")
   then (assert (hurt-part)))
)

(defrule identify-user::hurt-part "Detecta algun dolor en una parte del cuerpo"
  (hurt-part)
  (object (name ?part-name) (is-a Parte+del+cuerpo) (parte-del-cuerpo ?part))
 =>
  (bind ?det (if (eq ?part "tronco") then "su " else "sus "))
  (if (not (si-o-no-p (str-cat "Puede usar " ?det ?part)))
   then (assert (hurt ?part-name)))
)

(defrule identify-user::obesity "Detecta obesidad"
  (object (name [Usuario]) (IMC ?bmi&:(> ?bmi 30)))
 =>
  (assert (obesity)))

(defrule identify-user::done "Finish identify user"
  (declare (salience -100))
 =>
  (focus generate-recom))