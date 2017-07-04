(in-package #:cl-user)
(defpackage utopian/config
  (:use #:cl)
  (:import-from #:utopian/project
                #:project-path)
  (:import-from #:asdf/package-inferred-system
                #:package-inferred-system-file-dependencies)
  (:export #:*default-app-env*
           #:environment-config
           #:config
           #:appenv
           #:developmentp
           #:productionp))
(in-package #:utopian/config)

(defvar *config-cache*
  (make-hash-table :test 'equal))

(defvar *default-app-env* "development")

(defun environment-config (env)
  (let ((file (make-pathname :name env
                             :type "lisp"
                             :defaults (project-path #P"config/environments/"))))
    (when (probe-file file)
      (let ((modified-at (file-write-date file)))
        (cond
          ((< (car (gethash file *config-cache* '(0 . nil)))
              modified-at)
           #+quicklisp
           (ql:quickload (asdf/package-inferred-system::package-inferred-system-file-dependencies file)
                         :silent t)
           #-quicklisp
           (asdf:load-system (asdf/package-inferred-system::package-inferred-system-file-dependencies file))
           (let ((config (uiop:with-safe-io-syntax ()
                           (with-open-file (in file)
                             (uiop:eval-input in)))))
             (setf (gethash file *config-cache*)
                   (cons modified-at config))
             config))
          (t
           (cdr (gethash file *config-cache*))))))))

(defun config (&optional key)
  (let ((config (environment-config
                 (or (appenv) *default-app-env*))))
    (if key
        (getf config key)
        config)))

(defun appenv ()
  (let ((appenv (uiop:getenv "APP_ENV")))
    (when (and (stringp appenv)
               (not (string= appenv "")))
      appenv)))

(defun (setf appenv) (env)
  (setf (uiop:getenv "APP_ENV") env))

(defun developmentp ()
  (string= (appenv) "development"))

(defun productionp ()
  (find (appenv) '("production" "staging") :test #'string=))
