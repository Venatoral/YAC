(define main
  (lambda ()
    (funcall putInt (funcall fibo 40))))

(define fibo
  (lambda (n)
    (if (< n 2)
        n
	(+ (funcall fibo (- n 1))
	   (funcall fibo (- n 2))))))
