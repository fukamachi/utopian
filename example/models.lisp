(defpackage #:myblog/models
  (:use #:cl
        #:utopian)
  (:export #:entry
           #:entry-title))
(in-package #:myblog/models)

(defmodel entry ()
  ((title :col-type :text)))
