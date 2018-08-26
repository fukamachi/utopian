(uiop:define-package #:utopian/view
  (:use #:cl)
  (:import-from #:closer-mop)
  (:import-from #:alexandria
                #:compose
                #:ensure-list)
  (:import-from #:kebab
                #:to-camel-case)
  (:export #:view
           #:render-object
           #:defview
           #:find-view
           #:*default-format*
           #:html
           #:head
           #:title
           #:body
           #:div
           #:span
           #:h1
           #:ul
           #:li
           #:p
           #:a))
(in-package #:utopian/view)

(defvar *default-format* :html)

(defclass view () ())

(defclass view-slot-class (c2mop:standard-direct-slot-definition)
  ())

(defmethod initialize-instance :around ((class view-slot-class) &rest args &key name &allow-other-keys)
  (push
   (intern (princ-to-string name) :keyword)
   (getf args :initargs))
  (apply #'call-next-method class args))

(defmethod reinitialize-instance :around ((class view-slot-class) &rest args &key name &allow-other-keys)
  (push
   (intern (princ-to-string name) :keyword)
   (getf args :initargs))
  (apply #'call-next-method class args))

(defgeneric render-object (object format)
  (:method ((object null) format)
    (declare (ignore format))
    "")
  (:method ((object t) format)
    (declare (ignore format))
    (princ-to-string object))
  (:method ((object list) format)
    (with-output-to-string (*standard-output*)
      (dolist (content object)
        (princ (render-object content format))))))

(defclass view-class (standard-class)
  ((render :initarg :render
           :initform nil)))

(defmethod c2mop:direct-slot-definition-class ((class view-class) &key &allow-other-keys)
  'view-slot-class)

(defmethod c2mop:validate-superclass ((class view-class) (super standard-class))
  t)

(defmethod initialize-instance :around ((class view-class) &rest initargs &key render &allow-other-keys)
  (when render
    (setf (getf initargs :render) (eval (first render))))
  (apply #'call-next-method class initargs))

(defmethod render-object ((object view) format)
  (let ((class (class-of object)))
    (when (slot-value class 'render)
      (render-object
       (apply (slot-value class 'render)
              (mapcan (lambda (slot)
                        (when (slot-boundp object (c2mop:slot-definition-name slot))
                          (list (intern (princ-to-string (c2mop:slot-definition-name slot)) :keyword)
                                (slot-value object (c2mop:slot-definition-name slot)))))
                      (c2mop:class-slots class)))
       format))))

(defvar *views* (make-hash-table :test 'eq))

(defun find-view (name)
  (values (gethash name *views*)))

(defun (setf find-view) (class name)
  (setf (gethash name *views*) class))

(defmacro defview (name direct-superclasses direct-slots &rest options)
  (let ((initargs (gensym))
        (class-name (make-symbol (prin1-to-string name))))
    `(progn
       (defclass ,class-name (view ,@direct-superclasses)
         ,direct-slots
         (:metaclass view-class)
         (:render
          (lambda (&rest ,initargs &key ,@(mapcar (compose #'first #'ensure-list) direct-slots) &allow-other-keys)
            (declare (ignore ,initargs))
            ,@(rest (find :render options :key #'first))))
         ,@(remove :render options :key #'first))
       (setf (find-view ',name)
             (find-class ',class-name)))))

(defclass html-tag (view)
  ((name :initarg :name)
   (attr :initarg :attr
         :initform nil)
   (content :initarg :content
            :initform nil)))

(defmethod render-object ((tag html-tag) (format (eql :html)))
  (with-slots (name attr content) tag
    (with-output-to-string (*standard-output*)
      (write-char #\<)
      (write-string (string-downcase name))
      (loop for (key val) on attr by #'cddr
            do (format t " ~A=\"~A\""
                       (kebab:to-camel-case (princ-to-string key))
                       val))
      (write-char #\>)
      (when content
        (write-string (render-object content format)))
      (write-string "</")
      (write-string (string-downcase name))
      (write-char #\>))))

(defun attr-p (val)
  (and (consp val)
       (= (mod (length val) 2) 0)
       (keywordp (first val))))

(defmacro define-html-tag (name)
  `(defmacro ,name (&rest contents)
     (let ((attr '()))
       (when (attr-p (first contents))
         (setf attr (pop contents)))
       `(make-instance 'html-tag
                       :name ,,(string-downcase name)
                       :attr (list ,@attr)
                       :content (list ,@contents)))))

(define-html-tag html)
(define-html-tag head)
(define-html-tag title)
(define-html-tag body)
(define-html-tag div)
(define-html-tag span)
(define-html-tag h1)
(define-html-tag ul)
(define-html-tag li)
(define-html-tag p)
(define-html-tag a)
