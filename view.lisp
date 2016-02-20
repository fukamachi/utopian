(in-package #:cl-user)
(defpackage utopian/view
  (:use #:cl)
  (:import-from #:djula
                #:add-template-directory
                #:compile-template*
                #:render-template*)
  (:export #:render))
(in-package #:utopian/view)

(defun render (template-path &optional env)
  (let ((template (djula:compile-template* (princ-to-string template-path))))
    (apply #'djula:render-template* template nil env)))
