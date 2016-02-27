(in-package #:cl-user)
(defpackage utopian/controller
  (:use #:cl)
  (:import-from #:ningle)
  (:import-from #:caveman2
                #:<app>
                #:clear-routing-rules)
  (:import-from #:cl-annot
                #:defannotation)
  (:import-from #:cl-annot.util
                #:definition-form-type
                #:definition-form-symbol
                #:progn-form-last)
  (:export #:controller
           #:controller-instance
           #:find-controller
           #:find-controller-package
           #:route
           #:*action*
           #:clear-routing-rules))
(in-package #:utopian/controller)

(defvar *action*)

(defclass controller (<app>) ())

(defvar *package-controller* (make-hash-table :test 'eq))

(defmethod initialize-instance :after ((controller controller) &rest initargs)
  (declare (ignore initargs))
  (setf (gethash *package* *package-controller*) controller))

(defun find-controller-package (app-name name)
  (let* ((package-name (format nil "~(~A~)/controllers/~(~A~)"
                               app-name
                               name))
         (controller (asdf:find-system package-name nil)))
    (when controller
      (asdf:load-system controller)
      (find-package (string-upcase package-name)))))

(defun find-controller (app-name name)
  (let ((package (find-controller-package app-name name)))
    (when package
      (find-current-controller package))))

(defun find-current-controller (&optional (package *package*))
  (values (gethash package *package-controller*)))

(defun canonicalize-method (method)
  (etypecase method
    (list (mapcar #'canonicalize-method method))
    (keyword method)
    (symbol (intern (symbol-name method) :keyword))))

(defun %route (method url fn &key regexp identifier)
  (when (stringp fn)
    (destructuring-bind (controller action)
        (ppcre:split "::?" fn)
      (let ((package (find-controller-package (ppcre:scan-to-strings "^[^/]+" (package-name *package*))
                                              controller)))
        (unless package
          (error "Unknown package: ~A" controller))
        (multiple-value-bind (controller status)
            (intern (string-upcase action) package)
          (unless (and (eq status :external)
                       (fboundp controller))
            (error "Controller is not defined or internal"))
          (setf fn controller)))))
  (let ((controller (find-current-controller)))
    (setf (ningle:route controller url :method method :regexp regexp :identifier identifier)
          (lambda (params)
            (let ((*action* identifier))
              (funcall fn params))))))

(defannotation route (method routing-rule form)
    (:arity 3)
  (let* ((last-form (progn-form-last form))
         (type (definition-form-type last-form))
         (symbol (definition-form-symbol last-form))
         (method (canonicalize-method method)))
    (case type
      (cl:lambda
          `(%route ',method ,routing-rule ,form))
      (cl:defun
          `(progn
             (%route ',method ,routing-rule ,form :identifier ',symbol)
             ',symbol))
      ('nil
       `(%route ,method ,routing-rule ,form)))))
