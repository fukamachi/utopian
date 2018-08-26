(defpackage #:utopian/model
  (:use #:cl)
  (:import-from #:mito
                #:dao-table-class)
  (:import-from #:alexandria
                #:ensure-list)
  (:export #:defmodel))
(in-package #:utopian/model)

(defmacro defmodel (name direct-superclasses direct-slots &optional options)
  `(defclass ,name ,direct-superclasses
     ,(mapcar (lambda (slot)
                (destructuring-bind (slot-name &rest options)
                    (ensure-list slot)
                  `(,slot-name :initarg ,(intern (princ-to-string slot-name) :keyword)
                               :accessor ,(intern (format nil "~A-~A" name slot-name))
                               ,@options)))
              direct-slots)
     (:metaclass dao-table-class)
     ,@options))
