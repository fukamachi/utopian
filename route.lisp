(defpackage #:utopian/route
  (:use #:cl)
  (:import-from #:utopian/view
                #:render-object
                #:find-view
                #:*default-format*)
  (:import-from #:alexandria
                #:with-gensyms)
  (:export #:defroute
           #:render))
(in-package #:utopian/route)

(declaim (ftype (function (&optional) t) render))

(defmacro defroute (name lambda-list &body body)
  (with-gensyms (params)
    `(defun ,name ,(or lambda-list `(,params))
       ,@(unless lambda-list
           `((declare (ignore ,params))))
       (flet ((render (&rest args)
                (render-object (apply #'make-instance (find-view ',name) args) *default-format*)))
         ,@body))))
