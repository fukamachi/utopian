(defpackage #:utopian/controller
  (:use #:cl)
  (:import-from #:utopian/app
                #:base-app)
  (:export #:controller))
(in-package #:utopian/controller)

(defclass controller (base-app) ())

(defvar *package-controller* (make-hash-table :test 'eq))

(defmethod initialize-instance :after ((controller controller) &rest initargs)
  (declare (ignore initargs))
  (setf (gethash *package* *package-controller*) controller))

(defun find-current-controller (&optional (package *package*))
  (values (gethash package *package-controller*)))
