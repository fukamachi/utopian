(defpackage #:utopian/utils
  (:use #:cl)
  (:export #:load-file))
(in-package #:utopian/utils)

(defun load-file (file)
  (let ((package (second (asdf/package-inferred-system::file-defpackage-form file))))
    (when package
      #+quicklisp
      (ql:quickload package :silent t)
      #-quicklisp
      (asdf:load-system package))))
