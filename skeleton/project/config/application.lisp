(defpackage <% @var name %>/config/application
  (:use :cl
        :utopian)
  (:export :application))
(in-package :<% @var name %>/config/application)

(defclass application (utopian:base-app) ())

;;
;; Error pages

(defmethod on-exception ((app application) (code (eql 404)))
  (render nil :template #P"errors/404.html"))
