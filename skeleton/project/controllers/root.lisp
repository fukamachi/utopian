(defpackage <% @var name %>/controllers/root
  (:use :cl
        :utopian)
  (:export :index))
(in-package :<% @var name %>/controllers/root)

(defparameter *env*
  `(:appenv ,(or (appenv) *default-app-env*)))

(defun index (params)
  (declare (ignore params))
  (render *env* :template :index))
