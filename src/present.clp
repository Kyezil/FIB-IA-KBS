(deffunction pos-dec (?x ?y)
  (> (fact-slot-value ?x position) (fact-slot-value ?y position)))

(deffunction print-description (?s)
  (bind ?n (str-length ?s))
  (bind ?i (str-index "." ?s))
  (if (and ?i (< ?i ?n))
   then
     (format t "    %s%n" (sub-string 1 ?i ?s))
     (print-description (sub-string (+ 2 ?i) ?n ?s))
   else
     (format t "    %s%n" ?s)
)
)

(defrule present::test-print "Ver la planificación"
  (declare (salience -1000))
  (object (name [Usuario]) (nombre ?name))
  ?week <- (object (name [AbstractWeek]))
 =>
  (format t "============   Planificacion de la semana para %s  ==========%n" ?name)
  (foreach ?wday (send ?week get-days)
    (bind ?day-fact (nth 1 (find-fact ((?f day)) (eq ?f:aday (instance-name ?wday)))))
    (format t "-- Dia %d [%s] (tiempo total %dmin, trabajo realizado %.2f) --%n"
            ?wday-index (send (IA (send ?wday get-main-need)) get-necesidad)
            (fact-slot-value ?day-fact total-time) (fact-slot-value ?day-fact total-work))
      ; get all used day-slots in day ?day
    (bind ?day-slots (find-all-facts ((?f day-slot)) (and (eq ?f:used TRUE)
                                                          (eq ?f:day (instance-name ?wday)))))
    ; (printout t "found day slots " ?day-slots crlf)
    (bind ?day-slots (sort pos-dec ?day-slots))
    (foreach ?day-slot ?day-slots
      (bind ?activity (IA (fact-slot-value ?day-slot activity)))
      (format t " > %s [%dmin]%n"
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