(defpackage #:myblog/models/entry
  (:use #:cl
        #:mito)
  (:export #:entry
           #:entry-title))
(in-package #:myblog/models/entry)

(deftable entry ()
  ((title :col-type :text)))
