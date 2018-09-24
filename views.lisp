(defpackage #:utopian/views
  (:use #:cl)
  (:import-from #:utopian/context
                #:*response*
                #:response-headers)
  (:import-from #:utopian/file-loader
                #:intern-rule)
  (:import-from #:lsx)
  (:import-from #:closer-mop)
  (:export #:render
           #:defview))
(in-package #:utopian/views)

(defvar *default-content-type* "text/html")

(defclass utopian-view-class (lsx:component-class)
  ((content-type :initarg :content-type)
   (auto-escape :initarg :auto-escape
                :initform '(t))))

(defun view-content-type (view-class)
  (if (slot-boundp view-class 'content-type)
      (slot-value view-class 'content-type)
      *default-content-type*))

(defmacro defview (name superclasses slots &rest options)
  `(defclass ,name (,@superclasses lsx:component)
     ,slots
     (:metaclass utopian-view-class)
     ,@options))

(defmethod c2mop:validate-superclass ((class utopian-view-class) (super standard-class))
  t)

(defun render (view-class &rest view-args)
  (let* ((view (apply #'make-instance view-class view-args))
         (view-class (class-of view))
         (content-type (view-content-type view-class)))
    (when content-type
      (setf (getf (response-headers *response*) :content-type)
            content-type))
    (let ((lsx:*auto-escape* (first (slot-value view-class 'auto-escape))))
      (lsx:render-object view nil))))
