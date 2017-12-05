(uiop:define-package #:<% @var name %>/models
  (:use #:cl)
  ,@(mapcar #'utopian/utils:file-package-name
            (utopian:project-models (asdf:system-source-directory '#:<% @var name %>))))
(in-package #:<% @var name %>/models)
