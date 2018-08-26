(defpackage #:utopian/app
  (:use #:cl)
  (:import-from #:utopian/config
                #:*config-dir*
                #:config)
  (:import-from #:ningle)
  (:import-from #:caveman2
                #:<app>
                #:throw-code)
  (:import-from #:lack
                #:builder)
  (:import-from #:lack.component
                #:to-app
                #:call)
  (:import-from #:closer-mop)
  (:export #:defapp
           #:with-config

           ;; from Caveman2
           #:*request*
           #:*response*
           #:*session*
           #:*exception-class*
           #:http-exception
           #:exception-code
           #:on-exception
           #:throw-code))
(in-package #:utopian/app)

(defclass utopian-app (caveman2:<app>) ())

(defmacro with-config ((app) &body body)
  `(let ((*config-dir* (slot-value (class-of ,app) 'config)))
     ,@body))

(defmethod to-app ((app utopian-app))
  (let ((config-dir (slot-value (class-of app) 'config)))
    (builder
     :accesslog
     (lambda (app)
       (lambda (env)
         (let ((*config-dir* config-dir))
           (funcall app env))))
     (lambda (app)
       (lambda (env)
         (let* ((db-config (config :database))
                (mito:*connection* (and db-config (apply #'dbi:connect-cached db-config))))
           (funcall app env))))
     (lambda (env) (call app env)))))


(defclass utopian-app-class (standard-class)
  ((config :initarg :config
           :initform nil)))

(defvar *app-pathname*)

(defmethod initialize-instance :after ((class utopian-app-class) &rest initargs &key config &allow-other-keys)
  (declare (ignore initargs))
  (assert (and (listp config)
               (null (rest config))))
  (when config
    (setf (slot-value class 'config)
          (merge-pathnames (first config) *app-pathname*))))

(defmethod c2mop:validate-superclass ((class utopian-app-class) (super standard-class))
  t)

(defmacro defapp (name routing-rules &rest options)
  `(progn
     (let ((*app-pathname* ,(uiop:pathname-directory-pathname (or *load-pathname* *compile-file-pathname*))))
       (defclass ,name (utopian-app) ()
         (:metaclass utopian-app-class)
         ,@options))
     (defvar ,name (make-instance ',name))
     ,@(mapcar (lambda (rule)
                 (destructuring-bind (method path fn)
                     rule
                   `(setf (ningle:route ,name ,path :method ,method) ,fn)))
               routing-rules)
     ,name))
