(deffunction pos-dec (?x ?y)
  (> (fact-slot-value ?x position) (fact-slot-value ?y position)))

(defrule present::test-print "Ver la planificación"
  (declare (salience -1000))
  ?week <- (object (name [AbstractWeek]))
 =>
  (printout t "=== Planificacion de la semana ===" crlf)
  (foreach ?day (send ?week get-days)
    (printout t "-- Dia " ?day-index " ["
              (send (IA (send ?day get-main-need)) get-necesidad)
              "] --" crlf)
      ; get all used day-slots in day ?day
    (bind ?day-slots (find-all-facts ((?f day-slot)) (and (eq ?f:used TRUE)
                                                          (eq ?f:day (instance-name ?day)))))
    ; (printout t "found day slots " ?day-slots crlf)
    (bind ?day-slots (sort pos-dec ?day-slots))
    (foreach ?day-slot ?day-slots
      (format t "> %s [%dmin]%n"
              (send (IA (fact-slot-value ?day-slot activity)) get-actividad)
              (fact-slot-value ?day-slot duration))
      )
    (printout t crlf)
  )
)