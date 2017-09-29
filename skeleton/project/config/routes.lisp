(defpackage #:<% @var name %>/config/routes
  (:use #:cl
        #:utopian
        #:<% @var name %>/config/application)
  (:export #:*app*))
(in-package #:<% @var name %>/config/routes)

(defvar *app* (make-instance 'application))
(clear-routing-rules *app*)

;;
;; Routing rules

(route :GET "/" "root:index")
