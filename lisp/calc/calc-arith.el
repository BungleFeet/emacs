;;; calc-arith.el --- arithmetic functions for Calc

;; Copyright (C) 1990, 1991, 1992, 1993, 2001 Free Software Foundation, Inc.

;; Author: David Gillespie <daveg@synaptics.com>
;; Maintainer: Jay Belanger <belanger@truman.edu>

;; This file is part of GNU Emacs.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY.  No author or distributor
;; accepts responsibility to anyone for the consequences of using it
;; or for whether it serves any particular purpose or works at all,
;; unless he says so in writing.  Refer to the GNU Emacs General Public
;; License for full details.

;; Everyone is granted permission to copy, modify and redistribute
;; GNU Emacs, but only under the conditions described in the
;; GNU Emacs General Public License.   A copy of this license is
;; supposed to have been given to you along with GNU Emacs so you
;; can know your rights and responsibilities.  It should be in a
;; file named COPYING.  Among other things, the copyright notice
;; and this notice must be preserved on all copies.

;;; Commentary:

;;; Code:

;; This file is autoloaded from calc-ext.el.

(require 'calc-ext)
(require 'calc-macs)

;;; The following lists are not exhaustive.
(defvar math-scalar-functions '(calcFunc-det
				calcFunc-cnorm calcFunc-rnorm
				calcFunc-vlen calcFunc-vcount
				calcFunc-vsum calcFunc-vprod
				calcFunc-vmin calcFunc-vmax))

(defvar math-nonscalar-functions '(vec calcFunc-idn calcFunc-diag
				       calcFunc-cvec calcFunc-index
				       calcFunc-trn
				       | calcFunc-append
				       calcFunc-cons calcFunc-rcons
				       calcFunc-tail calcFunc-rhead))

(defvar math-scalar-if-args-functions '(+ - * / neg))

(defvar math-real-functions '(calcFunc-arg
			      calcFunc-re calcFunc-im
			      calcFunc-floor calcFunc-ceil
			      calcFunc-trunc calcFunc-round
			      calcFunc-rounde calcFunc-roundu
			      calcFunc-ffloor calcFunc-fceil
			      calcFunc-ftrunc calcFunc-fround
			      calcFunc-frounde calcFunc-froundu))

(defvar math-positive-functions '())

(defvar math-nonnegative-functions '(calcFunc-cnorm calcFunc-rnorm
				     calcFunc-vlen calcFunc-vcount))

(defvar math-real-scalar-functions '(% calcFunc-idiv calcFunc-abs
				       calcFunc-choose calcFunc-perm
				       calcFunc-eq calcFunc-neq
				       calcFunc-lt calcFunc-gt
				       calcFunc-leq calcFunc-geq
				       calcFunc-lnot
				       calcFunc-max calcFunc-min))

(defvar math-real-if-arg-functions '(calcFunc-sin calcFunc-cos
				     calcFunc-tan calcFunc-arctan
				     calcFunc-sinh calcFunc-cosh
				     calcFunc-tanh calcFunc-exp
				     calcFunc-gamma calcFunc-fact))

(defvar math-integer-functions '(calcFunc-idiv
				 calcFunc-isqrt calcFunc-ilog
				 calcFunc-vlen calcFunc-vcount))

(defvar math-num-integer-functions '())

(defvar math-rounding-functions '(calcFunc-floor
				  calcFunc-ceil
				  calcFunc-round calcFunc-trunc
				  calcFunc-rounde calcFunc-roundu))

(defvar math-float-rounding-functions '(calcFunc-ffloor
					calcFunc-fceil
					calcFunc-fround calcFunc-ftrunc
					calcFunc-frounde calcFunc-froundu))

(defvar math-integer-if-args-functions '(+ - * % neg calcFunc-abs
					   calcFunc-min calcFunc-max
					   calcFunc-choose calcFunc-perm))


;;; Arithmetic.

(defun calc-min (arg)
  (interactive "P")
  (calc-slow-wrapper
   (calc-binary-op "min" 'calcFunc-min arg '(var inf var-inf))))

(defun calc-max (arg)
  (interactive "P")
  (calc-slow-wrapper
   (calc-binary-op "max" 'calcFunc-max arg '(neg (var inf var-inf)))))

(defun calc-abs (arg)
  (interactive "P")
  (calc-slow-wrapper
   (calc-unary-op "abs" 'calcFunc-abs arg)))


(defun calc-idiv (arg)
  (interactive "P")
  (calc-slow-wrapper
   (calc-binary-op "\\" 'calcFunc-idiv arg 1)))


(defun calc-floor (arg)
  (interactive "P")
  (calc-slow-wrapper
   (if (calc-is-inverse)
       (if (calc-is-hyperbolic)
	   (calc-unary-op "ceil" 'calcFunc-fceil arg)
	 (calc-unary-op "ceil" 'calcFunc-ceil arg))
     (if (calc-is-hyperbolic)
	 (calc-unary-op "flor" 'calcFunc-ffloor arg)
       (calc-unary-op "flor" 'calcFunc-floor arg)))))

(defun calc-ceiling (arg)
  (interactive "P")
  (calc-invert-func)
  (calc-floor arg))

(defun calc-round (arg)
  (interactive "P")
  (calc-slow-wrapper
   (if (calc-is-inverse)
       (if (calc-is-hyperbolic)
	   (calc-unary-op "trnc" 'calcFunc-ftrunc arg)
	 (calc-unary-op "trnc" 'calcFunc-trunc arg))
     (if (calc-is-hyperbolic)
	 (calc-unary-op "rond" 'calcFunc-fround arg)
       (calc-unary-op "rond" 'calcFunc-round arg)))))

(defun calc-trunc (arg)
  (interactive "P")
  (calc-invert-func)
  (calc-round arg))

(defun calc-mant-part (arg)
  (interactive "P")
  (calc-slow-wrapper
   (calc-unary-op "mant" 'calcFunc-mant arg)))

(defun calc-xpon-part (arg)
  (interactive "P")
  (calc-slow-wrapper
   (calc-unary-op "xpon" 'calcFunc-xpon arg)))

(defun calc-scale-float (arg)
  (interactive "P")
  (calc-slow-wrapper
   (calc-binary-op "scal" 'calcFunc-scf arg)))

(defun calc-abssqr (arg)
  (interactive "P")
  (calc-slow-wrapper
   (calc-unary-op "absq" 'calcFunc-abssqr arg)))

(defun calc-sign (arg)
  (interactive "P")
  (calc-slow-wrapper
   (calc-unary-op "sign" 'calcFunc-sign arg)))

(defun calc-increment (arg)
  (interactive "p")
  (calc-wrapper
   (calc-enter-result 1 "incr" (list 'calcFunc-incr (calc-top-n 1) arg))))

(defun calc-decrement (arg)
  (interactive "p")
  (calc-wrapper
   (calc-enter-result 1 "decr" (list 'calcFunc-decr (calc-top-n 1) arg))))


(defun math-abs-approx (a)
  (cond ((Math-negp a)
	 (math-neg a))
	((Math-anglep a)
	 a)
	((eq (car a) 'cplx)
	 (math-add (math-abs (nth 1 a)) (math-abs (nth 2 a))))
	((eq (car a) 'polar)
	 (nth 1 a))
	((eq (car a) 'sdev)
	 (math-abs-approx (nth 1 a)))
	((eq (car a) 'intv)
	 (math-max (math-abs (nth 2 a)) (math-abs (nth 3 a))))
	((eq (car a) 'date)
	 a)
	((eq (car a) 'vec)
	 (math-reduce-vec 'math-add-abs-approx a))
	((eq (car a) 'calcFunc-abs)
	 (car a))
	(t a)))

(defun math-add-abs-approx (a b)
  (math-add (math-abs-approx a) (math-abs-approx b)))


;;;; Declarations.

(defvar math-decls-cache-tag nil)
(defvar math-decls-cache nil)
(defvar math-decls-all nil)

;;; Math-decls-cache is an a-list where each entry is a list of the form:
;;;   (VAR TYPES RANGE)
;;; where VAR is a variable name (with var- prefix) or function name;
;;;       TYPES is a list of type symbols (any, int, frac, ...)
;;;	  RANGE is a sorted vector of intervals describing the range.

(defvar math-super-types
  '((int numint rat real number)
    (numint real number)
    (frac rat real number)
    (rat real number)
    (float real number)
    (real number)
    (number)
    (scalar)
    (matrix vector)
    (vector)
    (const)))

(defun math-setup-declarations ()
  (or (eq math-decls-cache-tag (calc-var-value 'var-Decls))
      (let ((p (calc-var-value 'var-Decls))
	    vec type range)
	(setq math-decls-cache-tag p
	      math-decls-cache nil)
	(and (eq (car-safe p) 'vec)
	     (while (setq p (cdr p))
	       (and (eq (car-safe (car p)) 'vec)
		    (setq vec (nth 2 (car p)))
		    (condition-case err
			(let ((v (nth 1 (car p))))
			  (setq type nil range nil)
			  (or (eq (car-safe vec) 'vec)
			      (setq vec (list 'vec vec)))
			  (while (and (setq vec (cdr vec))
				      (not (Math-objectp (car vec))))
			    (and (eq (car-safe (car vec)) 'var)
				 (let ((st (assq (nth 1 (car vec))
						 math-super-types)))
				   (cond (st (setq type (append type st)))
					 ((eq (nth 1 (car vec)) 'pos)
					  (setq type (append type
							     '(real number))
						range
						'(intv 1 0 (var inf var-inf))))
					 ((eq (nth 1 (car vec)) 'nonneg)
					  (setq type (append type
							     '(real number))
						range
						'(intv 3 0
						       (var inf var-inf))))))))
			  (if vec
			      (setq type (append type '(real number))
				    range (math-prepare-set (cons 'vec vec))))
			  (setq type (list type range))
			  (or (eq (car-safe v) 'vec)
			      (setq v (list 'vec v)))
			  (while (setq v (cdr v))
			    (if (or (eq (car-safe (car v)) 'var)
				    (not (Math-primp (car v))))
				(setq math-decls-cache
				      (cons (cons (if (eq (car (car v)) 'var)
						      (nth 2 (car v))
						    (car (car v)))
						  type)
					    math-decls-cache)))))
		      (error nil)))))
	(setq math-decls-all (assq 'var-All math-decls-cache)))))

(defun math-known-scalarp (a &optional assume-scalar)
  (math-setup-declarations)
  (if (if calc-matrix-mode
	  (eq calc-matrix-mode 'scalar)
	assume-scalar)
      (not (math-check-known-matrixp a))
    (math-check-known-scalarp a)))

(defun math-known-matrixp (a)
  (and (not (Math-scalarp a))
       (not (math-known-scalarp a t))))

;;; Try to prove that A is a scalar (i.e., a non-vector).
(defun math-check-known-scalarp (a)
  (cond ((Math-objectp a) t)
	((memq (car a) math-scalar-functions)
	 t)
	((memq (car a) math-real-scalar-functions)
	 t)
	((memq (car a) math-scalar-if-args-functions)
	 (while (and (setq a (cdr a))
		     (math-check-known-scalarp (car a))))
	 (null a))
	((eq (car a) '^)
	 (math-check-known-scalarp (nth 1 a)))
	((math-const-var a) t)
	(t
	 (let ((decl (if (eq (car a) 'var)
			 (or (assq (nth 2 a) math-decls-cache)
			     math-decls-all)
		       (assq (car a) math-decls-cache))))
	   (memq 'scalar (nth 1 decl))))))

;;; Try to prove that A is *not* a scalar.
(defun math-check-known-matrixp (a)
  (cond ((Math-objectp a) nil)
	((memq (car a) math-nonscalar-functions)
	 t)
	((memq (car a) math-scalar-if-args-functions)
	 (while (and (setq a (cdr a))
		     (not (math-check-known-matrixp (car a)))))
	 a)
	((eq (car a) '^)
	 (math-check-known-matrixp (nth 1 a)))
	((math-const-var a) nil)
	(t
	 (let ((decl (if (eq (car a) 'var)
			 (or (assq (nth 2 a) math-decls-cache)
			     math-decls-all)
		       (assq (car a) math-decls-cache))))
	   (memq 'vector (nth 1 decl))))))


;;; Try to prove that A is a real (i.e., not complex).
(defun math-known-realp (a)
  (< (math-possible-signs a) 8))

;;; Try to prove that A is real and positive.
(defun math-known-posp (a)
  (eq (math-possible-signs a) 4))

;;; Try to prove that A is real and negative.
(defun math-known-negp (a)
  (eq (math-possible-signs a) 1))

;;; Try to prove that A is real and nonnegative.
(defun math-known-nonnegp (a)
  (memq (math-possible-signs a) '(2 4 6)))

;;; Try to prove that A is real and nonpositive.
(defun math-known-nonposp (a)
  (memq (math-possible-signs a) '(1 2 3)))

;;; Try to prove that A is nonzero.
(defun math-known-nonzerop (a)
  (memq (math-possible-signs a) '(1 4 5 8 9 12 13)))

;;; Return true if A is negative, or looks negative but we don't know.
(defun math-guess-if-neg (a)
  (let ((sgn (math-possible-signs a)))
    (if (memq sgn '(1 3))
	t
      (if (memq sgn '(2 4 6))
	  nil
	(math-looks-negp a)))))

;;; Find the possible signs of A, assuming A is a number of some kind.
;;; Returns an integer with bits:  1  may be negative,
;;;				   2  may be zero,
;;;				   4  may be positive,
;;;				   8  may be nonreal.

(defun math-possible-signs (a &optional origin)
  (cond ((Math-objectp a)
	 (if origin (setq a (math-sub a origin)))
	 (cond ((Math-posp a) 4)
	       ((Math-negp a) 1)
	       ((Math-zerop a) 2)
	       ((eq (car a) 'intv)
		(cond ((Math-zerop (nth 2 a)) 6)
		      ((Math-zerop (nth 3 a)) 3)
		      (t 7)))
	       ((eq (car a) 'sdev)
		(if (math-known-realp (nth 1 a)) 7 15))
	       (t 8)))
	((memq (car a) '(+ -))
	 (cond ((Math-realp (nth 1 a))
		(if (eq (car a) '-)
		    (math-neg-signs
		     (math-possible-signs (nth 2 a)
					  (if origin
					      (math-add origin (nth 1 a))
					    (nth 1 a))))
		  (math-possible-signs (nth 2 a)
				       (if origin
					   (math-sub origin (nth 1 a))
					 (math-neg (nth 1 a))))))
	       ((Math-realp (nth 2 a))
		(let ((org (if (eq (car a) '-)
			       (nth 2 a)
			     (math-neg (nth 2 a)))))
		  (math-possible-signs (nth 1 a)
				       (if origin
					   (math-add origin org)
					 org))))
	       (t
		(let ((s1 (math-possible-signs (nth 1 a) origin))
		      (s2 (math-possible-signs (nth 2 a))))
		  (if (eq (car a) '-) (setq s2 (math-neg-signs s2)))
		  (cond ((eq s1 s2) s1)
			((eq s1 2) s2)
			((eq s2 2) s1)
			((>= s1 8) 15)
			((>= s2 8) 15)
			((and (eq s1 4) (eq s2 6)) 4)
			((and (eq s2 4) (eq s1 6)) 4)
			((and (eq s1 1) (eq s2 3)) 1)
			((and (eq s2 1) (eq s1 3)) 1)
			(t 7))))))
	((eq (car a) 'neg)
	 (math-neg-signs (math-possible-signs
			  (nth 1 a)
			  (and origin (math-neg origin)))))
	((and origin (Math-zerop origin) (setq origin nil)
	      nil))
	((and (or (eq (car a) '*)
		  (and (eq (car a) '/) origin))
	      (Math-realp (nth 1 a)))
	 (let ((s (if (eq (car a) '*)
		      (if (Math-zerop (nth 1 a))
			  (math-possible-signs 0 origin)
			(math-possible-signs (nth 2 a)
					     (math-div (or origin 0)
						       (nth 1 a))))
		    (math-neg-signs
		     (math-possible-signs (nth 2 a)
					  (math-div (nth 1 a)
						    origin))))))
	   (if (Math-negp (nth 1 a)) (math-neg-signs s) s)))
	((and (memq (car a) '(* /)) (Math-realp (nth 2 a)))
	 (let ((s (math-possible-signs (nth 1 a)
				       (if (eq (car a) '*)
					   (math-mul (or origin 0) (nth 2 a))
					 (math-div (or origin 0) (nth 2 a))))))
	   (if (Math-negp (nth 2 a)) (math-neg-signs s) s)))
	((eq (car a) 'vec)
	 (let ((signs 0))
	   (while (and (setq a (cdr a)) (< signs 15))
	     (setq signs (logior signs (math-possible-signs
					(car a) origin))))
	   signs))
	(t (let ((sign
		  (cond
		   ((memq (car a) '(* /))
		    (let ((s1 (math-possible-signs (nth 1 a)))
			  (s2 (math-possible-signs (nth 2 a))))
		      (cond ((>= s1 8) 15)
			    ((>= s2 8) 15)
			    ((and (eq (car a) '/) (memq s2 '(2 3 6 7))) 15)
			    (t
			     (logior (if (memq s1 '(4 5 6 7)) s2 0)
				     (if (memq s1 '(2 3 6 7)) 2 0)
				     (if (memq s1 '(1 3 5 7))
					 (math-neg-signs s2) 0))))))
		   ((eq (car a) '^)
		    (let ((s1 (math-possible-signs (nth 1 a)))
			  (s2 (math-possible-signs (nth 2 a))))
		      (cond ((>= s1 8) 15)
			    ((>= s2 8) 15)
			    ((eq s1 4) 4)
			    ((eq s1 2) (if (eq s2 4) 2 15))
			    ((eq s2 2) (if (memq s1 '(1 5)) 2 15))
			    ((Math-integerp (nth 2 a))
			     (if (math-evenp (nth 2 a))
				 (if (memq s1 '(3 6 7)) 6 4)
			       s1))
			    ((eq s1 6) (if (eq s2 4) 6 15))
			    (t 7))))
		   ((eq (car a) '%)
		    (let ((s2 (math-possible-signs (nth 2 a))))
		      (cond ((>= s2 8) 7)
			    ((eq s2 2) 2)
			    ((memq s2 '(4 6)) 6)
			    ((memq s2 '(1 3)) 3)
			    (t 7))))
		   ((and (memq (car a) '(calcFunc-abs calcFunc-abssqr))
			 (= (length a) 2))
		    (let ((s1 (math-possible-signs (nth 1 a))))
		      (cond ((eq s1 2) 2)
			    ((memq s1 '(1 4 5)) 4)
			    (t 6))))
		   ((and (eq (car a) 'calcFunc-exp) (= (length a) 2))
		    (let ((s1 (math-possible-signs (nth 1 a))))
		      (if (>= s1 8)
			  15
			(if (or (not origin) (math-negp origin))
			    4
			  (setq origin (math-sub (or origin 0) 1))
			  (if (Math-zerop origin) (setq origin nil))
			  s1))))
		   ((or (and (memq (car a) '(calcFunc-ln calcFunc-log10))
			     (= (length a) 2))
			(and (eq (car a) 'calcFunc-log)
			     (= (length a) 3)
			     (math-known-posp (nth 2 a))))
		    (if (math-known-nonnegp (nth 1 a))
			(math-possible-signs (nth 1 a) 1)
		      15))
		   ((and (eq (car a) 'calcFunc-sqrt) (= (length a) 2))
		    (let ((s1 (math-possible-signs (nth 1 a))))
		      (if (memq s1 '(2 4 6)) s1 15)))
		   ((memq (car a) math-nonnegative-functions) 6)
		   ((memq (car a) math-positive-functions) 4)
		   ((memq (car a) math-real-functions) 7)
		   ((memq (car a) math-real-scalar-functions) 7)
		   ((and (memq (car a) math-real-if-arg-functions)
			 (= (length a) 2))
		    (if (math-known-realp (nth 1 a)) 7 15)))))
	     (cond (sign
		    (if origin
			(+ (logand sign 8)
			   (if (Math-posp origin)
			       (if (memq sign '(1 2 3 8 9 10 11)) 1 7)
			     (if (memq sign '(2 4 6 8 10 12 14)) 4 7)))
		      sign))
		   ((math-const-var a)
		    (cond ((eq (nth 2 a) 'var-pi)
			   (if origin
			       (math-possible-signs (math-pi) origin)
			     4))
			  ((eq (nth 2 a) 'var-e)
			   (if origin
			       (math-possible-signs (math-e) origin)
			     4))
			  ((eq (nth 2 a) 'var-inf) 4)
			  ((eq (nth 2 a) 'var-uinf) 13)
			  ((eq (nth 2 a) 'var-i) 8)
			  (t 15)))
		   (t
		    (math-setup-declarations)
		    (let ((decl (if (eq (car a) 'var)
				    (or (assq (nth 2 a) math-decls-cache)
					math-decls-all)
				  (assq (car a) math-decls-cache))))
		      (if (and origin
			       (memq 'int (nth 1 decl))
			       (not (Math-num-integerp origin)))
			  5
			(if (nth 2 decl)
			    (math-possible-signs (nth 2 decl) origin)
			  (if (memq 'real (nth 1 decl))
			      7
			    15))))))))))

(defun math-neg-signs (s1)
  (if (>= s1 8)
      (+ 8 (math-neg-signs (- s1 8)))
    (+ (if (memq s1 '(1 3 5 7)) 4 0)
       (if (memq s1 '(2 3 6 7)) 2 0)
       (if (memq s1 '(4 5 6 7)) 1 0))))


;;; Try to prove that A is an integer.
(defun math-known-integerp (a)
  (eq (math-possible-types a) 1))

(defun math-known-num-integerp (a)
  (<= (math-possible-types a t) 3))

(defun math-known-imagp (a)
  (= (math-possible-types a) 16))


;;; Find the possible types of A.
;;; Returns an integer with bits:  1  may be integer.
;;;				   2  may be integer-valued float.
;;;				   4  may be fraction.
;;;				   8  may be non-integer-valued float.
;;;				  16  may be imaginary.
;;;				  32  may be non-real, non-imaginary.
;;; Real infinities count as integers for the purposes of this function.
(defun math-possible-types (a &optional num)
  (cond ((Math-objectp a)
	 (cond ((Math-integerp a) (if num 3 1))
	       ((Math-messy-integerp a) (if num 3 2))
	       ((eq (car a) 'frac) (if num 12 4))
	       ((eq (car a) 'float) (if num 12 8))
	       ((eq (car a) 'intv)
		(if (equal (nth 2 a) (nth 3 a))
		    (math-possible-types (nth 2 a))
		  15))
	       ((eq (car a) 'sdev)
		(if (math-known-realp (nth 1 a)) 15 63))
	       ((eq (car a) 'cplx)
		(if (math-zerop (nth 1 a)) 16 32))
	       ((eq (car a) 'polar)
		(if (or (Math-equal (nth 2 a) (math-quarter-circle nil))
			(Math-equal (nth 2 a)
				    (math-neg (math-quarter-circle nil))))
		    16 48))
	       (t 63)))
	((eq (car a) '/)
	 (let* ((t1 (math-possible-types (nth 1 a) num))
		(t2 (math-possible-types (nth 2 a) num))
		(t12 (logior t1 t2)))
	   (if (< t12 16)
	       (if (> (logand t12 10) 0)
		   10
		 (if (or (= t1 4) (= t2 4) calc-prefer-frac)
		     5
		   15))
	     (if (< t12 32)
		 (if (= t1 16)
		     (if (= t2 16) 15
		       (if (< t2 16) 16 31))
		   (if (= t2 16)
		       (if (< t1 16) 16 31)
		     31))
	       63))))
	((memq (car a) '(+ - * %))
	 (let* ((t1 (math-possible-types (nth 1 a) num))
		(t2 (math-possible-types (nth 2 a) num))
		(t12 (logior t1 t2)))
	   (if (eq (car a) '%)
	       (setq t1 (logand t1 15) t2 (logand t2 15) t12 (logand t12 15)))
	   (if (< t12 16)
	       (let ((mask (if (<= t12 3)
			       1
			     (if (and (or (and (<= t1 3) (= (logand t2 3) 0))
					  (and (<= t2 3) (= (logand t1 3) 0)))
				      (memq (car a) '(+ -)))
				 4
			       5))))
		 (if num
		     (* mask 3)
		   (logior (if (and (> (logand t1 5) 0) (> (logand t2 5) 0))
			       mask 0)
			   (if (> (logand t12 10) 0)
			       (* mask 2) 0))))
	     (if (< t12 32)
		 (if (eq (car a) '*)
		     (if (= t1 16)
			 (if (= t2 16) 15
			   (if (< t2 16) 16 31))
		       (if (= t2 16)
			   (if (< t1 16) 16 31)
			 31))
		   (if (= t12 16) 16
		     (if (or (and (= t1 16) (< t2 16))
			     (and (= t2 16) (< t1 16))) 32 63)))
	       63))))
	((eq (car a) 'neg)
	 (math-possible-types (nth 1 a)))
	((eq (car a) '^)
	 (let* ((t1 (math-possible-types (nth 1 a) num))
		(t2 (math-possible-types (nth 2 a) num))
		(t12 (logior t1 t2)))
	   (if (and (<= t2 3) (math-known-nonnegp (nth 2 a)) (< t1 16))
	       (let ((mask (logior (if (> (logand t1 3) 0) 1 0)
				   (logand t1 4)
				   (if (> (logand t1 12) 0) 5 0))))
		 (if num
		     (* mask 3)
		   (logior (if (and (> (logand t1 5) 0) (> (logand t2 5) 0))
			       mask 0)
			   (if (> (logand t12 10) 0)
			       (* mask 2) 0))))
	     (if (and (math-known-nonnegp (nth 1 a))
		      (math-known-posp (nth 2 a)))
		 15
	       63))))
	((eq (car a) 'calcFunc-sqrt)
	 (let ((t1 (math-possible-signs (nth 1 a))))
	   (logior (if (> (logand t1 2) 0) 3 0)
		   (if (> (logand t1 1) 0) 16 0)
		   (if (> (logand t1 4) 0) 15 0)
		   (if (> (logand t1 8) 0) 32 0))))
	((eq (car a) 'vec)
	 (let ((types 0))
	   (while (and (setq a (cdr a)) (< types 63))
	     (setq types (logior types (math-possible-types (car a) t))))
	   types))
	((or (memq (car a) math-integer-functions)
	     (and (memq (car a) math-rounding-functions)
		  (math-known-nonnegp (or (nth 2 a) 0))))
	 1)
	((or (memq (car a) math-num-integer-functions)
	     (and (memq (car a) math-float-rounding-functions)
		  (math-known-nonnegp (or (nth 2 a) 0))))
	 2)
	((eq (car a) 'calcFunc-frac)
	 5)
	((and (eq (car a) 'calcFunc-float) (= (length a) 2))
	 (let ((t1 (math-possible-types (nth 1 a))))
	   (logior (if (> (logand t1 3) 0) 2 0)
		   (if (> (logand t1 12) 0) 8 0)
		   (logand t1 48))))
	((and (memq (car a) '(calcFunc-abs calcFunc-abssqr))
	      (= (length a) 2))
	 (let ((t1 (math-possible-types (nth 1 a))))
	   (if (>= t1 16)
	       15
	     t1)))
	((math-const-var a)
	 (cond ((memq (nth 2 a) '(var-e var-pi var-phi var-gamma)) 8)
	       ((eq (nth 2 a) 'var-inf) 1)
	       ((eq (nth 2 a) 'var-i) 16)
	       (t 63)))
	(t
	 (math-setup-declarations)
	 (let ((decl (if (eq (car a) 'var)
			 (or (assq (nth 2 a) math-decls-cache)
			     math-decls-all)
		       (assq (car a) math-decls-cache))))
	   (cond ((memq 'int (nth 1 decl))
		  1)
		 ((memq 'numint (nth 1 decl))
		  3)
		 ((memq 'frac (nth 1 decl))
		  4)
		 ((memq 'rat (nth 1 decl))
		  5)
		 ((memq 'float (nth 1 decl))
		  10)
		 ((nth 2 decl)
		  (math-possible-types (nth 2 decl)))
		 ((memq 'real (nth 1 decl))
		  15)
		 (t 63))))))

(defun math-known-evenp (a)
  (cond ((Math-integerp a)
	 (math-evenp a))
	((Math-messy-integerp a)
	 (or (> (nth 2 a) 0)
	     (math-evenp (math-trunc a))))
	((eq (car a) '*)
	 (if (math-known-evenp (nth 1 a))
	     (math-known-num-integerp (nth 2 a))
	   (if (math-known-num-integerp (nth 1 a))
	       (math-known-evenp (nth 2 a)))))
	((memq (car a) '(+ -))
	 (or (and (math-known-evenp (nth 1 a))
		  (math-known-evenp (nth 2 a)))
	     (and (math-known-oddp (nth 1 a))
		  (math-known-oddp (nth 2 a)))))
	((eq (car a) 'neg)
	 (math-known-evenp (nth 1 a)))))

(defun math-known-oddp (a)
  (cond ((Math-integerp a)
	 (math-oddp a))
	((Math-messy-integerp a)
	 (and (<= (nth 2 a) 0)
	      (math-oddp (math-trunc a))))
	((memq (car a) '(+ -))
	 (or (and (math-known-evenp (nth 1 a))
		  (math-known-oddp (nth 2 a)))
	     (and (math-known-oddp (nth 1 a))
		  (math-known-evenp (nth 2 a)))))
	((eq (car a) 'neg)
	 (math-known-oddp (nth 1 a)))))


(defun calcFunc-dreal (expr)
  (let ((types (math-possible-types expr)))
    (if (< types 16) 1
      (if (= (logand types 15) 0) 0
	(math-reject-arg expr 'realp 'quiet)))))

(defun calcFunc-dimag (expr)
  (let ((types (math-possible-types expr)))
    (if (= types 16) 1
      (if (= (logand types 16) 0) 0
	(math-reject-arg expr "Expected an imaginary number")))))

(defun calcFunc-dpos (expr)
  (let ((signs (math-possible-signs expr)))
    (if (eq signs 4) 1
      (if (memq signs '(1 2 3)) 0
	(math-reject-arg expr 'posp 'quiet)))))

(defun calcFunc-dneg (expr)
  (let ((signs (math-possible-signs expr)))
    (if (eq signs 1) 1
      (if (memq signs '(2 4 6)) 0
	(math-reject-arg expr 'negp 'quiet)))))

(defun calcFunc-dnonneg (expr)
  (let ((signs (math-possible-signs expr)))
    (if (memq signs '(2 4 6)) 1
      (if (eq signs 1) 0
	(math-reject-arg expr 'posp 'quiet)))))

(defun calcFunc-dnonzero (expr)
  (let ((signs (math-possible-signs expr)))
    (if (memq signs '(1 4 5 8 9 12 13)) 1
      (if (eq signs 2) 0
	(math-reject-arg expr 'nonzerop 'quiet)))))

(defun calcFunc-dint (expr)
  (let ((types (math-possible-types expr)))
    (if (= types 1) 1
      (if (= (logand types 1) 0) 0
	(math-reject-arg expr 'integerp 'quiet)))))

(defun calcFunc-dnumint (expr)
  (let ((types (math-possible-types expr t)))
    (if (<= types 3) 1
      (if (= (logand types 3) 0) 0
	(math-reject-arg expr 'integerp 'quiet)))))

(defun calcFunc-dnatnum (expr)
  (let ((res (calcFunc-dint expr)))
    (if (eq res 1)
	(calcFunc-dnonneg expr)
      res)))

(defun calcFunc-deven (expr)
  (if (math-known-evenp expr)
      1
    (if (or (math-known-oddp expr)
	    (= (logand (math-possible-types expr) 3) 0))
	0
      (math-reject-arg expr "Can't tell if expression is odd or even"))))

(defun calcFunc-dodd (expr)
  (if (math-known-oddp expr)
      1
    (if (or (math-known-evenp expr)
	    (= (logand (math-possible-types expr) 3) 0))
	0
      (math-reject-arg expr "Can't tell if expression is odd or even"))))

(defun calcFunc-drat (expr)
  (let ((types (math-possible-types expr)))
    (if (memq types '(1 4 5)) 1
      (if (= (logand types 5) 0) 0
	(math-reject-arg expr "Rational number expected")))))

(defun calcFunc-drange (expr)
  (math-setup-declarations)
  (let (range)
    (if (Math-realp expr)
	(list 'vec expr)
      (if (eq (car-safe expr) 'intv)
	  expr
	(if (eq (car-safe expr) 'var)
	    (setq range (nth 2 (or (assq (nth 2 expr) math-decls-cache)
				   math-decls-all)))
	  (setq range (nth 2 (assq (car-safe expr) math-decls-cache))))
	(if range
	    (math-clean-set (copy-sequence range))
	  (setq range (math-possible-signs expr))
	  (if (< range 8)
	      (aref [(vec)
		     (intv 2 (neg (var inf var-inf)) 0)
		     (vec 0)
		     (intv 3 (neg (var inf var-inf)) 0)
		     (intv 1 0 (var inf var-inf))
		     (vec (intv 2 (neg (var inf var-inf)) 0)
			  (intv 1 0 (var inf var-inf)))
		     (intv 3 0 (var inf var-inf))
		     (intv 3 (neg (var inf var-inf)) (var inf var-inf))] range)
	    (math-reject-arg expr 'realp 'quiet)))))))

(defun calcFunc-dscalar (a)
  (if (math-known-scalarp a) 1
    (if (math-known-matrixp a) 0
      (math-reject-arg a 'objectp 'quiet))))


;;;; Arithmetic.

(defsubst calcFunc-neg (a)
  (math-normalize (list 'neg a)))

(defun math-neg-fancy (a)
  (cond ((eq (car a) 'polar)
	 (list 'polar
	       (nth 1 a)
	       (if (math-posp (nth 2 a))
		   (math-sub (nth 2 a) (math-half-circle nil))
		 (math-add (nth 2 a) (math-half-circle nil)))))
	((eq (car a) 'mod)
	 (if (math-zerop (nth 1 a))
	     a
	   (list 'mod (math-sub (nth 2 a) (nth 1 a)) (nth 2 a))))
	((eq (car a) 'sdev)
	 (list 'sdev (math-neg (nth 1 a)) (nth 2 a)))
	((eq (car a) 'intv)
	 (math-make-intv (aref [0 2 1 3] (nth 1 a))
			 (math-neg (nth 3 a))
			 (math-neg (nth 2 a))))
	((and math-simplify-only
	      (not (equal a math-simplify-only)))
	 (list 'neg a))
	((eq (car a) '+)
	 (math-sub (math-neg (nth 1 a)) (nth 2 a)))
	((eq (car a) '-)
	 (math-sub (nth 2 a) (nth 1 a)))
	((and (memq (car a) '(* /))
	      (math-okay-neg (nth 1 a)))
	 (list (car a) (math-neg (nth 1 a)) (nth 2 a)))
	((and (memq (car a) '(* /))
	      (math-okay-neg (nth 2 a)))
	 (list (car a) (nth 1 a) (math-neg (nth 2 a))))
	((and (memq (car a) '(* /))
	      (or (math-objectp (nth 1 a))
		  (and (eq (car (nth 1 a)) '*)
		       (math-objectp (nth 1 (nth 1 a))))))
	 (list (car a) (math-neg (nth 1 a)) (nth 2 a)))
	((and (eq (car a) '/)
	      (or (math-objectp (nth 2 a))
		  (and (eq (car (nth 2 a)) '*)
		       (math-objectp (nth 1 (nth 2 a))))))
	 (list (car a) (nth 1 a) (math-neg (nth 2 a))))
	((and (eq (car a) 'var) (memq (nth 2 a) '(var-uinf var-nan)))
	 a)
	((eq (car a) 'neg)
	 (nth 1 a))
	(t (list 'neg a))))

(defun math-okay-neg (a)
  (or (math-looks-negp a)
      (eq (car-safe a) '-)))

(defun math-neg-float (a)
  (list 'float (Math-integer-neg (nth 1 a)) (nth 2 a)))


(defun calcFunc-add (&rest rest)
  (if rest
      (let ((a (car rest)))
	(while (setq rest (cdr rest))
	  (setq a (list '+ a (car rest))))
	(math-normalize a))
    0))

(defun calcFunc-sub (&rest rest)
  (if rest
      (let ((a (car rest)))
	(while (setq rest (cdr rest))
	  (setq a (list '- a (car rest))))
	(math-normalize a))
    0))

(defun math-add-objects-fancy (a b)
  (cond ((and (Math-numberp a) (Math-numberp b))
	 (let ((aa (math-complex a))
	       (bb (math-complex b)))
	   (math-normalize
	    (let ((res (list 'cplx
			     (math-add (nth 1 aa) (nth 1 bb))
			     (math-add (nth 2 aa) (nth 2 bb)))))
	      (if (math-want-polar a b)
		  (math-polar res)
		res)))))
	((or (Math-vectorp a) (Math-vectorp b))
	 (math-map-vec-2 'math-add a b))
	((eq (car-safe a) 'sdev)
	 (if (eq (car-safe b) 'sdev)
	     (math-make-sdev (math-add (nth 1 a) (nth 1 b))
			     (math-hypot (nth 2 a) (nth 2 b)))
	   (and (or (Math-scalarp b)
		    (not (Math-objvecp b)))
		(math-make-sdev (math-add (nth 1 a) b) (nth 2 a)))))
	((and (eq (car-safe b) 'sdev)
	      (or (Math-scalarp a)
		  (not (Math-objvecp a))))
	 (math-make-sdev (math-add a (nth 1 b)) (nth 2 b)))
	((eq (car-safe a) 'intv)
	 (if (eq (car-safe b) 'intv)
	     (math-make-intv (logior (logand (nth 1 a) (nth 1 b))
				     (if (equal (nth 2 a)
						'(neg (var inf var-inf)))
					 (logand (nth 1 a) 2) 0)
				     (if (equal (nth 2 b)
						'(neg (var inf var-inf)))
					 (logand (nth 1 b) 2) 0)
				     (if (equal (nth 3 a) '(var inf var-inf))
					 (logand (nth 1 a) 1) 0)
				     (if (equal (nth 3 b) '(var inf var-inf))
					 (logand (nth 1 b) 1) 0))
			     (math-add (nth 2 a) (nth 2 b))
			     (math-add (nth 3 a) (nth 3 b)))
	   (and (or (Math-anglep b)
		    (eq (car b) 'date)
		    (not (Math-objvecp b)))
		(math-make-intv (nth 1 a)
				(math-add (nth 2 a) b)
				(math-add (nth 3 a) b)))))
	((and (eq (car-safe b) 'intv)
	      (or (Math-anglep a)
		  (eq (car a) 'date)
		  (not (Math-objvecp a))))
	 (math-make-intv (nth 1 b)
			 (math-add a (nth 2 b))
			 (math-add a (nth 3 b))))
	((eq (car-safe a) 'date)
	 (cond ((eq (car-safe b) 'date)
		(math-add (nth 1 a) (nth 1 b)))
	       ((eq (car-safe b) 'hms)
		(let ((parts (math-date-parts (nth 1 a))))
		  (list 'date
			(math-add (car parts)   ; this minimizes roundoff
				  (math-div (math-add
					     (math-add (nth 1 parts)
						       (nth 2 parts))
					     (math-add
					      (math-mul (nth 1 b) 3600)
					      (math-add (math-mul (nth 2 b) 60)
							(nth 3 b))))
					    86400)))))
	       ((Math-realp b)
		(list 'date (math-add (nth 1 a) b)))
	       (t nil)))
	((eq (car-safe b) 'date)
	 (math-add-objects-fancy b a))
	((and (eq (car-safe a) 'mod)
	      (eq (car-safe b) 'mod)
	      (equal (nth 2 a) (nth 2 b)))
	 (math-make-mod (math-add (nth 1 a) (nth 1 b)) (nth 2 a)))
	((and (eq (car-safe a) 'mod)
	      (Math-anglep b))
	 (math-make-mod (math-add (nth 1 a) b) (nth 2 a)))
	((and (eq (car-safe b) 'mod)
	      (Math-anglep a))
	 (math-make-mod (math-add a (nth 1 b)) (nth 2 b)))
	((and (or (eq (car-safe a) 'hms) (eq (car-safe b) 'hms))
	      (and (Math-anglep a) (Math-anglep b)))
	 (or (eq (car-safe a) 'hms) (setq a (math-to-hms a)))
	 (or (eq (car-safe b) 'hms) (setq b (math-to-hms b)))
	 (math-normalize
	  (if (math-negp a)
	      (math-neg (math-add (math-neg a) (math-neg b)))
	    (if (math-negp b)
		(let* ((s (math-add (nth 3 a) (nth 3 b)))
		       (m (math-add (nth 2 a) (nth 2 b)))
		       (h (math-add (nth 1 a) (nth 1 b))))
		  (if (math-negp s)
		      (setq s (math-add s 60)
			    m (math-add m -1)))
		  (if (math-negp m)
		      (setq m (math-add m 60)
			    h (math-add h -1)))
		  (if (math-negp h)
		      (math-add b a)
		    (list 'hms h m s)))
	      (let* ((s (math-add (nth 3 a) (nth 3 b)))
		     (m (math-add (nth 2 a) (nth 2 b)))
		     (h (math-add (nth 1 a) (nth 1 b))))
		(list 'hms h m s))))))
	(t (calc-record-why "*Incompatible arguments for +" a b))))

(defun math-add-symb-fancy (a b)
  (or (and math-simplify-only
	   (not (equal a math-simplify-only))
	   (list '+ a b))
      (and (eq (car-safe b) '+)
	   (math-add (math-add a (nth 1 b))
		     (nth 2 b)))
      (and (eq (car-safe b) '-)
	   (math-sub (math-add a (nth 1 b))
		     (nth 2 b)))
      (and (eq (car-safe b) 'neg)
	   (eq (car-safe (nth 1 b)) '+)
	   (math-sub (math-sub a (nth 1 (nth 1 b)))
		     (nth 2 (nth 1 b))))
      (and (or (and (Math-vectorp a) (math-known-scalarp b))
	       (and (Math-vectorp b) (math-known-scalarp a)))
	   (math-map-vec-2 'math-add a b))
      (let ((inf (math-infinitep a)))
	(cond
	 (inf
	  (let ((inf2 (math-infinitep b)))
	    (if inf2
		(if (or (memq (nth 2 inf) '(var-uinf var-nan))
			(memq (nth 2 inf2) '(var-uinf var-nan)))
		    '(var nan var-nan)
		  (let ((dir (math-infinite-dir a inf))
			(dir2 (math-infinite-dir b inf2)))
		    (if (and (Math-objectp dir) (Math-objectp dir2))
			(if (Math-equal dir dir2)
			    a
			  '(var nan var-nan)))))
	      (if (and (equal a '(var inf var-inf))
		       (eq (car-safe b) 'intv)
		       (memq (nth 1 b) '(2 3))
		       (equal (nth 2 b) '(neg (var inf var-inf))))
		  (list 'intv 3 (nth 2 b) a)
		(if (and (equal a '(neg (var inf var-inf)))
			 (eq (car-safe b) 'intv)
			 (memq (nth 1 b) '(1 3))
			 (equal (nth 3 b) '(var inf var-inf)))
		    (list 'intv 3 a (nth 3 b))
		  a)))))
	 ((math-infinitep b)
	  (if (eq (car-safe a) 'intv)
	      (math-add b a)
	    b))
	 ((eq (car-safe a) '+)
	  (let ((temp (math-combine-sum (nth 2 a) b nil nil t)))
	    (and temp
		 (math-add (nth 1 a) temp))))
	 ((eq (car-safe a) '-)
	  (let ((temp (math-combine-sum (nth 2 a) b t nil t)))
	    (and temp
		 (math-add (nth 1 a) temp))))
	 ((and (Math-objectp a) (Math-objectp b))
	  nil)
	 (t
	  (math-combine-sum a b nil nil nil))))
      (and (Math-looks-negp b)
	   (list '- a (math-neg b)))
      (and (Math-looks-negp a)
	   (list '- b (math-neg a)))
      (and (eq (car-safe a) 'calcFunc-idn)
	   (= (length a) 2)
	   (or (and (eq (car-safe b) 'calcFunc-idn)
		    (= (length b) 2)
		    (list 'calcFunc-idn (math-add (nth 1 a) (nth 1 b))))
	       (and (math-square-matrixp b)
		    (math-add (math-mimic-ident (nth 1 a) b) b))
	       (and (math-known-scalarp b)
		    (math-add (nth 1 a) b))))
      (and (eq (car-safe b) 'calcFunc-idn)
	   (= (length a) 2)
	   (or (and (math-square-matrixp a)
		    (math-add a (math-mimic-ident (nth 1 b) a)))
	       (and (math-known-scalarp a)
		    (math-add a (nth 1 b)))))
      (list '+ a b)))


(defun calcFunc-mul (&rest rest)
  (if rest
      (let ((a (car rest)))
	(while (setq rest (cdr rest))
	  (setq a (list '* a (car rest))))
	(math-normalize a))
    1))

(defun math-mul-objects-fancy (a b)
  (cond ((and (Math-numberp a) (Math-numberp b))
	 (math-normalize
	  (if (math-want-polar a b)
	      (let ((a (math-polar a))
		    (b (math-polar b)))
		(list 'polar
		      (math-mul (nth 1 a) (nth 1 b))
		      (math-fix-circular (math-add (nth 2 a) (nth 2 b)))))
	    (setq a (math-complex a)
		  b (math-complex b))
	    (list 'cplx
		  (math-sub (math-mul (nth 1 a) (nth 1 b))
			    (math-mul (nth 2 a) (nth 2 b)))
		  (math-add (math-mul (nth 1 a) (nth 2 b))
			    (math-mul (nth 2 a) (nth 1 b)))))))
	((Math-vectorp a)
	 (if (Math-vectorp b)
	     (if (math-matrixp a)
		 (if (math-matrixp b)
		     (if (= (length (nth 1 a)) (length b))
			 (math-mul-mats a b)
		       (math-dimension-error))
		   (if (= (length (nth 1 a)) 2)
		       (if (= (length a) (length b))
			   (math-mul-mats a (list 'vec b))
			 (math-dimension-error))
		     (if (= (length (nth 1 a)) (length b))
			 (math-mul-mat-vec a b)
		       (math-dimension-error))))
	       (if (math-matrixp b)
		   (if (= (length a) (length b))
		       (nth 1 (math-mul-mats (list 'vec a) b))
		     (math-dimension-error))
		 (if (= (length a) (length b))
		     (math-dot-product a b)
		   (math-dimension-error))))
	   (math-map-vec-2 'math-mul a b)))
	((Math-vectorp b)
	 (math-map-vec-2 'math-mul a b))
	((eq (car-safe a) 'sdev)
	 (if (eq (car-safe b) 'sdev)
	     (math-make-sdev (math-mul (nth 1 a) (nth 1 b))
			     (math-hypot (math-mul (nth 2 a) (nth 1 b))
					 (math-mul (nth 2 b) (nth 1 a))))
	   (and (or (Math-scalarp b)
		    (not (Math-objvecp b)))
		(math-make-sdev (math-mul (nth 1 a) b)
				(math-mul (nth 2 a) b)))))
	((and (eq (car-safe b) 'sdev)
	      (or (Math-scalarp a)
		  (not (Math-objvecp a))))
	 (math-make-sdev (math-mul a (nth 1 b)) (math-mul a (nth 2 b))))
	((and (eq (car-safe a) 'intv) (Math-anglep b))
	 (if (Math-negp b)
	     (math-neg (math-mul a (math-neg b)))
	   (math-make-intv (nth 1 a)
			   (math-mul (nth 2 a) b)
			   (math-mul (nth 3 a) b))))
	((and (eq (car-safe b) 'intv) (Math-anglep a))
	 (math-mul b a))
	((and (eq (car-safe a) 'intv) (math-intv-constp a)
	      (eq (car-safe b) 'intv) (math-intv-constp b))
	 (let ((lo (math-mul a (nth 2 b)))
	       (hi (math-mul a (nth 3 b))))
	   (or (eq (car-safe lo) 'intv)
	       (setq lo (list 'intv (if (memq (nth 1 b) '(2 3)) 3 0) lo lo)))
	   (or (eq (car-safe hi) 'intv)
	       (setq hi (list 'intv (if (memq (nth 1 b) '(1 3)) 3 0) hi hi)))
	   (math-combine-intervals
	    (nth 2 lo) (and (or (memq (nth 1 b) '(2 3))
				(math-infinitep (nth 2 lo)))
			    (memq (nth 1 lo) '(2 3)))
	    (nth 3 lo) (and (or (memq (nth 1 b) '(2 3))
				(math-infinitep (nth 3 lo)))
			    (memq (nth 1 lo) '(1 3)))
	    (nth 2 hi) (and (or (memq (nth 1 b) '(1 3))
				(math-infinitep (nth 2 hi)))
			    (memq (nth 1 hi) '(2 3)))
	    (nth 3 hi) (and (or (memq (nth 1 b) '(1 3))
				(math-infinitep (nth 3 hi)))
			    (memq (nth 1 hi) '(1 3))))))
	((and (eq (car-safe a) 'mod)
	      (eq (car-safe b) 'mod)
	      (equal (nth 2 a) (nth 2 b)))
	 (math-make-mod (math-mul (nth 1 a) (nth 1 b)) (nth 2 a)))
	((and (eq (car-safe a) 'mod)
	      (Math-anglep b))
	 (math-make-mod (math-mul (nth 1 a) b) (nth 2 a)))
	((and (eq (car-safe b) 'mod)
	      (Math-anglep a))
	 (math-make-mod (math-mul a (nth 1 b)) (nth 2 b)))
	((and (eq (car-safe a) 'hms) (Math-realp b))
	 (math-with-extra-prec 2
	   (math-to-hms (math-mul (math-from-hms a 'deg) b) 'deg)))
	((and (eq (car-safe b) 'hms) (Math-realp a))
	 (math-mul b a))
	(t (calc-record-why "*Incompatible arguments for *" a b))))

;;; Fast function to multiply floating-point numbers.
(defun math-mul-float (a b)   ; [F F F]
  (math-make-float (math-mul (nth 1 a) (nth 1 b))
		   (+ (nth 2 a) (nth 2 b))))

(defun math-sqr-float (a)   ; [F F]
  (math-make-float (math-mul (nth 1 a) (nth 1 a))
		   (+ (nth 2 a) (nth 2 a))))

(defun math-intv-constp (a &optional finite)
  (and (or (Math-anglep (nth 2 a))
	   (and (equal (nth 2 a) '(neg (var inf var-inf)))
		(or (not finite)
		    (memq (nth 1 a) '(0 1)))))
       (or (Math-anglep (nth 3 a))
	   (and (equal (nth 3 a) '(var inf var-inf))
		(or (not finite)
		    (memq (nth 1 a) '(0 2)))))))

(defun math-mul-zero (a b)
  (if (math-known-matrixp b)
      (if (math-vectorp b)
	  (math-map-vec-2 'math-mul a b)
	(math-mimic-ident 0 b))
    (if (math-infinitep b)
	'(var nan var-nan)
      (let ((aa nil) (bb nil))
	(if (and (eq (car-safe b) 'intv)
		 (progn
		   (and (equal (nth 2 b) '(neg (var inf var-inf)))
			(memq (nth 1 b) '(2 3))
			(setq aa (nth 2 b)))
		   (and (equal (nth 3 b) '(var inf var-inf))
			(memq (nth 1 b) '(1 3))
			(setq bb (nth 3 b)))
		   (or aa bb)))
	    (if (or (math-posp a)
		    (and (math-zerop a)
			 (or (memq calc-infinite-mode '(-1 1))
			     (setq aa '(neg (var inf var-inf))
				   bb '(var inf var-inf)))))
		(list 'intv 3 (or aa 0) (or bb 0))
	      (if (math-negp a)
		  (math-neg (list 'intv 3 (or aa 0) (or bb 0)))
		'(var nan var-nan)))
	  (if (or (math-floatp a) (math-floatp b)) '(float 0 0) 0))))))


(defun math-mul-symb-fancy (a b)
  (or (and math-simplify-only
	   (not (equal a math-simplify-only))
	   (list '* a b))
      (and (Math-equal-int a 1)
	   b)
      (and (Math-equal-int a -1)
	   (math-neg b))
      (and (or (and (Math-vectorp a) (math-known-scalarp b))
	       (and (Math-vectorp b) (math-known-scalarp a)))
	   (math-map-vec-2 'math-mul a b))
      (and (Math-objectp b) (not (Math-objectp a))
	   (math-mul b a))
      (and (eq (car-safe a) 'neg)
	   (math-neg (math-mul (nth 1 a) b)))
      (and (eq (car-safe b) 'neg)
	   (math-neg (math-mul a (nth 1 b))))
      (and (eq (car-safe a) '*)
	   (math-mul (nth 1 a)
		     (math-mul (nth 2 a) b)))
      (and (eq (car-safe a) '^)
	   (Math-looks-negp (nth 2 a))
	   (not (and (eq (car-safe b) '^) (Math-looks-negp (nth 2 b))))
	   (math-known-scalarp b t)
	   (math-div b (math-normalize
			(list '^ (nth 1 a) (math-neg (nth 2 a))))))
      (and (eq (car-safe b) '^)
	   (Math-looks-negp (nth 2 b))
	   (not (and (eq (car-safe a) '^) (Math-looks-negp (nth 2 a))))
	   (math-div a (math-normalize
			(list '^ (nth 1 b) (math-neg (nth 2 b))))))
      (and (eq (car-safe a) '/)
	   (or (math-known-scalarp a t) (math-known-scalarp b t))
	   (let ((temp (math-combine-prod (nth 2 a) b t nil t)))
	     (if temp
		 (math-mul (nth 1 a) temp)
	       (math-div (math-mul (nth 1 a) b) (nth 2 a)))))
      (and (eq (car-safe b) '/)
	   (math-div (math-mul a (nth 1 b)) (nth 2 b)))
      (and (eq (car-safe b) '+)
	   (Math-numberp a)
	   (or (Math-numberp (nth 1 b))
	       (Math-numberp (nth 2 b)))
	   (math-add (math-mul a (nth 1 b))
		     (math-mul a (nth 2 b))))
      (and (eq (car-safe b) '-)
	   (Math-numberp a)
	   (or (Math-numberp (nth 1 b))
	       (Math-numberp (nth 2 b)))
	   (math-sub (math-mul a (nth 1 b))
		     (math-mul a (nth 2 b))))
      (and (eq (car-safe b) '*)
	   (Math-numberp (nth 1 b))
	   (not (Math-numberp a))
	   (math-mul (nth 1 b) (math-mul a (nth 2 b))))
      (and (eq (car-safe a) 'calcFunc-idn)
	   (= (length a) 2)
	   (or (and (eq (car-safe b) 'calcFunc-idn)
		    (= (length b) 2)
		    (list 'calcFunc-idn (math-mul (nth 1 a) (nth 1 b))))
	       (and (math-known-scalarp b)
		    (list 'calcFunc-idn (math-mul (nth 1 a) b)))
	       (and (math-known-matrixp b)
		    (math-mul (nth 1 a) b))))
      (and (eq (car-safe b) 'calcFunc-idn)
	   (= (length b) 2)
	   (or (and (math-known-scalarp a)
		    (list 'calcFunc-idn (math-mul a (nth 1 b))))
	       (and (math-known-matrixp a)
		    (math-mul a (nth 1 b)))))
      (and (math-looks-negp b)
	   (math-mul (math-neg a) (math-neg b)))
      (and (eq (car-safe b) '-)
	   (math-looks-negp a)
	   (math-mul (math-neg a) (math-neg b)))
      (cond
       ((eq (car-safe b) '*)
	(let ((temp (math-combine-prod a (nth 1 b) nil nil t)))
	  (and temp
	       (math-mul temp (nth 2 b)))))
       (t
	(math-combine-prod a b nil nil nil)))
      (and (equal a '(var nan var-nan))
	   a)
      (and (equal b '(var nan var-nan))
	   b)
      (and (equal a '(var uinf var-uinf))
	   a)
      (and (equal b '(var uinf var-uinf))
	   b)
      (and (equal b '(var inf var-inf))
	   (let ((s1 (math-possible-signs a)))
	     (cond ((eq s1 4)
		    b)
		   ((eq s1 6)
		    '(intv 3 0 (var inf var-inf)))
		   ((eq s1 1)
		    (math-neg b))
		   ((eq s1 3)
		    '(intv 3 (neg (var inf var-inf)) 0))
		   ((and (eq (car a) 'intv) (math-intv-constp a))
		    '(intv 3 (neg (var inf var-inf)) (var inf var-inf)))
		   ((and (eq (car a) 'cplx)
			 (math-zerop (nth 1 a)))
		    (list '* (list 'cplx 0 (calcFunc-sign (nth 2 a))) b))
		   ((eq (car a) 'polar)
		    (list '* (list 'polar 1 (nth 2 a)) b)))))
      (and (equal a '(var inf var-inf))
	   (math-mul b a))
      (list '* a b)))


(defun calcFunc-div (a &rest rest)
  (while rest
    (setq a (list '/ a (car rest))
	  rest (cdr rest)))
  (math-normalize a))

(defun math-div-objects-fancy (a b)
  (cond ((and (Math-numberp a) (Math-numberp b))
	 (math-normalize
	  (cond ((math-want-polar a b)
		 (let ((a (math-polar a))
		       (b (math-polar b)))
		   (list 'polar
			 (math-div (nth 1 a) (nth 1 b))
			 (math-fix-circular (math-sub (nth 2 a)
						      (nth 2 b))))))
		((Math-realp b)
		 (setq a (math-complex a))
		 (list 'cplx (math-div (nth 1 a) b)
		       (math-div (nth 2 a) b)))
		(t
		 (setq a (math-complex a)
		       b (math-complex b))
		 (math-div
		  (list 'cplx
			(math-add (math-mul (nth 1 a) (nth 1 b))
				  (math-mul (nth 2 a) (nth 2 b)))
			(math-sub (math-mul (nth 2 a) (nth 1 b))
				  (math-mul (nth 1 a) (nth 2 b))))
		  (math-add (math-sqr (nth 1 b))
			    (math-sqr (nth 2 b))))))))
	((math-matrixp b)
	 (if (math-square-matrixp b)
	     (let ((n1 (length b)))
	       (if (Math-vectorp a)
		   (if (math-matrixp a)
		       (if (= (length a) n1)
			   (math-lud-solve (math-matrix-lud b) a b)
			 (if (= (length (nth 1 a)) n1)
			     (math-transpose
			      (math-lud-solve (math-matrix-lud
					       (math-transpose b))
					      (math-transpose a) b))
			   (math-dimension-error)))
		     (if (= (length a) n1)
			 (math-mat-col (math-lud-solve (math-matrix-lud b)
						       (math-col-matrix a) b)
				       1)
		       (math-dimension-error)))
		 (if (Math-equal-int a 1)
		     (calcFunc-inv b)
		   (math-mul a (calcFunc-inv b)))))
	   (math-reject-arg b 'square-matrixp)))
	((and (Math-vectorp a) (Math-objectp b))
	 (math-map-vec-2 'math-div a b))
	((eq (car-safe a) 'sdev)
	 (if (eq (car-safe b) 'sdev)
	     (let ((x (math-div (nth 1 a) (nth 1 b))))
	       (math-make-sdev x
			       (math-div (math-hypot (nth 2 a)
						     (math-mul (nth 2 b) x))
					 (nth 1 b))))
	   (if (or (Math-scalarp b)
		   (not (Math-objvecp b)))
	       (math-make-sdev (math-div (nth 1 a) b) (math-div (nth 2 a) b))
	     (math-reject-arg 'realp b))))
	((and (eq (car-safe b) 'sdev)
	      (or (Math-scalarp a)
		  (not (Math-objvecp a))))
	 (let ((x (math-div a (nth 1 b))))
	   (math-make-sdev x
			   (math-div (math-mul (nth 2 b) x) (nth 1 b)))))
	((and (eq (car-safe a) 'intv) (Math-anglep b))
	 (if (Math-negp b)
	     (math-neg (math-div a (math-neg b)))
	   (math-make-intv (nth 1 a)
			   (math-div (nth 2 a) b)
			   (math-div (nth 3 a) b))))
	((and (eq (car-safe b) 'intv) (Math-anglep a))
	 (if (or (Math-posp (nth 2 b))
		 (and (Math-zerop (nth 2 b)) (or (memq (nth 1 b) '(0 1))
						 calc-infinite-mode)))
	     (if (Math-negp a)
		 (math-neg (math-div (math-neg a) b))
	       (let ((calc-infinite-mode 1))
		 (math-make-intv (aref [0 2 1 3] (nth 1 b))
				 (math-div a (nth 3 b))
				 (math-div a (nth 2 b)))))
	   (if (or (Math-negp (nth 3 b))
		   (and (Math-zerop (nth 3 b)) (or (memq (nth 1 b) '(0 2))
						   calc-infinite-mode)))
	       (math-neg (math-div a (math-neg b)))
	     (if calc-infinite-mode
		 '(intv 3 (neg (var inf var-inf)) (var inf var-inf))
	       (math-reject-arg b "*Division by zero")))))
	((and (eq (car-safe a) 'intv) (math-intv-constp a)
	      (eq (car-safe b) 'intv) (math-intv-constp b))
	 (if (or (Math-posp (nth 2 b))
		 (and (Math-zerop (nth 2 b)) (or (memq (nth 1 b) '(0 1))
						 calc-infinite-mode)))
	     (let* ((calc-infinite-mode 1)
		    (lo (math-div a (nth 2 b)))
		    (hi (math-div a (nth 3 b))))
	       (or (eq (car-safe lo) 'intv)
		   (setq lo (list 'intv (if (memq (nth 1 b) '(2 3)) 3 0)
				  lo lo)))
	       (or (eq (car-safe hi) 'intv)
		   (setq hi (list 'intv (if (memq (nth 1 b) '(1 3)) 3 0)
				  hi hi)))
	       (math-combine-intervals
		(nth 2 lo) (and (or (memq (nth 1 b) '(2 3))
				    (and (math-infinitep (nth 2 lo))
					 (not (math-zerop (nth 2 b)))))
				(memq (nth 1 lo) '(2 3)))
		(nth 3 lo) (and (or (memq (nth 1 b) '(2 3))
				    (and (math-infinitep (nth 3 lo))
					 (not (math-zerop (nth 2 b)))))
				(memq (nth 1 lo) '(1 3)))
		(nth 2 hi) (and (or (memq (nth 1 b) '(1 3))
				    (and (math-infinitep (nth 2 hi))
					 (not (math-zerop (nth 3 b)))))
				(memq (nth 1 hi) '(2 3)))
		(nth 3 hi) (and (or (memq (nth 1 b) '(1 3))
				    (and (math-infinitep (nth 3 hi))
					 (not (math-zerop (nth 3 b)))))
				(memq (nth 1 hi) '(1 3)))))
	   (if (or (Math-negp (nth 3 b))
		   (and (Math-zerop (nth 3 b)) (or (memq (nth 1 b) '(0 2))
						   calc-infinite-mode)))
	       (math-neg (math-div a (math-neg b)))
	     (if calc-infinite-mode
		 '(intv 3 (neg (var inf var-inf)) (var inf var-inf))
	       (math-reject-arg b "*Division by zero")))))
	((and (eq (car-safe a) 'mod)
	      (eq (car-safe b) 'mod)
	      (equal (nth 2 a) (nth 2 b)))
	 (math-make-mod (math-div-mod (nth 1 a) (nth 1 b) (nth 2 a))
			(nth 2 a)))
	((and (eq (car-safe a) 'mod)
	      (Math-anglep b))
	 (math-make-mod (math-div-mod (nth 1 a) b (nth 2 a)) (nth 2 a)))
	((and (eq (car-safe b) 'mod)
	      (Math-anglep a))
	 (math-make-mod (math-div-mod a (nth 1 b) (nth 2 b)) (nth 2 b)))
	((eq (car-safe a) 'hms)
	 (if (eq (car-safe b) 'hms)
	     (math-with-extra-prec 1
	       (math-div (math-from-hms a 'deg)
			 (math-from-hms b 'deg)))
	   (math-with-extra-prec 2
	     (math-to-hms (math-div (math-from-hms a 'deg) b) 'deg))))
	(t (calc-record-why "*Incompatible arguments for /" a b))))

(defun math-div-by-zero (a b)
  (if (math-infinitep a)
      (if (or (equal a '(var nan var-nan))
	      (equal b '(var uinf var-uinf))
	      (memq calc-infinite-mode '(-1 1)))
	  a
	'(var uinf var-uinf))
    (if calc-infinite-mode
	(if (math-zerop a)
	    '(var nan var-nan)
	  (if (eq calc-infinite-mode 1)
	      (math-mul a '(var inf var-inf))
	    (if (eq calc-infinite-mode -1)
		(math-mul a '(neg (var inf var-inf)))
	      (if (eq (car-safe a) 'intv)
		  '(intv 3 (neg (var inf var-inf)) (var inf var-inf))
		'(var uinf var-uinf)))))
      (math-reject-arg a "*Division by zero"))))

(defun math-div-zero (a b)
  (if (math-known-matrixp b)
      (if (math-vectorp b)
	  (math-map-vec-2 'math-div a b)
	(math-mimic-ident 0 b))
    (if (equal b '(var nan var-nan))
	b
      (if (and (eq (car-safe b) 'intv) (math-intv-constp b)
	       (not (math-posp b)) (not (math-negp b)))
	  (if calc-infinite-mode
	      (list 'intv 3
		    (if (and (math-zerop (nth 2 b))
			     (memq calc-infinite-mode '(1 -1)))
			(nth 2 b) '(neg (var inf var-inf)))
		    (if (and (math-zerop (nth 3 b))
			     (memq calc-infinite-mode '(1 -1)))
			(nth 3 b) '(var inf var-inf)))
	    (math-reject-arg b "*Division by zero"))
	a))))

(defun math-div-symb-fancy (a b)
  (or (and math-simplify-only
	   (not (equal a math-simplify-only))
	   (list '/ a b))
      (and (Math-equal-int b 1) a)
      (and (Math-equal-int b -1) (math-neg a))
      (and (Math-vectorp a) (math-known-scalarp b)
	   (math-map-vec-2 'math-div a b))
      (and (eq (car-safe b) '^)
	   (or (Math-looks-negp (nth 2 b)) (Math-equal-int a 1))
	   (math-mul a (math-normalize
			(list '^ (nth 1 b) (math-neg (nth 2 b))))))
      (and (eq (car-safe a) 'neg)
	   (math-neg (math-div (nth 1 a) b)))
      (and (eq (car-safe b) 'neg)
	   (math-neg (math-div a (nth 1 b))))
      (and (eq (car-safe a) '/)
	   (math-div (nth 1 a) (math-mul (nth 2 a) b)))
      (and (eq (car-safe b) '/)
	   (or (math-known-scalarp (nth 1 b) t)
	       (math-known-scalarp (nth 2 b) t))
	   (math-div (math-mul a (nth 2 b)) (nth 1 b)))
      (and (eq (car-safe b) 'frac)
	   (math-mul (math-make-frac (nth 2 b) (nth 1 b)) a))
      (and (eq (car-safe a) '+)
	   (or (Math-numberp (nth 1 a))
	       (Math-numberp (nth 2 a)))
	   (Math-numberp b)
	   (math-add (math-div (nth 1 a) b)
		     (math-div (nth 2 a) b)))
      (and (eq (car-safe a) '-)
	   (or (Math-numberp (nth 1 a))
	       (Math-numberp (nth 2 a)))
	   (Math-numberp b)
	   (math-sub (math-div (nth 1 a) b)
		     (math-div (nth 2 a) b)))
      (and (or (eq (car-safe a) '-)
	       (math-looks-negp a))
	   (math-looks-negp b)
	   (math-div (math-neg a) (math-neg b)))
      (and (eq (car-safe b) '-)
	   (math-looks-negp a)
	   (math-div (math-neg a) (math-neg b)))
      (and (eq (car-safe a) 'calcFunc-idn)
	   (= (length a) 2)
	   (or (and (eq (car-safe b) 'calcFunc-idn)
		    (= (length b) 2)
		    (list 'calcFunc-idn (math-div (nth 1 a) (nth 1 b))))
	       (and (math-known-scalarp b)
		    (list 'calcFunc-idn (math-div (nth 1 a) b)))
	       (and (math-known-matrixp b)
		    (math-div (nth 1 a) b))))
      (and (eq (car-safe b) 'calcFunc-idn)
	   (= (length b) 2)
	   (or (and (math-known-scalarp a)
		    (list 'calcFunc-idn (math-div a (nth 1 b))))
	       (and (math-known-matrixp a)
		    (math-div a (nth 1 b)))))
      (if (and calc-matrix-mode
	       (or (math-known-matrixp a) (math-known-matrixp b)))
	  (math-combine-prod a b nil t nil)
	(if (eq (car-safe a) '*)
	    (if (eq (car-safe b) '*)
		(let ((c (math-combine-prod (nth 1 a) (nth 1 b) nil t t)))
		  (and c
		       (math-div (math-mul c (nth 2 a)) (nth 2 b))))
	      (let ((c (math-combine-prod (nth 1 a) b nil t t)))
		(and c
		     (math-mul c (nth 2 a)))))
	  (if (eq (car-safe b) '*)
	      (let ((c (math-combine-prod a (nth 1 b) nil t t)))
		(and c
		     (math-div c (nth 2 b))))
	    (math-combine-prod a b nil t nil))))
      (and (math-infinitep a)
	   (if (math-infinitep b)
	       '(var nan var-nan)
	     (if (or (equal a '(var nan var-nan))
		     (equal a '(var uinf var-uinf)))
		 a
	       (if (equal a '(var inf var-inf))
		   (if (or (math-posp b)
			   (and (eq (car-safe b) 'intv)
				(math-zerop (nth 2 b))))
		       (if (and (eq (car-safe b) 'intv)
				(not (math-intv-constp b t)))
			   '(intv 3 0 (var inf var-inf))
			 a)
		     (if (or (math-negp b)
			     (and (eq (car-safe b) 'intv)
			      (math-zerop (nth 3 b))))
			 (if (and (eq (car-safe b) 'intv)
				  (not (math-intv-constp b t)))
			     '(intv 3 (neg (var inf var-inf)) 0)
			   (math-neg a))
		       (if (and (eq (car-safe b) 'intv)
				(math-negp (nth 2 b)) (math-posp (nth 3 b)))
			   '(intv 3 (neg (var inf var-inf))
				  (var inf var-inf)))))))))
      (and (math-infinitep b)
	   (if (equal b '(var nan var-nan))
	       b
	     (let ((calc-infinite-mode 1))
	       (math-mul-zero b a))))
      (list '/ a b)))


(defun calcFunc-mod (a b)
  (math-normalize (list '% a b)))

(defun math-mod-fancy (a b)
  (cond ((equal b '(var inf var-inf))
	 (if (or (math-posp a) (math-zerop a))
	     a
	   (if (math-negp a)
	       b
	     (if (eq (car-safe a) 'intv)
		 (if (math-negp (nth 2 a))
		     '(intv 3 0 (var inf var-inf))
		   a)
	       (list '% a b)))))
	((and (eq (car-safe a) 'mod) (Math-realp b) (math-posp b))
	 (math-make-mod (nth 1 a) b))
	((and (eq (car-safe a) 'intv) (math-intv-constp a t) (math-posp b))
	 (math-mod-intv a b))
	(t
	 (if (Math-anglep a)
	     (calc-record-why 'anglep b)
	   (calc-record-why 'anglep a))
	 (list '% a b))))


(defun calcFunc-pow (a b)
  (math-normalize (list '^ a b)))

(defun math-pow-of-zero (a b)
  "Raise A to the power of B, where A is a form of zero."
  (if (math-floatp b) (setq a (math-float a)))
  (cond
   ;; 0^0 = 1
   ((eq b 0)
    1)
   ;; 0^0.0, etc., are undetermined
   ((Math-zerop b)
    (if calc-infinite-mode
        '(var nan var-nan)
      (math-reject-arg (list '^ a b) "*Indeterminate form")))
   ;; 0^positive = 0
   ((math-posp b)
    a)
   ;; 0^negative is undefined (let math-div handle it)
   ((math-negp b)
    (math-div 1 a))
   ;; 0^infinity is undefined
   ((math-infinitep b)
    '(var nan var-nan))
   ;; Some intervals
   ((and (eq (car b) 'intv)
         calc-infinite-mode
         (math-negp (nth 2 b))
         (math-posp (nth 3 b)))
    '(intv 3 (neg (var inf var-inf)) (var inf var-inf)))
   ;; If none of the above, leave it alone.
   (t
    (list '^ a b))))

(defun math-pow-zero (a b)
  (if (eq (car-safe a) 'mod)
      (math-make-mod 1 (nth 2 a))
    (if (math-known-matrixp a)
	(math-mimic-ident 1 a)
      (if (math-infinitep a)
	  '(var nan var-nan)
	(if (and (eq (car a) 'intv) (math-intv-constp a)
		 (or (and (not (math-posp a)) (not (math-negp a)))
		     (not (math-intv-constp a t))))
	    '(intv 3 (neg (var inf var-inf)) (var inf var-inf))
	  (if (or (math-floatp a) (math-floatp b))
	      '(float 1 0) 1))))))

(defun math-pow-fancy (a b)
  (cond ((and (Math-numberp a) (Math-numberp b))
	 (or (if (memq (math-quarter-integer b) '(1 2 3))
		 (let ((sqrt (math-sqrt (if (math-floatp b)
					    (math-float a) a))))
		   (and (Math-numberp sqrt)
			(math-pow sqrt (math-mul 2 b))))
	       (and (eq (car b) 'frac)
		    (integerp (nth 2 b))
		    (<= (nth 2 b) 10)
		    (let ((root (math-nth-root a (nth 2 b))))
		      (and root (math-ipow root (nth 1 b))))))
	     (and (or (eq a 10) (equal a '(float 1 1)))
		  (math-num-integerp b)
		  (calcFunc-scf '(float 1 0) b))
	     (and calc-symbolic-mode
		  (list '^ a b))
	     (math-with-extra-prec 2
	       (math-exp-raw
		(math-float (math-mul b (math-ln-raw (math-float a))))))))
	((or (not (Math-objvecp a))
	     (not (Math-objectp b)))
	 (let (temp)
	   (cond ((and math-simplify-only
		       (not (equal a math-simplify-only)))
		  (list '^ a b))
		 ((and (eq (car-safe a) '*)
		       (or (math-known-num-integerp b)
			   (math-known-nonnegp (nth 1 a))
			   (math-known-nonnegp (nth 2 a))))
		  (math-mul (math-pow (nth 1 a) b)
			    (math-pow (nth 2 a) b)))
		 ((and (eq (car-safe a) '/)
		       (or (math-known-num-integerp b)
			   (math-known-nonnegp (nth 2 a))))
		  (math-div (math-pow (nth 1 a) b)
			    (math-pow (nth 2 a) b)))
		 ((and (eq (car-safe a) '/)
		       (math-known-nonnegp (nth 1 a))
		       (not (math-equal-int (nth 1 a) 1)))
		  (math-mul (math-pow (nth 1 a) b)
			    (math-pow (math-div 1 (nth 2 a)) b)))
		 ((and (eq (car-safe a) '^)
		       (or (math-known-num-integerp b)
			   (math-known-nonnegp (nth 1 a))))
		  (math-pow (nth 1 a) (math-mul (nth 2 a) b)))
		 ((and (eq (car-safe a) 'calcFunc-sqrt)
		       (or (math-known-num-integerp b)
			   (math-known-nonnegp (nth 1 a))))
		  (math-pow (nth 1 a) (math-div b 2)))
		 ((and (eq (car-safe a) '^)
		       (math-known-evenp (nth 2 a))
		       (memq (math-quarter-integer b) '(1 2 3))
		       (math-known-realp (nth 1 a)))
		  (math-abs (math-pow (nth 1 a) (math-mul (nth 2 a) b))))
		 ((and (math-looks-negp a)
		       (math-known-integerp b)
		       (setq temp (or (and (math-known-evenp b)
					   (math-pow (math-neg a) b))
				      (and (math-known-oddp b)
					   (math-neg (math-pow (math-neg a)
							       b))))))
		  temp)
		 ((and (eq (car-safe a) 'calcFunc-abs)
		       (math-known-realp (nth 1 a))
		       (math-known-evenp b))
		  (math-pow (nth 1 a) b))
		 ((math-infinitep a)
		  (cond ((equal a '(var nan var-nan))
			 a)
			((eq (car a) 'neg)
			 (math-mul (math-pow -1 b) (math-pow (nth 1 a) b)))
			((math-posp b)
			 a)
			((math-negp b)
			 (if (math-floatp b) '(float 0 0) 0))
			((and (eq (car-safe b) 'intv)
			      (math-intv-constp b))
			 '(intv 3 0 (var inf var-inf)))
			(t
			 '(var nan var-nan))))
		 ((math-infinitep b)
		  (let (scale)
		    (cond ((math-negp b)
			   (math-pow (math-div 1 a) (math-neg b)))
			  ((not (math-posp b))
			   '(var nan var-nan))
			  ((math-equal-int (setq scale (calcFunc-abssqr a)) 1)
			   '(var nan var-nan))
			  ((Math-lessp scale 1)
			   (if (math-floatp a) '(float 0 0) 0))
			  ((Math-lessp 1 a)
			   b)
			  ((Math-lessp a -1)
			   '(var uinf var-uinf))
			  ((and (eq (car a) 'intv)
				(math-intv-constp a))
			   (if (Math-lessp -1 a)
			       (if (math-equal-int (nth 3 a) 1)
				   '(intv 3 0 1)
				 '(intv 3 0 (var inf var-inf)))
			     '(intv 3 (neg (var inf var-inf))
				    (var inf var-inf))))
			  (t (list '^ a b)))))
		 ((and (eq (car-safe a) 'calcFunc-idn)
		       (= (length a) 2)
		       (math-known-num-integerp b))
		  (list 'calcFunc-idn (math-pow (nth 1 a) b)))
		 (t (if (Math-objectp a)
			(calc-record-why 'objectp b)
		      (calc-record-why 'objectp a))
		    (list '^ a b)))))
	((and (eq (car-safe a) 'sdev) (eq (car-safe b) 'sdev))
	 (if (and (math-constp a) (math-constp b))
	     (math-with-extra-prec 2
	       (let* ((ln (math-ln-raw (math-float (nth 1 a))))
		      (pow (math-exp-raw
			    (math-float (math-mul (nth 1 b) ln)))))
		 (math-make-sdev
		  pow
		  (math-mul
		   pow
		   (math-hypot (math-mul (nth 2 a)
					 (math-div (nth 1 b) (nth 1 a)))
			       (math-mul (nth 2 b) ln))))))
	   (let ((pow (math-pow (nth 1 a) (nth 1 b))))
	     (math-make-sdev
	      pow
	      (math-mul pow
			(math-hypot (math-mul (nth 2 a)
					      (math-div (nth 1 b) (nth 1 a)))
				    (math-mul (nth 2 b) (calcFunc-ln
							 (nth 1 a)))))))))
	((and (eq (car-safe a) 'sdev) (Math-numberp b))
	 (if (math-constp a)
	     (math-with-extra-prec 2
	       (let ((pow (math-pow (nth 1 a) (math-sub b 1))))
		 (math-make-sdev (math-mul pow (nth 1 a))
				 (math-mul pow (math-mul (nth 2 a) b)))))
	   (math-make-sdev (math-pow (nth 1 a) b)
			   (math-mul (math-pow (nth 1 a) (math-add b -1))
				     (math-mul (nth 2 a) b)))))
	((and (eq (car-safe b) 'sdev) (Math-numberp a))
	 (math-with-extra-prec 2
	   (let* ((ln (math-ln-raw (math-float a)))
		  (pow (calcFunc-exp (math-mul (nth 1 b) ln))))
	     (math-make-sdev pow (math-mul pow (math-mul (nth 2 b) ln))))))
	((and (eq (car-safe a) 'intv) (math-intv-constp a)
	      (Math-realp b)
	      (or (Math-natnump b)
		  (Math-posp (nth 2 a))
		  (and (math-zerop (nth 2 a))
		       (or (Math-posp b)
			   (and (Math-integerp b) calc-infinite-mode)))
		  (Math-negp (nth 3 a))
		  (and (math-zerop (nth 3 a))
		       (or (Math-posp b)
			   (and (Math-integerp b) calc-infinite-mode)))))
	 (if (math-evenp b)
	     (setq a (math-abs a)))
	 (let ((calc-infinite-mode (if (math-zerop (nth 3 a)) -1 1)))
	   (math-sort-intv (nth 1 a)
			   (math-pow (nth 2 a) b)
			   (math-pow (nth 3 a) b))))
	((and (eq (car-safe b) 'intv) (math-intv-constp b)
	      (Math-realp a) (Math-posp a))
	 (math-sort-intv (nth 1 b)
			 (math-pow a (nth 2 b))
			 (math-pow a (nth 3 b))))
	((and (eq (car-safe a) 'intv) (math-intv-constp a)
	      (eq (car-safe b) 'intv) (math-intv-constp b)
	      (or (and (not (Math-negp (nth 2 a)))
		       (not (Math-negp (nth 2 b))))
		  (and (Math-posp (nth 2 a))
		       (not (Math-posp (nth 3 b))))))
	 (let ((lo (math-pow a (nth 2 b)))
	       (hi (math-pow a (nth 3 b))))
	   (or (eq (car-safe lo) 'intv)
	       (setq lo (list 'intv (if (memq (nth 1 b) '(2 3)) 3 0) lo lo)))
	   (or (eq (car-safe hi) 'intv)
	       (setq hi (list 'intv (if (memq (nth 1 b) '(1 3)) 3 0) hi hi)))
	   (math-combine-intervals
	    (nth 2 lo) (and (or (memq (nth 1 b) '(2 3))
				(math-infinitep (nth 2 lo)))
			    (memq (nth 1 lo) '(2 3)))
	    (nth 3 lo) (and (or (memq (nth 1 b) '(2 3))
				(math-infinitep (nth 3 lo)))
			    (memq (nth 1 lo) '(1 3)))
	    (nth 2 hi) (and (or (memq (nth 1 b) '(1 3))
				(math-infinitep (nth 2 hi)))
			    (memq (nth 1 hi) '(2 3)))
	    (nth 3 hi) (and (or (memq (nth 1 b) '(1 3))
				(math-infinitep (nth 3 hi)))
			    (memq (nth 1 hi) '(1 3))))))
	((and (eq (car-safe a) 'mod) (eq (car-safe b) 'mod)
	      (equal (nth 2 a) (nth 2 b)))
	 (math-make-mod (math-pow-mod (nth 1 a) (nth 1 b) (nth 2 a))
			(nth 2 a)))
	((and (eq (car-safe a) 'mod) (Math-anglep b))
	 (math-make-mod (math-pow-mod (nth 1 a) b (nth 2 a)) (nth 2 a)))
	((and (eq (car-safe b) 'mod) (Math-anglep a))
	 (math-make-mod (math-pow-mod a (nth 1 b) (nth 2 b)) (nth 2 b)))
	((not (Math-numberp a))
	 (math-reject-arg a 'numberp))
	(t
	 (math-reject-arg b 'numberp))))

(defun math-quarter-integer (x)
  (if (Math-integerp x)
      0
    (if (math-negp x)
	(progn
	  (setq x (math-quarter-integer (math-neg x)))
	  (and x (- 4 x)))
      (if (eq (car x) 'frac)
	  (if (eq (nth 2 x) 2)
	      2
	    (and (eq (nth 2 x) 4)
		 (progn
		   (setq x (nth 1 x))
		   (% (if (consp x) (nth 1 x) x) 4))))
	(if (eq (car x) 'float)
	    (if (>= (nth 2 x) 0)
		0
	      (if (= (nth 2 x) -1)
		  (progn
		    (setq x (nth 1 x))
		    (and (= (% (if (consp x) (nth 1 x) x) 10) 5) 2))
		(if (= (nth 2 x) -2)
		    (progn
		      (setq x (nth 1 x)
			    x (% (if (consp x) (nth 1 x) x) 100))
		      (if (= x 25) 1
			(if (= x 75) 3)))))))))))

;;; This assumes A < M and M > 0.
(defun math-pow-mod (a b m)   ; [R R R R]
  (if (and (Math-integerp a) (Math-integerp b) (Math-integerp m))
      (if (Math-negp b)
	  (math-div-mod 1 (math-pow-mod a (Math-integer-neg b) m) m)
	(if (eq m 1)
	    0
	  (math-pow-mod-step a b m)))
    (math-mod (math-pow a b) m)))

(defun math-pow-mod-step (a n m)   ; [I I I I]
  (math-working "pow" a)
  (let ((val (cond
	      ((eq n 0) 1)
	      ((eq n 1) a)
	      (t
	       (let ((rest (math-pow-mod-step
			    (math-imod (math-mul a a) m)
			    (math-div2 n)
			    m)))
		 (if (math-evenp n)
		     rest
		   (math-mod (math-mul a rest) m)))))))
    (math-working "pow" val)
    val))


;;; Compute the minimum of two real numbers.  [R R R] [Public]
(defun math-min (a b)
  (if (and (consp a) (eq (car a) 'intv))
      (if (and (consp b) (eq (car b) 'intv))
	  (let ((lo (nth 2 a))
		(lom (memq (nth 1 a) '(2 3)))
		(hi (nth 3 a))
		(him (memq (nth 1 a) '(1 3)))
		res)
	    (if (= (setq res (math-compare (nth 2 b) lo)) -1)
		(setq lo (nth 2 b) lom (memq (nth 1 b) '(2 3)))
	      (if (= res 0)
		  (setq lom (or lom (memq (nth 1 b) '(2 3))))))
	    (if (= (setq res (math-compare (nth 3 b) hi)) -1)
		(setq hi (nth 3 b) him (memq (nth 1 b) '(1 3)))
	      (if (= res 0)
		  (setq him (or him (memq (nth 1 b) '(1 3))))))
	    (math-make-intv (+ (if lom 2 0) (if him 1 0)) lo hi))
	(math-min a (list 'intv 3 b b)))
    (if (and (consp b) (eq (car b) 'intv))
	(math-min (list 'intv 3 a a) b)
      (let ((res (math-compare a b)))
	(if (= res 1)
	    b
	  (if (= res 2)
	      '(var nan var-nan)
	    a))))))

(defun calcFunc-min (&optional a &rest b)
  (if (not a)
      '(var inf var-inf)
    (if (not (or (Math-anglep a) (eq (car a) 'date)
		 (and (eq (car a) 'intv) (math-intv-constp a))
		 (math-infinitep a)))
	(math-reject-arg a 'anglep))
    (math-min-list a b)))

(defun math-min-list (a b)
  (if b
      (if (or (Math-anglep (car b)) (eq (car b) 'date)
	      (and (eq (car (car b)) 'intv) (math-intv-constp (car b)))
	      (math-infinitep (car b)))
	  (math-min-list (math-min a (car b)) (cdr b))
	(math-reject-arg (car b) 'anglep))
    a))

;;; Compute the maximum of two real numbers.  [R R R] [Public]
(defun math-max (a b)
  (if (or (and (consp a) (eq (car a) 'intv))
	  (and (consp b) (eq (car b) 'intv)))
      (math-neg (math-min (math-neg a) (math-neg b)))
    (let ((res (math-compare a b)))
      (if (= res -1)
	  b
	(if (= res 2)
	      '(var nan var-nan)
	  a)))))

(defun calcFunc-max (&optional a &rest b)
  (if (not a)
      '(neg (var inf var-inf))
    (if (not (or (Math-anglep a) (eq (car a) 'date)
		 (and (eq (car a) 'intv) (math-intv-constp a))
		 (math-infinitep a)))
	(math-reject-arg a 'anglep))
    (math-max-list a b)))

(defun math-max-list (a b)
  (if b
      (if (or (Math-anglep (car b)) (eq (car b) 'date)
	      (and (eq (car (car b)) 'intv) (math-intv-constp (car b)))
	      (math-infinitep (car b)))
	  (math-max-list (math-max a (car b)) (cdr b))
	(math-reject-arg (car b) 'anglep))
    a))


;;; Compute the absolute value of A.  [O O; r r] [Public]
(defun math-abs (a)
  (cond ((Math-negp a)
	 (math-neg a))
	((Math-anglep a)
	 a)
	((eq (car a) 'cplx)
	 (math-hypot (nth 1 a) (nth 2 a)))
	((eq (car a) 'polar)
	 (nth 1 a))
	((eq (car a) 'vec)
	 (if (cdr (cdr (cdr a)))
	     (math-sqrt (calcFunc-abssqr a))
	   (if (cdr (cdr a))
	       (math-hypot (nth 1 a) (nth 2 a))
	     (if (cdr a)
		 (math-abs (nth 1 a))
	       a))))
	((eq (car a) 'sdev)
	 (list 'sdev (math-abs (nth 1 a)) (nth 2 a)))
	((and (eq (car a) 'intv) (math-intv-constp a))
	 (if (Math-posp a)
	     a
	   (let* ((nlo (math-neg (nth 2 a)))
		  (res (math-compare nlo (nth 3 a))))
	     (cond ((= res 1)
		    (math-make-intv (if (memq (nth 1 a) '(0 1)) 2 3) 0 nlo))
		   ((= res 0)
		    (math-make-intv (if (eq (nth 1 a) 0) 2 3) 0 nlo))
		   (t
		    (math-make-intv (if (memq (nth 1 a) '(0 2)) 2 3)
				    0 (nth 3 a)))))))
	((math-looks-negp a)
	 (list 'calcFunc-abs (math-neg a)))
	((let ((signs (math-possible-signs a)))
	   (or (and (memq signs '(2 4 6)) a)
	       (and (memq signs '(1 3)) (math-neg a)))))
	((let ((inf (math-infinitep a)))
	   (and inf
		(if (equal inf '(var nan var-nan))
		    inf
		  '(var inf var-inf)))))
	(t (calc-record-why 'numvecp a)
	   (list 'calcFunc-abs a))))

(defalias 'calcFunc-abs 'math-abs)

(defun math-float-fancy (a)
  (cond ((eq (car a) 'intv)
	 (cons (car a) (cons (nth 1 a) (mapcar 'math-float (nthcdr 2 a)))))
	((and (memq (car a) '(* /))
	      (math-numberp (nth 1 a)))
	 (list (car a) (math-float (nth 1 a))
	       (list 'calcFunc-float (nth 2 a))))
	((and (eq (car a) '/)
	      (eq (car (nth 1 a)) '*)
	      (math-numberp (nth 1 (nth 1 a))))
	 (list '* (math-float (nth 1 (nth 1 a)))
	       (list 'calcFunc-float (list '/ (nth 2 (nth 1 a)) (nth 2 a)))))
	((math-infinitep a) a)
	((eq (car a) 'calcFunc-float) a)
	((let ((func (assq (car a) '((calcFunc-floor  . calcFunc-ffloor)
				     (calcFunc-ceil   . calcFunc-fceil)
				     (calcFunc-trunc  . calcFunc-ftrunc)
				     (calcFunc-round  . calcFunc-fround)
				     (calcFunc-rounde . calcFunc-frounde)
				     (calcFunc-roundu . calcFunc-froundu)))))
	   (and func (cons (cdr func) (cdr a)))))
	(t (math-reject-arg a 'objectp))))

(defalias 'calcFunc-float 'math-float)

;; The variable math-trunc-prec is local to math-trunc in calc-misc.el, 
;; but used by math-trunc-fancy which is called by math-trunc.
(defvar math-trunc-prec)

(defun math-trunc-fancy (a)
  (cond ((eq (car a) 'frac) (math-quotient (nth 1 a) (nth 2 a)))
	((eq (car a) 'cplx) (math-trunc (nth 1 a)))
	((eq (car a) 'polar) (math-trunc (math-complex a)))
	((eq (car a) 'hms) (list 'hms (nth 1 a) 0 0))
	((eq (car a) 'date) (list 'date (math-trunc (nth 1 a))))
	((eq (car a) 'mod)
	 (if (math-messy-integerp (nth 2 a))
	     (math-trunc (math-make-mod (nth 1 a) (math-trunc (nth 2 a))))
	   (math-make-mod (math-trunc (nth 1 a)) (nth 2 a))))
	((eq (car a) 'intv)
	 (math-make-intv (+ (if (and (equal (nth 2 a) '(neg (var inf var-inf)))
				     (memq (nth 1 a) '(0 1)))
				0 2)
			    (if (and (equal (nth 3 a) '(var inf var-inf))
				     (memq (nth 1 a) '(0 2)))
				0 1))
			 (if (and (Math-negp (nth 2 a))
				  (Math-num-integerp (nth 2 a))
				  (memq (nth 1 a) '(0 1)))
			     (math-add (math-trunc (nth 2 a)) 1)
			   (math-trunc (nth 2 a)))
			 (if (and (Math-posp (nth 3 a))
				  (Math-num-integerp (nth 3 a))
				  (memq (nth 1 a) '(0 2)))
			     (math-add (math-trunc (nth 3 a)) -1)
			   (math-trunc (nth 3 a)))))
	((math-provably-integerp a) a)
	((Math-vectorp a)
	 (math-map-vec (function (lambda (x) (math-trunc x math-trunc-prec))) a))
	((math-infinitep a)
	 (if (or (math-posp a) (math-negp a))
	     a
	   '(var nan var-nan)))
	((math-to-integer a))
	(t (math-reject-arg a 'numberp))))

(defun math-trunc-special (a prec)
  (if (Math-messy-integerp prec)
      (setq prec (math-trunc prec)))
  (or (integerp prec)
      (math-reject-arg prec 'fixnump))
  (if (and (<= prec 0)
	   (math-provably-integerp a))
      a
    (calcFunc-scf (math-trunc (let ((calc-prefer-frac t))
				(calcFunc-scf a prec)))
		  (- prec))))

(defun math-to-integer (a)
  (let ((func (assq (car-safe a) '((calcFunc-ffloor  . calcFunc-floor)
				   (calcFunc-fceil   . calcFunc-ceil)
				   (calcFunc-ftrunc  . calcFunc-trunc)
				   (calcFunc-fround  . calcFunc-round)
				   (calcFunc-frounde . calcFunc-rounde)
				   (calcFunc-froundu . calcFunc-roundu)))))
    (and func (= (length a) 2)
	 (cons (cdr func) (cdr a)))))

(defun calcFunc-ftrunc (a &optional prec)
  (if (and (Math-messy-integerp a)
	   (or (not prec) (and (integerp prec)
			       (<= prec 0))))
      a
    (math-float (math-trunc a prec))))

;; The variable math-floor-prec is local to math-floor in calc-misc.el,
;; but used by math-floor-fancy which is called by math-floor.
(defvar math-floor-prec)

(defun math-floor-fancy (a)
  (cond ((math-provably-integerp a) a)
	((eq (car a) 'hms)
	 (if (or (math-posp a)
		 (and (math-zerop (nth 2 a))
		      (math-zerop (nth 3 a))))
	     (math-trunc a)
	   (math-add (math-trunc a) -1)))
	((eq (car a) 'date) (list 'date (math-floor (nth 1 a))))
	((eq (car a) 'intv)
	 (math-make-intv (+ (if (and (equal (nth 2 a) '(neg (var inf var-inf)))
				     (memq (nth 1 a) '(0 1)))
				0 2)
			    (if (and (equal (nth 3 a) '(var inf var-inf))
				     (memq (nth 1 a) '(0 2)))
				0 1))
			 (math-floor (nth 2 a))
			 (if (and (Math-num-integerp (nth 3 a))
				  (memq (nth 1 a) '(0 2)))
			     (math-add (math-floor (nth 3 a)) -1)
			   (math-floor (nth 3 a)))))
	((Math-vectorp a)
	 (math-map-vec (function (lambda (x) (math-floor x math-floor-prec))) a))
	((math-infinitep a)
	 (if (or (math-posp a) (math-negp a))
	     a
	   '(var nan var-nan)))
	((math-to-integer a))
	(t (math-reject-arg a 'anglep))))

(defun math-floor-special (a prec)
  (if (Math-messy-integerp prec)
      (setq prec (math-trunc prec)))
  (or (integerp prec)
      (math-reject-arg prec 'fixnump))
  (if (and (<= prec 0)
	   (math-provably-integerp a))
      a
    (calcFunc-scf (math-floor (let ((calc-prefer-frac t))
				(calcFunc-scf a prec)))
		  (- prec))))

(defun calcFunc-ffloor (a &optional prec)
  (if (and (Math-messy-integerp a)
	   (or (not prec) (and (integerp prec)
			       (<= prec 0))))
      a
    (math-float (math-floor a prec))))

;;; Coerce A to be an integer (by truncation toward plus infinity).  [I N]
(defun math-ceiling (a &optional prec)   ;  [Public]
  (cond (prec
	 (if (Math-messy-integerp prec)
	     (setq prec (math-trunc prec)))
	 (or (integerp prec)
	     (math-reject-arg prec 'fixnump))
	 (if (and (<= prec 0)
		  (math-provably-integerp a))
	     a
	   (calcFunc-scf (math-ceiling (let ((calc-prefer-frac t))
					 (calcFunc-scf a prec)))
			 (- prec))))
	((Math-integerp a) a)
	((Math-messy-integerp a) (math-trunc a))
	((Math-realp a)
	 (if (Math-posp a)
	     (math-add (math-trunc a) 1)
	   (math-trunc a)))
	((math-provably-integerp a) a)
	((eq (car a) 'hms)
	 (if (or (math-negp a)
		 (and (math-zerop (nth 2 a))
		      (math-zerop (nth 3 a))))
	     (math-trunc a)
	   (math-add (math-trunc a) 1)))
	((eq (car a) 'date) (list 'date (math-ceiling (nth 1 a))))
	((eq (car a) 'intv)
	 (math-make-intv (+ (if (and (equal (nth 2 a) '(neg (var inf var-inf)))
				     (memq (nth 1 a) '(0 1)))
				0 2)
			    (if (and (equal (nth 3 a) '(var inf var-inf))
				     (memq (nth 1 a) '(0 2)))
				0 1))
			 (if (and (Math-num-integerp (nth 2 a))
				  (memq (nth 1 a) '(0 1)))
			     (math-add (math-floor (nth 2 a)) 1)
			   (math-ceiling (nth 2 a)))
			 (math-ceiling (nth 3 a))))
	((Math-vectorp a)
	 (math-map-vec (function (lambda (x) (math-ceiling x prec))) a))
	((math-infinitep a)
	 (if (or (math-posp a) (math-negp a))
	     a
	   '(var nan var-nan)))
	((math-to-integer a))
	(t (math-reject-arg a 'anglep))))

(defalias 'calcFunc-ceil 'math-ceiling)

(defun calcFunc-fceil (a &optional prec)
  (if (and (Math-messy-integerp a)
	   (or (not prec) (and (integerp prec)
			       (<= prec 0))))
      a
    (math-float (math-ceiling a prec))))

(defvar math-rounding-mode nil)

;;; Coerce A to be an integer (by rounding to nearest integer).  [I N] [Public]
(defun math-round (a &optional prec)
  (cond (prec
	 (if (Math-messy-integerp prec)
	     (setq prec (math-trunc prec)))
	 (or (integerp prec)
	     (math-reject-arg prec 'fixnump))
	 (if (and (<= prec 0)
		  (math-provably-integerp a))
	     a
	   (calcFunc-scf (math-round (let ((calc-prefer-frac t))
				       (calcFunc-scf a prec)))
			 (- prec))))
	((Math-anglep a)
	 (if (Math-num-integerp a)
	     (math-trunc a)
	   (if (and (Math-negp a) (not (eq math-rounding-mode 'up)))
	       (math-neg (math-round (math-neg a)))
	     (setq a (let ((calc-angle-mode 'deg))   ; in case of HMS forms
		       (math-add a (if (Math-ratp a)
				       '(frac 1 2)
				     '(float 5 -1)))))
	     (if (and (Math-num-integerp a) (eq math-rounding-mode 'even))
		 (progn
		   (setq a (math-floor a))
		   (or (math-evenp a)
		       (setq a (math-sub a 1)))
		   a)
	       (math-floor a)))))
	((math-provably-integerp a) a)
	((eq (car a) 'date) (list 'date (math-round (nth 1 a))))
	((eq (car a) 'intv)
	 (math-floor (math-add a '(frac 1 2))))
	((Math-vectorp a)
	 (math-map-vec (function (lambda (x) (math-round x prec))) a))
	((math-infinitep a)
	 (if (or (math-posp a) (math-negp a))
	     a
	   '(var nan var-nan)))
	((math-to-integer a))
	(t (math-reject-arg a 'anglep))))

(defalias 'calcFunc-round 'math-round)

(defsubst calcFunc-rounde (a &optional prec)
  (let ((math-rounding-mode 'even))
    (math-round a prec)))

(defsubst calcFunc-roundu (a &optional prec)
  (let ((math-rounding-mode 'up))
    (math-round a prec)))

(defun calcFunc-fround (a &optional prec)
  (if (and (Math-messy-integerp a)
	   (or (not prec) (and (integerp prec)
			       (<= prec 0))))
      a
    (math-float (math-round a prec))))

(defsubst calcFunc-frounde (a &optional prec)
  (let ((math-rounding-mode 'even))
    (calcFunc-fround a prec)))

(defsubst calcFunc-froundu (a &optional prec)
  (let ((math-rounding-mode 'up))
    (calcFunc-fround a prec)))

;;; Pull floating-point values apart into mantissa and exponent.
(defun calcFunc-mant (x)
  (if (Math-realp x)
      (if (or (Math-ratp x)
	      (eq (nth 1 x) 0))
	  x
	(list 'float (nth 1 x) (- 1 (math-numdigs (nth 1 x)))))
    (calc-record-why 'realp x)
    (list 'calcFunc-mant x)))

(defun calcFunc-xpon (x)
  (if (Math-realp x)
      (if (or (Math-ratp x)
	      (eq (nth 1 x) 0))
	  0
	(math-normalize (+ (nth 2 x) (1- (math-numdigs (nth 1 x))))))
    (calc-record-why 'realp x)
    (list 'calcFunc-xpon x)))

(defun calcFunc-scf (x n)
  (if (integerp n)
      (cond ((eq n 0)
	     x)
	    ((Math-integerp x)
	     (if (> n 0)
		 (math-scale-int x n)
	       (math-div x (math-scale-int 1 (- n)))))
	    ((eq (car x) 'frac)
	     (if (> n 0)
		 (math-make-frac (math-scale-int (nth 1 x) n) (nth 2 x))
	       (math-make-frac (nth 1 x) (math-scale-int (nth 2 x) (- n)))))
	    ((eq (car x) 'float)
	     (math-make-float (nth 1 x) (+ (nth 2 x) n)))
	    ((memq (car x) '(cplx sdev))
	     (math-normalize
	      (list (car x)
		    (calcFunc-scf (nth 1 x) n)
		    (calcFunc-scf (nth 2 x) n))))
	    ((memq (car x) '(polar mod))
	     (math-normalize
	      (list (car x)
		    (calcFunc-scf (nth 1 x) n)
		    (nth 2 x))))
	    ((eq (car x) 'intv)
	     (math-normalize
	      (list (car x)
		    (nth 1 x)
		    (calcFunc-scf (nth 2 x) n)
		    (calcFunc-scf (nth 3 x) n))))
	    ((eq (car x) 'vec)
	     (math-map-vec (function (lambda (x) (calcFunc-scf x n))) x))
	    ((math-infinitep x)
	     x)
	    (t
	     (calc-record-why 'realp x)
	     (list 'calcFunc-scf x n)))
    (if (math-messy-integerp n)
	(if (< (nth 2 n) 10)
	    (calcFunc-scf x (math-trunc n))
	  (math-overflow n))
      (if (math-integerp n)
	  (math-overflow n)
	(calc-record-why 'integerp n)
	(list 'calcFunc-scf x n)))))


(defun calcFunc-incr (x &optional step relative-to)
  (or step (setq step 1))
  (cond ((not (Math-integerp step))
	 (math-reject-arg step 'integerp))
	((Math-integerp x)
	 (math-add x step))
	((eq (car x) 'float)
	 (if (and (math-zerop x)
		  (eq (car-safe relative-to) 'float))
	     (math-mul step
		       (calcFunc-scf relative-to (- 1 calc-internal-prec)))
	   (math-add-float x (math-make-float
			      step
			      (+ (nth 2 x)
				 (- (math-numdigs (nth 1 x))
				    calc-internal-prec))))))
	((eq (car x) 'date)
	 (if (Math-integerp (nth 1 x))
	     (math-add x step)
	   (math-add x (list 'hms 0 0 step))))
	(t
	 (math-reject-arg x 'realp))))

(defsubst calcFunc-decr (x &optional step relative-to)
  (calcFunc-incr x (math-neg (or step 1)) relative-to))

(defun calcFunc-percent (x)
  (if (math-objectp x)
      (let ((calc-prefer-frac nil))
	(math-div x 100))
    (list 'calcFunc-percent x)))

(defun calcFunc-relch (x y)
  (if (and (math-objectp x) (math-objectp y))
      (math-div (math-sub y x) x)
    (list 'calcFunc-relch x y)))

;;; Compute the absolute value squared of A.  [F N] [Public]
(defun calcFunc-abssqr (a)
  (cond ((Math-realp a)
	 (math-mul a a))
	((eq (car a) 'cplx)
	 (math-add (math-sqr (nth 1 a))
		   (math-sqr (nth 2 a))))
	((eq (car a) 'polar)
	 (math-sqr (nth 1 a)))
	((and (memq (car a) '(sdev intv)) (math-constp a))
	 (math-sqr (math-abs a)))
	((eq (car a) 'vec)
	 (math-reduce-vec 'math-add (math-map-vec 'calcFunc-abssqr a)))
	((math-known-realp a)
	 (math-pow a 2))
	((let ((inf (math-infinitep a)))
	   (and inf
		(math-mul (calcFunc-abssqr (math-infinite-dir a inf)) inf))))
	(t (calc-record-why 'numvecp a)
	   (list 'calcFunc-abssqr a))))

(defsubst math-sqr (a)
  (math-mul a a))

;;;; Number theory.

(defun calcFunc-idiv (a b)   ; [I I I] [Public]
  (cond ((and (Math-natnump a) (Math-natnump b) (not (eq b 0)))
	 (math-quotient a b))
	((Math-realp a)
	 (if (Math-realp b)
	     (let ((calc-prefer-frac t))
	       (math-floor (math-div a b)))
	   (math-reject-arg b 'realp)))
	((eq (car-safe a) 'hms)
	 (if (eq (car-safe b) 'hms)
	     (let ((calc-prefer-frac t))
	       (math-floor (math-div a b)))
	   (math-reject-arg b 'hmsp)))
	((and (or (eq (car-safe a) 'intv) (Math-realp a))
	      (or (eq (car-safe b) 'intv) (Math-realp b)))
	 (math-floor (math-div a b)))
	((or (math-infinitep a)
	     (math-infinitep b))
	 (math-div a b))
	(t (math-reject-arg a 'anglep))))


;;; Combine two terms being added, if possible.
(defun math-combine-sum (a b nega negb scalar-okay)
  (if (and scalar-okay (Math-objvecp a) (Math-objvecp b))
      (math-add-or-sub a b nega negb)
    (let ((amult 1) (bmult 1))
      (and (consp a)
	   (cond ((and (eq (car a) '*)
		       (Math-objectp (nth 1 a)))
		  (setq amult (nth 1 a)
			a (nth 2 a)))
		 ((and (eq (car a) '/)
		       (Math-objectp (nth 2 a)))
		  (setq amult (if (Math-integerp (nth 2 a))
				  (list 'frac 1 (nth 2 a))
				(math-div 1 (nth 2 a)))
			a (nth 1 a)))
		 ((eq (car a) 'neg)
		  (setq amult -1
			a (nth 1 a)))))
      (and (consp b)
	   (cond ((and (eq (car b) '*)
		       (Math-objectp (nth 1 b)))
		  (setq bmult (nth 1 b)
			b (nth 2 b)))
		 ((and (eq (car b) '/)
		       (Math-objectp (nth 2 b)))
		  (setq bmult (if (Math-integerp (nth 2 b))
				  (list 'frac 1 (nth 2 b))
				(math-div 1 (nth 2 b)))
			b (nth 1 b)))
		 ((eq (car b) 'neg)
		  (setq bmult -1
			b (nth 1 b)))))
      (and (if math-simplifying
	       (Math-equal a b)
	     (equal a b))
	   (progn
	     (if nega (setq amult (math-neg amult)))
	     (if negb (setq bmult (math-neg bmult)))
	     (setq amult (math-add amult bmult))
	     (math-mul amult a))))))

(defun math-add-or-sub (a b aneg bneg)
  (if aneg (setq a (math-neg a)))
  (if bneg (setq b (math-neg b)))
  (if (or (Math-vectorp a) (Math-vectorp b))
      (math-normalize (list '+ a b))
    (math-add a b)))

(defvar math-combine-prod-e '(var e var-e))

;;; The following is expanded out four ways for speed.

;; math-unit-prefixes is defined in calc-units.el,
;; but used here.
(defvar math-unit-prefixes)

(defun math-combine-prod (a b inva invb scalar-okay)
  (cond
   ((or (and inva (Math-zerop a))
	(and invb (Math-zerop b)))
    nil)
   ((and scalar-okay (Math-objvecp a) (Math-objvecp b))
    (setq a (math-mul-or-div a b inva invb))
    (and (Math-objvecp a)
	 a))
   ((and (eq (car-safe a) '^)
	 inva
	 (math-looks-negp (nth 2 a)))
    (math-mul (math-pow (nth 1 a) (math-neg (nth 2 a))) b))
   ((and (eq (car-safe b) '^)
	 invb
	 (math-looks-negp (nth 2 b)))
    (math-mul a (math-pow (nth 1 b) (math-neg (nth 2 b)))))
   (t (let ((apow 1) (bpow 1))
	(and (consp a)
	     (cond ((and (eq (car a) '^)
			 (or math-simplifying
			     (Math-numberp (nth 2 a))))
		    (setq apow (nth 2 a)
			  a (nth 1 a)))
		   ((eq (car a) 'calcFunc-sqrt)
		    (setq apow '(frac 1 2)
			  a (nth 1 a)))
		   ((and (eq (car a) 'calcFunc-exp)
			 (or math-simplifying
			     (Math-numberp (nth 1 a))))
		    (setq apow (nth 1 a)
			  a math-combine-prod-e))))
	(and (consp a) (eq (car a) 'frac)
	     (Math-lessp (nth 1 a) (nth 2 a))
	     (setq a (math-div 1 a) apow (math-neg apow)))
	(and (consp b)
	     (cond ((and (eq (car b) '^)
			 (or math-simplifying
			     (Math-numberp (nth 2 b))))
		    (setq bpow (nth 2 b)
			  b (nth 1 b)))
		   ((eq (car b) 'calcFunc-sqrt)
		    (setq bpow '(frac 1 2)
			  b (nth 1 b)))
		   ((and (eq (car b) 'calcFunc-exp)
			 (or math-simplifying
			     (Math-numberp (nth 1 b))))
		    (setq bpow (nth 1 b)
			  b math-combine-prod-e))))
	(and (consp b) (eq (car b) 'frac)
	     (Math-lessp (nth 1 b) (nth 2 b))
	     (setq b (math-div 1 b) bpow (math-neg bpow)))
	(if inva (setq apow (math-neg apow)))
	(if invb (setq bpow (math-neg bpow)))
	(or (and (if math-simplifying
		     (math-commutative-equal a b)
		   (equal a b))
		 (let ((sumpow (math-add apow bpow)))
		   (and (or (not (Math-integerp a))
			    (Math-zerop sumpow)
			    (eq (eq (car-safe apow) 'frac)
				(eq (car-safe bpow) 'frac)))
			(progn
			  (and (math-looks-negp sumpow)
			       (Math-ratp a) (Math-posp a)
			       (setq a (math-div 1 a)
				     sumpow (math-neg sumpow)))
			  (cond ((equal sumpow '(frac 1 2))
				 (list 'calcFunc-sqrt a))
				((equal sumpow '(frac -1 2))
				 (math-div 1 (list 'calcFunc-sqrt a)))
				((and (eq a math-combine-prod-e)
				      (eq a b))
				 (list 'calcFunc-exp sumpow))
				(t
				 (condition-case err
				     (math-pow a sumpow)
				   (inexact-result (list '^ a sumpow)))))))))
	    (and math-simplifying-units
		 math-combining-units
		 (let* ((ua (math-check-unit-name a))
			ub)
		   (and ua
			(eq ua (setq ub (math-check-unit-name b)))
			(progn
			  (setq ua (if (eq (nth 1 a) (car ua))
				       1
				     (nth 1 (assq (aref (symbol-name (nth 1 a))
							0)
						  math-unit-prefixes)))
				ub (if (eq (nth 1 b) (car ub))
				       1
				     (nth 1 (assq (aref (symbol-name (nth 1 b))
							0)
						  math-unit-prefixes))))
			  (if (Math-lessp ua ub)
			      (let (temp)
				(setq temp a a b b temp
				      temp ua ua ub ub temp
				      temp apow apow bpow bpow temp)))
			  (math-mul (math-pow (math-div ua ub) apow)
				    (math-pow b (math-add apow bpow)))))))
	    (and (equal apow bpow)
		 (Math-natnump a) (Math-natnump b)
		 (cond ((equal apow '(frac 1 2))
			(list 'calcFunc-sqrt (math-mul a b)))
		       ((equal apow '(frac -1 2))
			(math-div 1 (list 'calcFunc-sqrt (math-mul a b))))
		       (t
			(setq a (math-mul a b))
			(condition-case err
			    (math-pow a apow)
			  (inexact-result (list '^ a apow)))))))))))

(defun math-mul-or-div (a b ainv binv)
  (if (or (Math-vectorp a) (Math-vectorp b))
      (math-normalize
       (if ainv
	   (if binv
	       (list '/ (math-div 1 a) b)
	     (list '/ b a))
	 (if binv
	     (list '/ a b)
	   (list '* a b))))
    (if ainv
	(if binv
	    (math-div (math-div 1 a) b)
	  (math-div b a))
      (if binv
	  (math-div a b)
	(math-mul a b)))))

;; The variable math-com-bterms is local to math-commutative-equal,
;; but is used by math-commutative collect, which is called by
;; math-commutative-equal.
(defvar math-com-bterms)

(defun math-commutative-equal (a b)
  (if (memq (car-safe a) '(+ -))
      (and (memq (car-safe b) '(+ -))
	   (let ((math-com-bterms nil) aterms p)
	     (math-commutative-collect b nil)
	     (setq aterms math-com-bterms math-com-bterms nil)
	     (math-commutative-collect a nil)
	     (and (= (length aterms) (length math-com-bterms))
		  (progn
		    (while (and aterms
				(progn
				  (setq p math-com-bterms)
				  (while (and p (not (equal (car aterms)
							    (car p))))
				    (setq p (cdr p)))
				  p))
		      (setq math-com-bterms (delq (car p) math-com-bterms)
			    aterms (cdr aterms)))
		    (not aterms)))))
    (equal a b)))

(defun math-commutative-collect (b neg)
  (if (eq (car-safe b) '+)
      (progn
	(math-commutative-collect (nth 1 b) neg)
	(math-commutative-collect (nth 2 b) neg))
    (if (eq (car-safe b) '-)
	(progn
	  (math-commutative-collect (nth 1 b) neg)
	  (math-commutative-collect (nth 2 b) (not neg)))
      (setq math-com-bterms (cons (if neg (math-neg b) b) math-com-bterms)))))

(provide 'calc-arith)

;;; arch-tag: 6c396b5b-14c6-40ed-bb2a-7cc2e8111465
;;; calc-arith.el ends here
