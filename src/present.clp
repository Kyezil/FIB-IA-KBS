(deffunction pos-dec (?x ?y)
  (> (fact-slot-value ?x position) (fact-slot-value ?y position)))

(deffunction print-description (?s)
  (bind ?n (str-length ?s))
  (bind ?i (str-index "." ?s))
  (if (and ?i (< ?i ?n))
   then
     (format t "  %s%n" (sub-string 1 ?i ?s))
     (print-description (sub-string (+ 2 ?i) ?n ?s))
   else
     (format t "  %s%n" ?s)
)
)

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
      (bind ?activity (IA (fact-slot-value ?day-slot activity)))
      (format t "> %s [%dmin]%n"
              (send ?activity get-actividad)
              (fact-slot-value ?day-slot duration))
      (bind ?des (send ?activity get-descripcion))
      (if (!= 0 (str-compare ?des ""))
       then (print-description ?des)
      )
      ; (printout t crlf)
      )
    (printout t crlf)
  )
)