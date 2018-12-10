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
  (declare (salience -10))
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
  (declare (salience -10))
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
  (declare (salience -100))
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

; (defrule specify-recom::select-activities "Selecciona actividades en la lista según la valoración"
; )
; (defrule specify-recom::add-activities "Assigna actividades en orden a los dias"
;   ?d-f <- (day (aday ?aday) (total-time ?tt&:(< ?tt 90))) ; max 1h30
;   (object (is-a ADay) (name ?aday) (main-need ?need) (activities $?acts))
;  =>
;   ; (printout t "day is " ?aday " with need " ?need crlf)
;   ;; find available activities
;   (bind ?rem-time (- 90 ?tt))
;   (bind ?available-acts
;     (find-all-instances ((?ins Actividad))
;                         (and (member$ ?need ?ins:llena)
;                              (not (member$ ?ins ?acts))
;                               (<= (nth 1 ?ins:duracion) ?rem-time))))
;   ;; (printout t ?available-acts)
;   ;; pick one at random
;   (bind ?n (length$ ?available-acts))
;   (if (> ?n 0)

;    then ; necessary if there is not enough activities
;      (bind ?i (random 1 ?n))
;      (bind ?act (nth ?i ?available-acts))
; ;  (printout t "selected activity is ")
; ;  (send ?act print)
;      (slot-insert$ (IA ?aday) activities 1 ?act)
;      (modify ?d-f (total-time (+ ?tt (nth 1 (send ?act get-duracion)))))
;   )
; )

(defrule specify-recom::done "Pasa a la presentación de la solución"
  (declare (salience -100))
  =>
  (focus present)
)
;;

