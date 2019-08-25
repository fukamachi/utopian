(defpackage #:myblog/controllers/root
  (:use #:cl
        #:utopian
        #:myblog/views/root)
  (:export #:index))
(in-package #:myblog/controllers/root)

(defun index (params)
  (declare (ignore params))
  (render 'index-page))
