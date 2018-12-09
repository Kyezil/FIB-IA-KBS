; modulo de concretizacion de los ejercicios en base a un planning abstracto
(defrule specify-recom::clamp-day-range "Asegura generar entre 3 y 7 dias"
  (declare (salience 10))
  ?o <- (days ?d&:(or (> ?d 7) (< ?d 0)))
 =>
  (retract ?o)
  (assert (days (max 0 (min 7 ?d))))
)

(defrule specify-recom::init-days "Crear facts para la creacion de dias"
  (object (is-a ADay) (name ?day))
 =>
  (assert (day (aday ?day)))
)

;; Valoracion de actividades segun el usuario
(defrule specify-recom::init-activities "Crear facts para la valorar actividades"
  (declare (salience 10))
  (object (is-a Actividad) (name ?act))
 =>
  (assert (activity (act ?act)))
)

(defrule specify-recom::change-value-class "Cambia la puntuacion de una clase de Actividad"
  ?o <- (change-value class ?class ?val)
 =>
  (do-for-all-instances ((?ex ?class)) TRUE
    ; (printout t "found instance of " ?class crlf)
    ; (send ?ex print)
    ; (printout t crlf)
    (do-for-fact ((?act activity)) (eq ?act:act (instance-name ?ex))
      ; (printout t  "found activity fact" ?act crlf)
      (assert (activity (act ?act:act) (value (+ ?act:value ?val))))
      (retract ?act)
    )
  )
  (retract ?o)
)

(defrule specify-recom::change-value-need "Cambia la puntuacion de actividades para una necesidad"
  ?o <- (change-value need ?need-name ?val)
  (object (is-a Necesidad) (name ?need) (necesidad ?need-name))
 =>
  (do-for-all-instances ((?ex Actividad)) (member$ ?need ?ex:llena)
    ; (printout t "found activity with need " ?need "> " ?ex crlf)
    (do-for-fact ((?act activity)) (eq ?act:act (instance-name ?ex))
      ; (printout t  "found activity fact" ?act crlf)
      (assert (activity (act ?act:act) (value (+ ?act:value ?val))))
      (retract ?act)
    )
   )
  (retract ?o)
)
;;; Valoracion de ejercicios segun el usuario
(defrule specify-recom::health-heart
  (heart-problems)
 =>
  (assert (change-value class bicicleta+estatica 10))
  (assert (change-value class abdominales 10))
)
(defrule specify-recom::health-osteoroposis
  (osteoroposis)
 =>
  (assert (change-value class caminar 10))
  (assert (change-value class levantarse+y+sentarse+silla 10))
)
(defrule specify-recom::health-hypertension
  (hypertension)
 =>
  (assert (change-value class natacion 10))
  (assert (change-value class bicicleta+estatica 10))
  (assert (change-value need "resistencia" 10))
  (assert (change-value need "fuerza" 20))
  (assert (change-value need "flexibilidad" 20))
)
(defrule specify-recom::health-stress
  (stress)
 =>
  (assert (change-value class relajacion))
)

(defrule specify-recom::high-dependence "Elimina ejercicios solitarios si dependencia"
  (object (name [Usuario]) (dependencia ~independiente&~undefined))
  (object (is-a Actividad) (name ?ex) (solitaria TRUE))
  ?a-o <- (activity (act ?ex))
 =>
  ; (printout t "Found solitary activity" ?ex crlf)
  (retract ?a-o)
)


;;; Creacion del planning concreto
(defrule specify-recom::add-activities "Assigna actividades en orden a los dias"
  ?d-f <- (day (aday ?aday) (total-time ?tt&:(< ?tt 90))) ; max 1h30
  (object (is-a ADay) (name ?aday) (main-need ?need) (activities $?acts))
 =>
  ; (printout t "day is " ?aday " with need " ?need crlf)
  ;; find available activities
  (bind ?rem-time (- 90 ?tt))
  (bind ?available-acts
    (find-all-instances ((?ins Actividad))
                        (and (member$ ?need ?ins:llena)
                             (not (member$ ?ins ?acts))
                             (<= (nth 1 ?ins:duracion) ?rem-time))))
  ;; (printout t ?available-acts)
  ;; pick one at random
  (bind ?n (length$ ?available-acts))
  (if (> ?n 0)
   then ; necessary if there is not enough activities
     (bind ?i (random 1 ?n))
     (bind ?act (nth ?i ?available-acts))
;  (printout t "selected activity is ")
;  (send ?act print)
     (slot-insert$ (IA ?aday) activities 1 ?act)
     (modify ?d-f (total-time (+ ?tt (nth 1 (send ?act get-duracion)))))
  )
)

(defrule specify-recom::test-print "Ver la planificación"
  (declare (salience -100))
  ?week <- (object (name [AbstractWeek]))
 =>
  (printout t "=== Planificacion de la semana ===" crlf)
  (foreach ?day (send ?week get-days)
    (printout t "-- Dia " ?day-index " ["
              (send (IA (send ?day get-main-need)) get-necesidad)
              "] --" crlf)
      ; (printout t "actividades " (send ?day get-activities) crlf)
      (bind ?acts (send ?day get-activities))
      (foreach ?act ?acts
        (format t " > %s [%dmin]%n"
                (send ?act get-actividad) (nth 1 (send ?act get-duracion)))
        )
      (printout t crlf)
    )
)