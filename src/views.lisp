(defpackage #:utopian/views
  (:use #:cl)
  (:import-from #:utopian/context
                #:*response*
                #:response-headers)
  (:import-from #:lsx)
  (:import-from #:closer-mop)
  (:export #:defview
           #:utopian-view
           #:utopian-view-class
           #:render
           #:render-object
           #:html-view
           #:html-view-class))
(in-package #:utopian/views)

(defvar *default-content-type* "text/html")

(defclass utopian-view () ())

(defclass utopian-view-class (standard-class)
  ((content-type :initarg :content-type)
   (inherits :initarg :inherits
             :initform '(utopian-view))
   (render :initarg :render
           :initform nil)
   (render-element :initarg :render-element
                   :initform #'princ)))

(defclass utopian-view-slot-class (c2mop:standard-direct-slot-definition)
  ())

(defgeneric render-object (object stream)
  (:method :before ((object utopian-view) stream)
    (let* ((class (class-of object))
           (content-type (view-content-type class)))
      (when (and (boundp '*response*)
                 *response*
                 content-type)
        (setf (getf (response-headers *response*) :content-type)
              content-type)))))

(defmethod c2mop:direct-slot-definition-class ((class utopian-view-class) &key &allow-other-keys)
  'utopian-view-slot-class)

(defmethod c2mop:validate-superclass ((class utopian-view-class) (super standard-class))
  t)

(defun view-content-type (view-class)
  (if (slot-boundp view-class 'content-type)
      (slot-value view-class 'content-type)
      *default-content-type*))

(defmacro define-initialize-instance (lambda-list &body body)
  `(progn
     (defmethod initialize-instance ,lambda-list ,@body)
     (defmethod reinitialize-instance ,lambda-list ,@body)))

(define-initialize-instance :around ((class utopian-view-slot-class) &rest args &key name &allow-other-keys)
  (push
   (intern (princ-to-string name) :keyword)
   (getf args :initargs))
  (apply #'call-next-method class args))

(define-initialize-instance ((class utopian-view-class) &rest initargs
                                                        &key direct-superclasses inherits &allow-other-keys)
  (apply #'call-next-method class
         :direct-superclasses (append direct-superclasses (mapcar #'find-class (if (slot-boundp class 'inherits)
                                                                                   (slot-value class 'inherits)
                                                                                   inherits)))
         initargs))

(define-initialize-instance :after ((class utopian-view-class) &rest initargs &key direct-slots render &allow-other-keys)
  (declare (ignore initargs))
  (when render
    (let* ((stream (gensym "STREAM"))
           (object (gensym "OBJECT"))
           (slot-names (mapcar (lambda (slot) (getf slot :name))
                               direct-slots))
           (generic-function (ensure-generic-function 'render-object :lambda-list '(object stream)))
           (main-fn (eval
                     `(lambda (,stream ,object)
                        (with-slots (,@slot-names) ,object
                          (declare (ignorable ,@slot-names))
                          (let ((render-element (slot-value ,class 'render-element))
                                (elements (list ,@render)))
                            (mapc (lambda (element)
                                    (funcall render-element element ,stream))
                                  elements))
                          (values))))))
      (add-method generic-function
                  (make-instance 'standard-method
                                 :lambda-list '(object stream)
                                 :qualifiers ()
                                 :specializers (list class (find-class 't))
                                 :function
                                 (lambda (args &rest ignore)
                                   (declare (ignore ignore))
                                   (destructuring-bind (object stream) args
                                     (if stream
                                         (funcall main-fn stream object)
                                         (with-output-to-string (s)
                                           (funcall main-fn s object))))))))))

(defclass html-view (utopian-view) ())

(defclass html-view-class (utopian-view-class)
  ((auto-escape :initarg :auto-escape
                :initform '(t)))
  (:default-initargs
   :content-type "text/html"
   :inherits '(html-view)
   :render-element #'lsx:render-object))

(defmacro defview (name superclasses slots &rest options)
  (pushnew '(:metaclass utopian-view-class) options
           :key #'first
           :test #'eq)
  `(defclass ,name (,@superclasses)
     ,slots
     ,@options))

(defmethod render-object :around ((view html-view) stream)
  (let* ((view-class (class-of view))
         (lsx:*auto-escape* (first (slot-value view-class 'auto-escape))))
    (call-next-method)))

(defun render (object &rest args)
  (etypecase object
    (symbol (apply #'render (find-class object) args))
    (utopian-view-class
      (render-object (apply #'make-instance object
                            :allow-other-keys t
                            args)
                     nil))))
