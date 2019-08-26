(defpackage #:utopian-tests/utils
  (:use #:cl)
  (:export #:random-string))
(in-package #:utopian-tests/utils)

(defun random-char ()
  (let ((*random-state* (make-random-state t)))
    (ecase (random 3)
      (0 (code-char (+ (char-code #\0) (random 10))))
      (1 (code-char (+ (char-code #\a) (random 26))))
      (2 (code-char (+ (char-code #\A) (random 26)))))))

(defun random-string (&optional (length 10))
  (let ((string (make-string length)))
    (dotimes (i length string)
      (setf (aref string i) (random-char)))))
