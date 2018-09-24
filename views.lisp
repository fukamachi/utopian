(defpackage #:utopian/views
  (:use #:cl)
  (:import-from #:utopian/routes
                #:*current-route*)
  (:import-from #:utopian/file-loader
                #:intern-rule)
  (:export #:render))
(in-package #:utopian/views)

(defvar *views-directory*)

(defun render (&rest view-args)
  (if (and view-args
           (not (keywordp (first view-args))))
      (apply #'make-instance view-args)
      (apply #'make-instance
             (intern-rule *current-route* *views-directory*)
             view-args)))
