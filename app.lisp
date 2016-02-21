(in-package #:cl-user)
(defpackage utopian/app
  (:use #:cl)
  (:import-from #:ningle)
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

           ;; From Caveman2
           #:on-exception
           #:throw-code
           #:clear-routing-rules))
(in-package #:utopian/app)

(defvar *package-app* (make-hash-table :test 'eq))
(defvar *current-app*)

(defclass base-app (<app>)
  ((root :initarg :root
         :accessor app-root)))

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
               (let ((package-name
                       (intern
                        (string-upcase
                         (format nil "~A/controllers/~A"
                                 (ppcre:scan-to-strings "^[^/]+"
                                                        (asdf:component-name
                                                         (package-system *package*)))
                                 (aref match 0)))
                        :keyword)))
                 (asdf:load-system (asdf:find-system package-name)
                                   :verbose nil)
                 (let ((fn (intern (string-upcase (aref match 1))
                                   package-name)))
                   (lambda (&rest params)
                     (apply (fdefinition fn)
                            (caveman2.nested-parameter:parse-parameters params)))))))))))

(defun route (method url fn &key regexp)
  (connect (gethash *package* *package-app*) url fn :method method :regexp regexp))

;; Rename the name of 'redirect' to 'redirect-to'
(setf (fdefinition 'redirect-to) #'caveman2:redirect)
