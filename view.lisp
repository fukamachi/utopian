(defpackage #:utopian/view
  (:use #:cl)
  (:import-from #:utopian/app
                #:*app*
                #:*action*
                #:*session*
                #:*response*
                #:app-template-store)
  (:import-from #:utopian/config
                #:appenv
                #:*default-app-env*)
  (:import-from #:lack.response
                #:response-headers)
  (:import-from #:lack.middleware.csrf)
  (:import-from #:jonathan)
  (:import-from #:djula
                #:add-template-directory
                #:compile-template*
                #:render-template*
                #:def-tag-compiler
                #:*current-store*
                #:find-template)
  (:export #:default-view-env
           #:render
           #:render-json))
(in-package #:utopian/view)

(defvar *default-view-env-cache*)

(defun default-view-env ()
  (if (boundp '*default-view-env-cache*)
      *default-view-env-cache*
      `(:appenv ,(or (appenv) *default-app-env*))))

(defun (setf default-view-env) (value)
  (setf *default-view-env-cache* value))

(defun find-djula-template (path &optional (template-store djula:*current-store*))
  (setf path
        (etypecase path
          (keyword (string-downcase path))
          (pathname (namestring path))
          (string path)))
  (or (djula:find-template template-store path nil)
      (djula:find-template template-store (format nil "~A.html.dj" path) nil)
      (djula:find-template template-store (format nil "~A.html" path) nil)))

(defun find-default-action-template (&optional (action *action*) (app *app*))
  (assert action)
  (flet ((action-controller (action)
           (let ((match
                     (nth-value 1
                                (ppcre:scan-to-strings "^[^/]+/controllers/(.+)"
                                                       (string-downcase
                                                        (package-name (symbol-package action)))))))
             (unless match
               (error "Invalid action: ~A" action))
             (aref match 0))))
    (let ((html (format nil
                        "~A/~A"
                        (action-controller action)
                        (string-downcase action))))
      (find-djula-template html (app-template-store app)))))

(defun render (env &key template)
  (let ((template (if template
                      (djula:compile-template* (find-djula-template template (app-template-store *app*)))
                      (find-default-action-template))))
    (unless template
      (error "Unknown template: ~A for ~S" template *action*))
    (apply #'djula:render-template* template nil
           (append env (default-view-env)))))

(defun render-json (object &rest args &key from octets)
  (declare (ignore from octets))
  (setf (getf (response-headers *response*) :content-type) "application/json")
  (apply #'jojo:to-json object args))

(djula::def-tag-compiler csrf-token ()
  (lambda (stream)
    (when *session*
      (princ (lack.middleware.csrf:csrf-token *session*) stream))))

(djula::def-tag-compiler csrf-html-tag ()
  (lambda (stream)
    (princ (lack.middleware.csrf:csrf-html-tag *session*) stream)))
