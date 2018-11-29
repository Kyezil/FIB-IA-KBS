; modulo de concretizacion de los ejercicios en base a un planning abstracto
(defrule specify-recom:add-activities "Assigna actividades en orden a los dias"
  ?o-day <- (object (is-a ADay) (main-need ?need)
                   (activities $?acts&:(<= (length$ ?acts) 4)))
  ?o-act <- (object (is-a Actividad)
                    (name ?act-name&:(not (member$ ?act-name ?acts)))
                    (llena $?needs&:(member$ ?need ?needs)))
 =>

  ; (printout t ">>" crlf)
  ; (printout t "found a day " ?o-day " with activities " ?acts " and need " ?need crlf)
  ; (printout t "found an activity " ?o-act " with needs " ?needs crlf)
  (slot-insert$ ?o-day activities 1 ?act-name)
)

(defrule specify-recom:test-print "Ver la planificación"
  (declare (salience -100))
  ?week <- (object (name [AbstractWeek]))
 =>
  (printout t "=== Planificacion de la semana ===" crlf)
  (foreach ?day (send ?week get-days)
    (printout t "> Dia " ?day-index " ["
              (send (send ?day get-main-need) get-necesidad)
              "]" crlf)
      ; (printout t "actividades " (send ?day get-activities) crlf)
      (bind ?acts (send ?day get-activities))
      (foreach ?act ?acts
       (printout t "Actividad : " (send ?act get-actividad) crlf)
      )
    )
)