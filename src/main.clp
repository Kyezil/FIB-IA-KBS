; ---------------------------------------------
; Practica 2: Sistema basado en el conocimiento
; ---------------------------------------------

; -- carga de la ontologia --
; classes
(load "protege/clips/ont.pont")

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
  (import identify-user ?ALL)
  (export ?ALL))
; modulo de seleccion de actividades
(defmodule specify-recom
  (import MAIN ?ALL)
  (import identify-user ?ALL)
  (export ?ALL))
; modulo de presentacion de la solucion
(defmodule present
  (import MAIN ?ALL)
  (import specify-recom ?ALL)
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
  )
; -- una semana de recomendacion
(defclass AWeek
  (is-a USER)
  (multislot days)
)
;; -- una actividad para valorar
(deftemplate activity
  (slot act (type INSTANCE) (allowed-classes Actividad))
  (slot value (type INTEGER) (default 0))
)
;; -- un dia para crear la recomendacion
(deftemplate day
  (slot aday (type INSTANCE) (allowed-classes ADay))
  (slot total-time (type INTEGER) (default 0))
  (slot total-work (type FLOAT) (default 0.0))
)
;; -- un ejercicio en un dia
(deftemplate day-slot
  (slot used (type SYMBOL) ; used in recom
        (allowed-values TRUE FALSE) (default TRUE))
  (slot day (type INSTANCE); linked to day
        (allowed-classes ADay))
  (slot position (type INTEGER)); relative position in day
  (slot activity (type INSTANCE); activity
        (allowed-classes Actividad))
  (slot duration (type INTEGER) (default 0))
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

(defrule MAIN::sort-duracion "Ordena la duracion de los ejercicios"
  (declare (salience 1000))
  (exists (object (is-a Actividad)))
 =>
  (do-for-all-instances ((?x Actividad)) TRUE
    (send ?x put-duracion (sort > ?x:duracion))
  )
)

; start program
(reset)
; instancias
(load-instances "protege/clips/ont.pins")
; (run)
