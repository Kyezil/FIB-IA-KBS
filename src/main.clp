; ---------------------------------------------
; Practica 2: Sistema basado en el conocimiento
; ---------------------------------------------

; -- carga de la ontologia --
; classes
(load "protege/clips/ont.pont")
; instancias
(load-instances "protege/clips/ont.pins")

; -- declaracion de modulos --
; modulo principal
(defmodule MAIN (export ?ALL))
; modulo de identificacion
(defmodule identify-user
  (import MAIN ?ALL)
  (export ?ALL))
; modulo de generacion de la recomendacion
(defmodule generate-recom
  (import MAIN ?ALL)
  (export ?ALL))
; modulo de seleccion de actividades
(defmodule specify-recom
  (import MAIN ?ALL)
  (export ?ALL))
; modulo de presentacion de la solucion
(defmodule present
  (import MAIN ?ALL)
  (export ?ALL))
; volvemos al modulo MAIN
(focus MAIN)

; -- definicion de objetos
; -- objetivo para el paciente
(deftemplate objective
  (slot need (type INSTANCE) (allowed-classes Necesidad))
  (slot priority (type NUMBER) (default 1))
  )
; -- un dia de recomendacion
(defclass ADay
  (is-a USER)
  (single-slot main-need (type INSTANCE) (allowed-classes Necesidad))
  (multislot activities (type INSTANCE) (allowed-classes Actividad))
)
; -- una semana de recomendacion
(defclass AWeek
  (is-a USER)
  (multislot days)
)

; -- carga de archivos --
(load "utils.clp")
(load "identify-user.clp")
(load "generate-recom.clp")
(load "specify-recom.clp")
(load "present.clp")

; -- regla inicial
(defrule MAIN::start "inicio del sistema"
  (declare (salience 100))
 =>
  (printout t "================================================" crlf
              "===  Sistema de recomendacion de ejercicios  ===" crlf
              "================================================" crlf
              crlf
              "Bienvenido al sistema de generación de un programa de ejercicios para personas mayores!" crlf
              "A continuación se le hará una serie de preguntas para poder recomendarle más adecuadamente." crlf crlf
  )
  (focus identify-user)
)
; start program
; (run)
