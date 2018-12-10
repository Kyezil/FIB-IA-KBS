;;;; modulo de generacion del planning abstracto
(deffacts generate-recom::INIT-NEED "Prioridades iniciales de las necesidades"
  (init-need "resistencia" 40)
  (init-need "fuerza" 10)
  (init-need "equilibrio" 5)
  (init-need "coordinacion" 2)
  (init-need "flexibilidad" 2))


;;; Define el numero de dias
(defrule generate-recom::days1 "Define el #dias"
  (not (days ?))
  (borg walk-1h 1)
 =>
  (assert (days 7))
)
(defrule generate-recom::days2 "Define el #dias"
  (not (days ?))
  (borg walk-1h 2)
 =>
  (assert (days 6))
)
(defrule generate-recom::days3 "Define el #dias"
  (not (days ?))
  (borg walk-1h 3)
 =>
  (assert (days 5))
)
(defrule generate-recom::days4 "Define el #dias"
  (not (days ?))
  (borg walk-1h 4|5)
 =>
  (assert (days 4))
)
(defrule generate-recom::days5 "Define el #dias"
  (not (days ?))
  (borg walk-1h 6|7|8|9|10)
 =>
  (assert (days 3))
)

(defrule specify-recom::clamp-day-range "Asegura generar entre 3 y 7 dias"
  (declare (salience -1)) ; lower than day changing but higher
  ?o <- (days ?d&:(or (> ?d 7) (< ?d 0)))
 =>
  (retract ?o)
  (assert (days (max 0 (min 7 ?d))))
)


;; Define la cantidad de esfuerzo
(defrule generate-recom::work1
  (declare (salience -5))
  (days 3)
 =>
  (assert (work 70))
)
(defrule generate-recom::work2
  (declare (salience -5))
  (days 4)
 =>
  (assert (work 105))
)
(defrule generate-recom::work3
  (declare (salience -5))
  (days 5)
 =>
  (assert (work 140))
)
(defrule generate-recom::work4
  (declare (salience -5))
  (days 6)
 =>
  (assert (work 210))
)
(defrule generate-recom::work5
  (declare (salience -5))
  (days 7)
 =>
  (assert (work 280))
)
(defrule generate-recom::YEAH
  (work ?w)
 =>
  (printout t "FOUND WORK " ?w crlf)
)

;; Trata condiciones del anciano
(defrule generate-recom::dependency1 "Trata la dependencia elevada"
  (object (name [Usuario]) (dependencia dependiente_moderado))
 =>
  (assert (add-day -1))
)
(defrule generate-recom::dependency2 "Trata la dependencia elevada"
  (object (name [Usuario]) (dependencia dependiente_severo))
 =>
  (assert (add-day -2))
)
(defrule generate-recom::dependency3 "Trata la dependencia elevada"
  (object (name [Usuario]) (dependencia gran_dependencia))
 =>
  (assert (add-day -3))
)


(defrule generate-recom::add-day "Cambia el numero de dias"
  ?add-o <- (add-day ?inc)
  ?days-o <- (days ?d)
 =>
  (retract ?days-o)
  (retract ?add-o)
  (assert (days (+ ?d ?inc)))
)

;;; Cambios de prioridades en los objetivos
(defrule generate-recom::init-need "Crea objetos de necesidad"
  (object (is-a Necesidad) (name ?need) (necesidad ?need-name))
  ?in-o <- (init-need ?need-name ?val)
 =>
  (assert (objective (need ?need) (priority ?val)))
  (retract ?in-o)
)

(defrule generate-recom::change-priority "Cambia la prioridad de un objectivo"
  ?n <- (change-priority ?need-name ?val)
  (object (is-a Necesidad) (name ?need) (necesidad ?need-name))
  ?o <- (objective (need ?need) (priority ?p))
 =>
  (modify ?o (priority (+ ?p ?val)))
  (retract ?n)
)

(defrule generate-recom::obesity "Trata la obesidad"
  ?oo <- (obesity)
 =>
  (retract ?oo)
  (assert (add-day 1))
  (assert (change-priority "resistencia" 10))
)
(defrule generate-recom::health-heart
  (heart-problems)
 =>
  (assert (change-priority "resistencia" 10))
  (assert (change-priority "fuerza" 10))
)
(defrule generate-recom::health-incontinency
  (incontinency)
 =>
  (assert (change-priority "equilibrio" 35))
)
(defrule generate-recom::health-osteoroposis
  (osteoroposis)
 =>
  (assert (change-priority "equilibrio" 25))
  (assert (change-priority "flexibilidad" 25))
)
(defrule generate-recom::health-falling-fear
  (falling-fear)
 =>
  (assert (change-priority "equilibrio" 35))
  (assert (change-priority "coordinacion" 20))
)
(defrule generate-recom::health-fas-fallen
  (has-fallen)
 =>
  (assert (change-priority "equilibrio" 25))
  (assert (change-priority "resitencia" 5))
)

;;; Generacion de dias en base a los objetivos
(defrule generate-recom::generate-abstract-week "Crea un planning segun las prioridades"
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
  ; (printout t "total probability " ?total crlf)
  ; create a recom-week with d days with random need
  (bind ?week (make-instance AbstractWeek of AWeek))
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

(defrule generate-recom::done "Pasa a la fase de concretizacion del planning"
  (declare (salience -100))
 =>
  (focus specify-recom)
)