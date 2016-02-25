(in-package #:cl-user)
(defpackage utopian/view
  (:use #:cl)
  (:import-from #:utopian/app
                #:*session*)
  (:import-from #:utopian/controller
                #:*action*)
  (:import-from #:lack.middleware.csrf)
  (:import-from #:jonathan)
  (:import-from #:djula
                #:add-template-directory
                #:compile-template*
                #:render-template*
                #:def-tag-compiler
                #:*current-store*
                #:find-template)
  (:export #:render
           #:render-json))
(in-package #:utopian/view)

(defun find-djula-template (path)
  (setf path
        (etypecase path
          (keyword (string-downcase path))
          (pathname (namestring path))
          (string path)))
  (or (djula:find-template djula:*current-store* path nil)
      (djula:find-template djula:*current-store* (format nil "~A.html.dj" path) nil)
      (djula:find-template djula:*current-store* (format nil "~A.html" path) nil)))

(defun find-default-action-template (&optional (action *action*))
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
      (find-djula-template html))))

(defun render (env &key template)
  (let ((template (if template
                      (djula:compile-template* (find-djula-template template))
                      (find-default-action-template))))
    (apply #'djula:render-template* template nil env)))

(defun render-json (object)
  (jojo:to-json object))

(djula::def-tag-compiler csrf-token ()
  (lambda (stream)
    (princ (lack.middleware.csrf:csrf-token *session*) stream)))
