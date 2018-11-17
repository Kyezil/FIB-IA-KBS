(defrule MAIN::test
 (object (is-a Ejercicio) (actividad ?act))
 =>
  (printout t "Found Ejercicio " ?act crlf)
)