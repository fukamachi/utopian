(defpackage #:utopian/views
  (:use #:cl)
  (:import-from #:utopian/context
                #:*response*
                #:response-headers)
  (:import-from #:lsx
                #:render)
  (:import-from #:closer-mop)
  (:export #:defview
           ;; Reexport from LSX
           #:render))
(in-package #:utopian/views)

(defvar *default-content-type* "text/html")

(defclass utopian-view (lsx:template) ())

(defclass utopian-view-class (lsx:template-class)
  ((content-type :initarg :content-type)
   (auto-escape :initarg :auto-escape
                :initform '(t))))

(defun view-content-type (view-class)
  (if (slot-boundp view-class 'content-type)
      (slot-value view-class 'content-type)
      *default-content-type*))

(defmacro defview (name superclasses slots &rest options)
  `(defclass ,name (,@superclasses utopian-view)
     ,slots
     (:metaclass utopian-view-class)
     ,@options))

(defmethod c2mop:validate-superclass ((class utopian-view-class) (super standard-class))
  t)

(defmethod lsx:render-object ((view utopian-view) stream)
  (let* ((view-class (class-of view))
         (content-type (view-content-type view-class)))
    (when content-type
      (setf (getf (response-headers *response*) :content-type)
            content-type))
    (let ((lsx:*auto-escape* (first (slot-value view-class 'auto-escape))))
      (call-next-method))))
