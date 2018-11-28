;;;; modulo de generacion del planning abstracto

;;; Define el numero de dias
(defrule generate-recom:days1 "Define el #dias"
  (not (days ?))
  (borg walk-1h 1)
 =>
  (assert (days 7))
)
(defrule generate-recom:days2 "Define el #dias"
  (not (days ?))
  (borg walk-1h 2)
 =>
  (assert (days 6))
)
(defrule generate-recom:days3 "Define el #dias"
  (not (days ?))
  (borg walk-1h 3)
 =>
  (assert (days 5))
)
(defrule generate-recom:days4 "Define el #dias"
  (not (days ?))
  (borg walk-1h 4|5)
 =>
  (assert (days 4))
)
(defrule generate-recom:days5 "Define el #dias"
  (not (days ?))
  (borg walk-1h ?)
 =>
  (assert (days 3))
)

(defrule generate-recom:days-bmi "Aumenta el #dias si obesidad"
  (object (name [Usuario]) (IMC ?bmi&:(> ?bmi 30)))
  ?df <- (days ?d&:(< ?d 7))
  (not (days-bmi)) ; HACK
 =>
  (retract ?df)
  (assert (days-bmi)) ; HACK
  (assert (days (+ ?d 1)))
)

;;; cambios de prioridades en los objetivos
(defrule generate-recom:init-need "Crea objetos de necesidad"
  ?need <- (object (is-a Necesidad))
 =>
  (assert (objective (need ?need)))
)

(defrule generate-recom:need-priority "Cambia la prioridad de un objectivo"
  ?n <- (need-extra ?need)
  ?o <- (objective (need ?need) (priority ?p))
 =>
  (retract ?n)
  (modify ?o (priority (+ ?p 2)))
)


; generacion de los dias en base a los objetivos
(defrule generate-recom:generate-abstract-week "Crea un planning segun las prioridades"
  (declare (salience -10)) ; IMPORTANT, lower than day changing
  (days ?d)
  (not (object (name [AbstractWeek])))
  (objective (priority ?o&:(> ?o 0)))
 =>
  (bind ?objs (find-all-facts ((?o objective )) (> ?o:priority 0)))
  ; (printout t "possible objectives are " ?objs crlf)
  ; get total need probability
  (bind ?total 0)
  (foreach ?obj ?objs
    (bind ?total (+ ?total (fact-slot-value ?obj priority)))
    )
  (printout t "total probability " ?total crlf)
  ; create a recom-week with d days with random need
  (bind ?week (make-instance [AbstractWeek] of AWeek))
  (loop-for-count (?i 1 ?d) do
                  ; random objective
                  (bind ?r (random 1 ?total))
                  ; get the random need
                  (bind ?p 0)
                  (bind ?need nil)
                  (foreach ?obj ?objs
                    (bind ?need (fact-slot-value ?obj need))
                    (bind ?p (+ ?p (fact-slot-value ?obj priority)))
                    (if (> ?p ?r) then (break))
                    )
                  ; (printout t "my need is " ?need crlf)
                  (slot-insert$ ?week days 1
                                (make-instance (gensym) of ADay (main-need ?need)))
                  )
  )

(defrule generate-recom:display "Visualiza los dias del planning abstracto"
  ?week <- (object (name [AbstractWeek]))
 =>
  (printout t "=== Planificacion de la semana ===" crlf)
  (foreach ?day (send ?week get-days)
    (printout t "> Dia " ?day-index " de "
              (send (send ?day get-main-need) get-necesidad)
              crlf)
    )
)