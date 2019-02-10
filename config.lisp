(defpackage #:utopian/config
  (:use #:cl)
  (:import-from #:utopian/file-loader
                #:eval-file)
  (:export #:*config-dir*
           #:environment-config
           #:config
           #:db-settings
           #:appenv))
(in-package #:utopian/config)

(defvar *default-app-env* "local")

(defvar *config-dir*)

(defun environment-config (env)
  (unless (boundp '*config-dir*)
    (return-from environment-config nil))

  (let ((file (make-pathname :name env
                             :type "lisp"
                             :defaults *config-dir*)))
    (when (probe-file file)
      (eval-file file))))

(defun config (key)
  (getf (environment-config (appenv)) key))

(defun db-settings (&optional (db :maindb))
  (cdr (assoc db (config :databases))))

(defun appenv ()
  (let ((appenv (uiop:getenv "APP_ENV")))
    (if (and (stringp appenv)
             (not (string= appenv "")))
        appenv
        *default-app-env*)))

(defun (setf appenv) (env)
  (setf (uiop:getenv "APP_ENV") env))
