(in-package #:cl-user)
(defpackage utopian/app
  (:use #:cl)
  (:import-from #:utopian/controller
                #:controller
                #:find-controller
                #:find-controller-package
                #:%route)
  (:import-from #:caveman2
                #:*request*
                #:*response*
                #:*session*
                #:throw-code
                #:on-exception
                #:redirect)
  (:import-from #:myway
                #:make-mapper
                #:next-route
                #:dispatch)
  (:import-from #:lack.component
                #:call)
  (:import-from #:lack.request
                #:request-path-info
                #:request-method
                #:request-env)
  (:import-from #:djula
                #:add-template-directory)
  (:export #:base-app
           #:project-root
           #:project-path
           #:mount
           #:redirect-to

           ;; from MyWay
           #:next-route

           ;; from Caveman2
           #:*request*
           #:*response*
           #:*session*
           #:on-exception
           #:throw-code))
(in-package #:utopian/app)

(defvar *package-app* (make-hash-table :test 'eq))
(defvar *current-app*)

(defun package-system (package)
  (asdf:find-system
   (asdf/package-inferred-system::package-name-system (package-name package))))

(defclass base-app (controller)
  ((root :initarg :root
         :initform (asdf:component-pathname (package-system *package*))
         :accessor app-root)
   (name :initarg :name
         :initform (string-downcase
                    (ppcre:scan-to-strings "^[^/]+"
                                           (asdf:component-name
                                            (package-system *package*))))
         :accessor app-name)))

(defparameter *default-mapper*
  (myway:make-mapper))

(myway:connect *default-mapper* "/:controller/?:action?"
               (lambda (url-params)
                 (let ((controller (find-controller (app-name *current-app*)
                                                    (getf url-params :controller))))
                   (if controller
                       (let ((env (lack.request:request-env *request*)))
                         (setf (getf env :path-info) (format nil "/~A"
                                                             (or (getf url-params :action) "")))
                         (call controller env))
                       (throw-code 404))))
               :method :any)

(defmethod ningle:not-found ((app base-app))
  (multiple-value-bind (res foundp)
      (myway:dispatch *default-mapper*
                      (request-path-info *request*)
                      :method
                      (request-method *request*))
    (if foundp
        res
        (call-next-method))))

(defun project-root ()
  (app-root *current-app*))

(defun project-path (path)
  (merge-pathnames path (project-root)))

(defmethod initialize-instance :after ((app base-app) &rest initargs)
  (declare (ignore initargs))
  (djula:add-template-directory
   (merge-pathnames #P"views/" (app-root app)))
  (setf (gethash *package* *package-app*) app)
  (setf *current-app* app))

(defun mount (mount-path controller)
  (check-type controller string)
  ;; Ensure the mount-path ends with "/".
  (setf mount-path
        (ppcre:regex-replace "/?$" mount-path "/"))
  (let ((package (find-controller-package (app-name *current-app*) controller)))
    (unless package
      (error "Unknown (or internal) controller: ~A" controller))

    (%route :any (format nil "~A*" mount-path)
            (lambda (params)
              (let ((path-info (request-path-info *request*)))
                (cond
                  ((string= path-info mount-path)
                   (setf (request-path-info *request*) "/")
                   (call (gethash package *package-app*) params))
                  ((and (< (length mount-path)
                           (length path-info))
                        (string= path-info mount-path :end1 (length mount-path)))
                   (setf (request-path-info *request*)
                         (subseq path-info (length mount-path)))
                   (call (gethash package *package-app*) params))
                  (t
                   (throw-code 404))))))))

;; Rename the name of 'redirect' to 'redirect-to'
(setf (fdefinition 'redirect-to) #'caveman2:redirect)
