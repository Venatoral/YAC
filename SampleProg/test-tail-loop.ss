(define main
  (lambda ()
    (funcall putInt (funcall loopSum 100000000 0))))

(define loopSum
  (lambda (n s)
    (if (< 1 n)
        (funcall/t loopSum (- n 1) (+ n s))
	s)))
