; ======= FUNCIONES GENERALES ======
; -- preguntas con conjunto de valores permitidos
(deffunction pregunta (?pregunta $?valores-permitidos)
  (progn$
    (?var ?valores-permitidos)
  (lowcase ?var))
  (format t "¿%s? (%s) " ?pregunta (implode$ ?valores-permitidos))
  (bind ?respuesta (read))
  (while (not (member (lowcase ?respuesta) ?valores-permitidos)) do
    (format t "¿%s? (%s) " ?pregunta (implode$ ?valores-permitidos))
    (bind ?respuesta (read))
  )
  ?respuesta
  )

; -- pregunta con valor numerico en un rango
(deffunction pregunta-numerica (?pregunta ?rangini ?rangfi)
  (format t "¿%s? [%d, %d] " ?pregunta ?rangini ?rangfi)
  (bind ?respuesta (read))
  (while (not (and (>= ?respuesta ?rangini) (<= ?respuesta ?rangfi))) do
    (format t "¿%s? [%d, %d] " ?pregunta ?rangini ?rangfi)
    (bind ?respuesta (read))
  )
  ?respuesta
)

; -- pregunta general
(deffunction pregunta-general (?pregunta)
  (format t "¿%s? " ?pregunta)
  (bind ?respuesta (read))
  ?respuesta
)

; -- pregunta binaria
(deffunction si-o-no-p (?pregunta)
  (bind ?respuesta (pregunta ?pregunta si no s n))
  (if (or (eq (lowcase ?respuesta) si) (eq (lowcase ?respuesta) s))
    then TRUE
    else FALSE
  )
  )

(deffunction IA (?name)
  (instance-address * ?name))

(deffunction sigmoid (?x)
  (/ 1 (+ 1 (exp (- 0 (/ ?x 5))))))

; (select-random-by (a b d) (2 2 1))
; returns a with probability 2/5
; returns b with probability 2/5
; returns c with porbability 1/5
(deffunction select-random-by (?col ?val)
  (bind ?total (+ 0 (expand$ ?val)))
  (bind ?r (random 1 ?total))
  ; find element with value at ?r
  (bind ?p 0)
  (foreach ?v ?val
    (bind ?p (+ ?p ?v))
    (if (>= ?p ?r) then (return (nth ?v-index ?col)))))
