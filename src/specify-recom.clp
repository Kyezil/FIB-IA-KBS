; modulo de concretizacion de los ejercicios en base a un planning abstracto

(defrule specify-recom:init-days "Crear facts para la creacion de dias"
  (object (is-a ADay) (name ?aday))
 =>
  (assert (day (aday ?aday)))
)

(defrule specify-recom:add-activities "Assigna actividades en orden a los dias"
  ?d-f <- (day (aday ?aday))
  (object (is-a ADay) (name ?aday) (main-need ?need)
          (activities $?acts&:(< (length$ ?acts) 4)))
 =>
  ; (printout t "day is " ?aday " with need " ?need crlf)
  ;; find available activities
  (bind ?available-acts (find-all-instances ((?ins Actividad))
                                            (and (member$ ?need ?ins:llena)
                                                 (not (member$ ?ins ?acts)))))
  ;; (printout t ?available-acts)
  ;; pick one at random
  (bind ?n (length$ ?available-acts))
  (if (> ?n 0) then ; necessary if there is not enough activities
                 (bind ?i (random 1 ?n))
                 (bind ?act (nth ?i ?available-acts))
;  (printout t "selected activity is ")
;  (send ?act print)
                 (slot-insert$ ?aday activities 1 ?act))
)

(defrule specify-recom:test-print "Ver la planificación"
  (declare (salience -100))
  ?week <- (object (name [AbstractWeek]))
 =>
  (printout t "=== Planificacion de la semana ===" crlf)
  (foreach ?day (send ?week get-days)
    (printout t "-- Dia " ?day-index " ["
              (send (send ?day get-main-need) get-necesidad)
              "] --" crlf)
      ; (printout t "actividades " (send ?day get-activities) crlf)
      (bind ?acts (send ?day get-activities))
      (foreach ?act ?acts
        (format t " > %s [%dmin]%n"
                (send ?act get-actividad) (send ?act get-duracion-min))
        )
      (printout t crlf)
    )
)