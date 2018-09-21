(defpackage #:myblog/models/entry
  (:use #:cl
        #:utopian)
  (:export #:entry
           #:entry-title))
(in-package #:myblog/models/entry)

(defmodel entry ()
  ((title :col-type :text)))
