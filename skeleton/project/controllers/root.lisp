(defpackage #:<% @var name %>/controllers/root
  (:use #:cl
        #:utopian)
  (:export #:index))
(in-package #:<% @var name %>/controllers/root)

(defun index (params)
  (declare (ignore params))
  (render nil :template :index))
