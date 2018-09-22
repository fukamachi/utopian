(defpackage #:utopian/context
  (:use #:cl)
  (:export #:*request*
           #:*response*))
(in-package #:utopian/context)

(defvar *request*)
(defvar *response*)
