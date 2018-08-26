(defpackage #:utopian/config
  (:use #:cl)
  (:export #:*config-dir*
           #:environment-config
           #:config
           #:appenv))
(in-package #:utopian/config)

(defvar *config-cache*
  (make-hash-table :test 'equal))

(defvar *default-app-env* "local")

(defvar *config-dir*)

(defun environment-config (env)
  (unless (boundp '*config-dir*)
    (return-from environment-config nil))

  (let ((file (make-pathname :name env
                             :type "lisp"
                             :defaults *config-dir*)))
    (when (probe-file file)
      (let ((modified-at (file-write-date file)))
        (cond
          ((< (car (gethash file *config-cache* '(0 . nil)))
              modified-at)
           (let ((dependencies (asdf/package-inferred-system::package-inferred-system-file-dependencies file)))
             (when dependencies
               #+quicklisp
               (ql:quickload dependencies :silent t)
               #-quicklisp
               (asdf:load-system dependencies)))
           (let ((config (uiop:with-safe-io-syntax ()
                           (with-open-file (in file)
                             (uiop:eval-input in)))))
             (setf (gethash file *config-cache*)
                   (cons modified-at config))
             config))
          (t
           (cdr (gethash file *config-cache*))))))))

(defun config (key)
  (getf (environment-config (appenv)) key))

(defun appenv ()
  (let ((appenv (uiop:getenv "APP_ENV")))
    (if (and (stringp appenv)
             (not (string= appenv "")))
        appenv
        *default-app-env*)))

(defun (setf appenv) (env)
  (setf (uiop:getenv "APP_ENV") env))
