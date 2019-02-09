(defpackage #:utopian/errors
  (:use #:cl)
  (:export #:utopian-error
           #:utopian-task-error
           #:file-not-found
           #:system-not-found))
(in-package #:utopian/errors)

(define-condition utopian-error (error) ())

(define-condition utopian-task-error (utopian-error) ())

(define-condition file-not-found (utopian-task-error)
  ((file :initarg file))
  (:report (lambda (condition stream)
             (with-slots (file) condition
               (format stream "File '~A' not found" file)))))

(define-condition system-not-found (utopian-task-error)
  ((system :initarg :system))
  (:report (lambda (condition stream)
             (with-slots (system) condition
               (format stream "System '~A' cannot be located.~%Make sure it's loadable by ASDF."
                       system)))))
