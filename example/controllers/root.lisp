(defpackage #:myblog/controllers/root
  (:use #:cl
        #:utopian
        #:myblog/views/root)
  (:export #:index))
(in-package #:myblog/controllers/root)

(defroute index ()
  (render))
