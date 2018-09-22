(defpackage #:utopian/app
  (:use #:cl)
  (:import-from #:utopian/config
                #:*config-dir*
                #:config)
  (:import-from #:utopian/context
                #:*request*
                #:*response*)
  (:import-from #:utopian/errors
                #:throw-code
                #:http-error
                #:http-error-code
                #:http-redirect
                #:http-redirect-to
                #:http-redirect-code)
  (:import-from #:lack
                #:builder)
  (:import-from #:lack.component
                #:lack-component
                #:to-app
                #:call)
  (:import-from #:lack.response
                #:response-body
                #:response-status
                #:finalize-response)
  (:import-from #:lack.request)
  (:import-from #:lsx)
  (:import-from #:myway)
  (:import-from #:closer-mop)
  (:export #:application
           #:make-request
           #:make-response
           #:defapp))
(in-package #:utopian/app)

(defclass application (lack-component)
  ((routes :initarg :routes)))

(defmacro with-config ((app) &body body)
  `(let ((*config-dir* (slot-value (class-of ,app) 'config)))
     ,@body))

(defmethod to-app :around ((app application))
  (let* ((config-dir (slot-value (class-of app) 'config))
         (*config-dir* config-dir))
    (builder
     (lambda (app)
       (lambda (env)
         (let ((*config-dir* config-dir))
           (funcall app env))))
     (call-next-method))))

(defgeneric make-request (application env)
  (:method ((app application) env)
    (lack.request:make-request env)))

(defgeneric make-response (application status headers)
  (:method ((app application) status headers)
    (lack.response:make-response status headers)))

(defmethod call ((app application) env)
  (multiple-value-bind (res foundp)
      (myway:dispatch (slot-value app 'routes)
                      (getf env :path-info)
                      :method (getf env :request-method))
    (if foundp
        (progn
          (setf (response-body *response*)
                (if (typep res '(or string list vector pathname))
                    res
                    (lsx:render-object res nil)))
          (finalize-response *response*))
        (throw-code 404))))

(defmethod call :around ((app application) env)
  (let ((*request* (make-request app env))
        (*response* (make-response app 200 ())))
    (handler-case (call-next-method)
      (http-error (e)
        (setf (response-status *response*)
              (http-error-code e))
        ;; TODO: custom error handler
        (setf (response-body *response*)
              (princ-to-string e))
        (finalize-response *response*))
      (http-redirect (c)
        (let ((to (http-redirect-to c))
              (code (http-redirect-code c)))
          (setf (getf (response-headers *response*) :location) to)
          (setf (response-status *response*) code)
          (setf (response-body *response*) to))
        (finalize-response *response*)))))

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

(defmethod reinitialize-instance :after ((class utopian-app-class) &rest initargs &key config &allow-other-keys)
  (declare (ignore initargs))
  (assert (and (listp config)
               (null (rest config))))
  (when config
    (setf (slot-value class 'config)
          (merge-pathnames (first config) *app-pathname*))))

(defmethod c2mop:validate-superclass ((class utopian-app-class) (super standard-class))
  t)

(defmacro defapp (name superclasses slots &rest options)
  `(let ((*app-pathname* ,(uiop:pathname-directory-pathname (or *load-pathname* *compile-file-pathname*))))
     (defclass ,name (application ,@superclasses)
       ,slots
       (:metaclass utopian-app-class)
       ,@options)))
