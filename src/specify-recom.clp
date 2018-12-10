; modulo de concretizacion de los ejercicios en base a un planning abstracto
(deffacts specify-recom::INIT-VALUE
  (change-value class caminar 10))

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
      (modify ?act (act ?act:act) (value (+ ?act:value ?val)))
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
  (assert (change-value class relajacion 20))
)
;; Depresion =>
;;      -20 a los solitarios
;;      -10 a los con MET > 6.5
(defrule specify-recom::health-depression1
  (depression)
 =>
  (do-for-all-instances ((?ex Actividad)) (eq ?ex:solitaria TRUE)
    ; (printout t "found activity with need " ?need "> " ?ex crlf)
    (do-for-fact ((?act activity)) (eq ?act:act (instance-name ?ex))
      ; (printout t  "found activity fact" ?act crlf)
      (assert (activity (act ?act:act) (value (- ?act:value 20))))
      (retract ?act)
    )
   )
)
(defrule specify-recom::health-depression2
  (depression)
 =>
  (do-for-all-instances ((?ex Actividad)) (> ?ex:MET 6.5)
    ; (printout t "found activity with need " ?need "> " ?ex crlf)
    (do-for-fact ((?act activity)) (eq ?act:act (instance-name ?ex))
      ; (printout t  "found activity fact" ?act crlf)
      (assert (activity (act ?act:act) (value (- ?act:value 10))))
      (retract ?act)
    )
   )
)

(defrule specify-recom::high-dependence "Elimina ejercicios solitarios si dependencia"
  (object (name [Usuario]) (dependencia ~independiente&~undefined))
  (object (is-a Actividad) (name ?ex) (solitaria TRUE))
  ?a-o <- (activity (act ?ex))
 =>
  ; (printout t "Found solitary activity" ?ex crlf)
  (retract ?a-o)
)

(deffunction intensity-up (?a ?b)
  (> (send (IA (fact-slot-value ?a act)) get-MET)
     (send (IA (fact-slot-value ?b act)) get-MET)))
(deffunction intensity-down (?a ?b)
  (not (intensity-up ?a ?b)))

;;; Creacion del planning concreto
(defrule specify-recom::init-day-slots "Crea todos los slots de dia"
  (declare (salience -10))
  (day (aday ?aday))
  (object (is-a ADay) (name ?aday) (main-need ?need))
 =>
  ;; split all activities in two sets
  (bind ?set1 (create$)) ; increasing intensity
  (bind ?set2 (create$)) ; decreasing intensity
  (do-for-all-facts ((?f activity))
      (member$ ?need (send (IA ?f:act) get-llena))
    (if (= 1 (random 1 2))
     then (bind ?set1 (insert$ ?set1 1 ?f))
     else (bind ?set2 (insert$ ?set2 1 ?f)))
    )
  ; (printout t "TWO SETS" crlf ?set1 crlf ?set2 crlf crlf)
  ;; sort one < the other > by intensity
  (bind ?set1 (sort intensity-up ?set1))
  (bind ?set2 (sort intensity-down ?set2))
  ; (printout t "SORTED SETS" crlf)
  ; (foreach ?a ?set1
  ;   (printout t (send (IA (fact-slot-value ?a act)) get-MET) ","))
  ; (printout t crlf "SET 2" crlf)
  ; (foreach ?a ?set2
  ;   (printout t (send (IA (fact-slot-value ?a act)) get-MET) ","))
  ; (printout t crlf)
  ;; merge the sets
  (bind ?full-set (insert$ ?set2 1 ?set1))
  (foreach ?act ?full-set
    (assert (day-slot (day ?aday)
                      (position ?act-index)
                      (activity (fact-slot-value ?act act))))
  )
)


(deffunction specify-recom::get-activity-value (?activity)
  ; (printout t "GET ACTIVITY VALUE of " ?activity crlf)
  (fact-slot-value (nth 1 (find-fact ((?act activity)) (eq ?act:act ?activity))) value))

(deffunction specify-recom::get-value-prob (?val)
  (round (* (sigmoid ?val) 100)))

(defrule specify-recom::select-activities "Selecciona actividades en la lista según la valoración"
  (declare (salience -20))
  (work ?max-w)
  (object (is-a ADay) (name ?aday))
  ?day-o <- (day (aday ?aday)
       (total-time ?tt&:(< ?tt 90))
       (total-work ?tw))
  (test (or (< ?tt 30) (< ?tw ?max-w))) ; if tt >= 30 then tw < max-w
 =>
 ; find all unused day-slot in ?aday
  (bind ?day-slots (find-all-facts ((?f day-slot)) (and (eq ?f:used FALSE)
                                                       (eq ?f:day ?aday))))
 ; (printout t "remaining unused day-slots for " ?aday " are " ?day-slots crlf)
 ; select one unused day-slot at random by value
  (bind ?n (+ 1 (length$ ?day-slots)))
  (bind ?day-slots-prob (create$))
  (foreach ?day-slot ?day-slots
    (bind ?day-slots-prob
      (insert$ ?day-slots-prob ?n (get-value-prob (get-activity-value (fact-slot-value ?day-slot activity))))))
  ; (printout t " my day slots " crlf ?day-slots " have probability " crlf ?day-slots-prob crlf)
  (bind ?selected-day-slot (select-random-by ?day-slots ?day-slots-prob))
  (bind ?selected-activity (IA (fact-slot-value ?selected-day-slot activity)))
  ;; use day-slot
  ; select a possible duration
  (bind ?possible-durations (create$))
  (bind ?activity-MET (send ?selected-activity get-MET))
  (foreach ?dur (send ?selected-activity get-duracion)
    (if (and (< (+ ?dur ?tt) 90) (or (< ?tt 30) (< (+ ?tw (* ?dur ?activity-MET)) ?max-w)))
     then (bind ?possible-durations (insert$ ?possible-durations 1 ?dur))))

  (bind ?n-durations (length$ ?possible-durations))
  (if (> ?n-durations 0)
   then
     (bind ?duration (nth (random 1 ?n-durations) ?possible-durations))
     ; (printout t " I selected a day ! " ?selected-day-slot " with duration " ?duration crlf)
  ; (printout t "work amount is " ?work crlf)
     (modify ?day-o (total-time (+ ?tt ?duration)) (total-work (+ ?tw (* ?duration ?activity-MET))))
     (modify ?selected-day-slot (used TRUE) (duration ?duration))
   )
)

(defrule specify-recom::done "Pasa a la presentación de la solución"
  (declare (salience -100))
  =>
  (focus present)
)
;;

