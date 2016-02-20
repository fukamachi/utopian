(in-package #:cl-user)
(defpackage utopian/view
  (:use #:cl)
  (:import-from #:utopian/app
                #:*session*)
  (:import-from #:lack.middleware.csrf)
  (:import-from #:djula
                #:add-template-directory
                #:compile-template*
                #:render-template*
                #:def-tag-compiler)
  (:export #:render))
(in-package #:utopian/view)

(defun render (template-path &optional env)
  (let ((template (djula:compile-template* (princ-to-string template-path))))
    (apply #'djula:render-template* template nil env)))

(djula::def-tag-compiler csrf-token ()
  (lambda (stream)
    (princ (lack.middleware.csrf:csrf-token *session*) stream)))
