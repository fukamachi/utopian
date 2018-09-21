(uiop:define-package #:myblog/models
  (:use #:cl)
  (:use-reexport #:myblog/models/entry))
(in-package #:myblog/models)
