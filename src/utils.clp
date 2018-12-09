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