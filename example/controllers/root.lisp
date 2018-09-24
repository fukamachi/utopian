(defpackage #:myblog/controllers/root
  (:use #:cl
        #:utopian)
  (:export #:index))
(in-package #:myblog/controllers/root)

(defroute index ()
  (render))
