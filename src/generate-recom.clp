; modulo de generacion del planning abstracto
(defrule generate-recom:init "Crea objetos de necesidad"
 =>
  (do-for-all-instances ((?need Necesidad)) TRUE
    ;(printout t "Necesidad " (send ?need get-necesidad) crlf)
    (assert (objective (need ?need) (priority (random 0 3)))) ; TODO remove random
    )
  )

; cambios de prioridades en los objetivos

; generacion de los dias en base a los objetivos
(defrule generate-recom:generate-abstract-week "Crea un planning segun las prioridades"
  (days ?d)
  (not (object (name [AbstractWeek])))
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