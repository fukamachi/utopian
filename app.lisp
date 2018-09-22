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
                #:make-response
                #:response-body
                #:response-headers
                #:response-status
                #:finalize-response)
  (:import-from #:lack.request
                #:make-request)
  (:import-from #:lsx)
  (:import-from #:myway)
  (:import-from #:closer-mop)
  (:export #:application
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
  (let ((*request* (make-request env))
        (*response* (make-response 200 ())))
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
  ((base-directory :initarg :base-directory
                   :initform *default-pathname-defaults*)
   (config :initarg :config
           :initform nil)))

(defmethod initialize-instance :after ((class utopian-app-class) &rest initargs &key config &allow-other-keys)
  (declare (ignore initargs))
  (assert (and (listp config)
               (null (rest config))))
  (with-slots (base-directory config) class
    (when config
      (setf config
            (merge-pathnames (first config) (first base-directory))))))

(defmethod reinitialize-instance :after ((class utopian-app-class) &rest initargs &key config &allow-other-keys)
  (declare (ignore initargs))
  (assert (and (listp config)
               (null (rest config))))
  (with-slots (base-directory config) class
    (when config
      (setf config
            (merge-pathnames (first config) (first base-directory))))))

(defmethod c2mop:validate-superclass ((class utopian-app-class) (super standard-class))
  t)

(defmacro defapp (name superclasses slots &rest options)
  `(defclass ,name (application ,@superclasses)
     ,slots
     (:metaclass utopian-app-class)
     (:base-directory ,(uiop:pathname-directory-pathname (or *compile-file-pathname* *load-pathname*)))
     ,@options))
