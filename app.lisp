(in-package #:cl-user)
(defpackage utopian/app
  (:use #:cl)
  (:import-from #:ningle
                #:not-found)
  (:import-from #:caveman2
                #:<app>)
  (:import-from #:caveman2
                #:on-exception
                #:throw-code
                #:clear-routing-rules
                #:next-route
                #:*request*
                #:*response*
                #:*session*)
  (:import-from #:myway
                #:make-mapper
                #:dispatch)
  (:import-from #:lack.request
                #:request-parameters
                #:request-path-info
                #:request-method)
  (:import-from #:djula
                #:add-template-directory)
  (:export #:base-app
           #:project-root
           #:project-path
           #:connect
           #:route
           #:next-route
           #:redirect-to
           #:*request*
           #:*response*
           #:*session*
           #:*action*

           ;; From Caveman2
           #:on-exception
           #:throw-code
           #:clear-routing-rules))
(in-package #:utopian/app)

(defparameter *action* nil)

(defvar *package-app* (make-hash-table :test 'eq))
(defvar *current-app*)

(defclass base-app (<app>)
  ((root :initarg :root
         :accessor app-root)
   (name :initarg :name
         :accessor app-name)))

(defparameter *default-mapper*
  (myway:make-mapper))

(defun find-controller (controller-name)
  (let* ((package-name (format nil "~(~A~)/controllers/~(~A~)"
                               (app-name *current-app*)
                               controller-name))
         (controller (asdf:find-system package-name nil)))
    (when controller
      (asdf:load-system controller)
      (find-package (string-upcase package-name)))))

(defun find-controller-action (controller-name action-name)
  (let ((controller (find-controller controller-name)))
    (when controller
      (multiple-value-bind (fn status)
          (intern (string-upcase action-name) controller)
        (when (and (fboundp fn)
                   (eq status :external))
          fn)))))

(defun call-default-or-next (url-params)
  (let ((action (find-controller-action
                 (getf url-params :controller)
                 (or (getf url-params :action) :index))))
    (if action
        (let ((*action* action))
          (funcall action
                   (append (request-parameters *request*)
                           (loop for (k v) on url-params by #'cddr
                                 collect (cons k v)))))
        (throw-code 404))))

(myway:connect *default-mapper* "/:controller/?:action?/?:id?.?:format?" #'call-default-or-next)

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

(defun package-system (package)
  (asdf:find-system
   (asdf/package-inferred-system::package-name-system (package-name package))))

(defmethod initialize-instance :after ((app base-app) &rest initargs)
  (declare (ignore initargs))
  (unless (and (slot-boundp app 'root)
               (slot-value app 'root))
    (setf (slot-value app 'root)
          (asdf:component-pathname (package-system *package*))))
  (unless (and (slot-boundp app 'name)
               (slot-value app 'name))
    (setf (slot-value app 'name)
          (string-downcase
           (ppcre:scan-to-strings "^[^/]+"
                                  (asdf:component-name
                                   (package-system *package*))))))
  (djula:add-template-directory
   (merge-pathnames #P"views/" (slot-value app 'root)))
  (setf (gethash *package* *package-app*) app)
  (setf *current-app* app))

(defgeneric connect (app url action &key method regexp)
  (:method ((app base-app) url action &key (method :get) regexp)
    (setf (ningle:route app url :method method :regexp regexp)
          (etypecase action
            (function action)
            (string
             (let ((match
                       (nth-value 1 (ppcre:scan-to-strings "^([^:]+)::?(.+)$"
                                                           action))))
               (unless match
                 (error "Invalid controller: ~A" action))
               (let ((action (find-controller-action (aref match 0) (aref match 1))))
                 (lambda (params)
                   (let ((*action* action))
                     (funcall (fdefinition action)
                              (caveman2.nested-parameter:parse-parameters params)))))))))))

(defun route (method url fn &key regexp)
  (connect (gethash *package* *package-app*) url fn :method method :regexp regexp))

;; Rename the name of 'redirect' to 'redirect-to'
(setf (fdefinition 'redirect-to) #'caveman2:redirect)
