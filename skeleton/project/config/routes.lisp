(defpackage <% @var name %>/config/routes
  (:use :cl
        :utopian
        :<% @var name %>/config/application)
  (:export :*app*))
(in-package :<% @var name %>/config/routes)

(defparameter *app* (make-instance 'application))

;;
;; Routing rules

(route :GET "/" "root:index")
