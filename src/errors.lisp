(defpackage #:utopian/errors
  (:use #:cl)
  (:export #:utopian-error
           #:utopian-task-error
           #:simple-task-error
           #:invalid-arguments
           #:unknown-command
           #:file-not-found
           #:system-not-found
           #:directory-already-exists))
(in-package #:utopian/errors)

(define-condition utopian-error (error) ())

(define-condition utopian-task-error (utopian-error) ())

(define-condition simple-task-error (utopian-task-error simple-error) ())

(define-condition invalid-arguments (utopian-task-error) ())

(define-condition unknown-command (utopian-task-error)
  ((given :initarg :given)
   (candidates :initarg :candidates
               :initform nil))
  (:report (lambda (condition stream)
             (with-slots (given candidates) condition
               (format stream "~&Command not found: ~A~%~@[Must be one of [ ~{~A~^ | ~} ]~]" given candidates)))))

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

(define-condition directory-already-exists (utopian-task-error)
  ((directory :initarg :directory))
  (:report (lambda (condition stream)
             (with-slots (directory) condition
               (format stream "Directory '~A' already exists." directory)))))
