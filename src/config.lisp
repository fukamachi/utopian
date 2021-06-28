(defpackage #:utopian/config
  (:use #:cl)
  (:import-from #:utopian/file-loader
                #:eval-file)
  (:import-from #:alexandria
                #:when-let)
  (:export #:*config-dir*
           #:environment-config
           #:config
           #:db-settings
           #:getenv
           #:getenv-int
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

(defun getenv (var)
  (uiop:getenvp var))

(defun (setf getenv) (new-value var)
  (setf (uiop:getenv var) new-value))

(defun getenv-int (var)
  (when-let (value (getenv var))
    (assert (every #'digit-char-p value))
    (parse-integer value)))

(defun appenv ()
  (or (getenv "APP_ENV") *default-app-env*))

(defun (setf appenv) (env)
  (setf (uiop:getenv "APP_ENV") env))
