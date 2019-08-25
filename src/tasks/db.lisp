(defpackage #:utopian/tasks/db
  (:use #:cl)
  (:import-from #:utopian/config
                #:db-settings
                #:appenv)
  (:import-from #:utopian/app
                #:with-config
                #:load-models)
  (:import-from #:utopian/file-loader
                #:eval-file)
  (:import-from #:cl-dbi)
  (:import-from #:mito)
  (:export #:connect
           #:create
           #:drop
           #:recreate
           #:reset
           #:migrate
           #:migration-status
           #:generate-migrations))
(in-package #:utopian/tasks/db)

(defun load-app (app)
  (if (pathnamep app)
      (eval-file app)
      app))

(defmacro with-connection (conn &body body)
  `(let ((mito:*connection* ,conn))
     (unwind-protect (progn ,@body)
       (dbi:disconnect mito:*connection*))))

(defun connect (app &optional (db :maindb))
  (with-config ((load-app app))
    (let ((config (db-settings db)))
      (unless config
        (error "No database settings. (APP_ENV=~A)" (appenv)))
      (apply #'dbi:connect config))))

(defun create (app)
  (let ((mito:*mito-logger-stream* t))
    (with-config ((load-app app))
      ;; TODO: Create all databases defined, not only :maindb.
      (let* ((config (copy-seq (db-settings)))
             (db-type (first config))
             (db-name (getf (rest config) :database-name)))
        (setf (getf (cdr config) :database-name)
              (ecase db-type
                (:mysql nil)
                (:postgres "postgres")
                (:sqlite3 db-name)))
        (with-connection (apply #'dbi:connect config)
          (handler-case
              (ecase db-type
                (:mysql (mito:execute-sql (format nil "CREATE DATABASE `~A` DEFAULT CHARACTER SET utf8" db-name)))
                (:postgres (mito:execute-sql (format nil "CREATE DATABASE \"~A\"" db-name)))
                (:sqlite3))
            (dbi:<dbi-error> (e)
              (format *error-output* "~&~A~%" e))
            (error (e)
              (format *error-output* "~&[~A] ~A~%"
                      (type-of e)
                      e))))))))

(defun drop (app)
  (let ((mito:*mito-logger-stream* t))
    (with-config ((load-app app))
      (let* ((config (copy-seq (db-settings)))
             (db-type (first config))
             (db-name (getf (rest config) :database-name)))
        (setf (getf (cdr config) :database-name)
              (ecase db-type
                (:mysql nil)
                (:postgres "postgres")
                (:sqlite3 db-name)))
        (with-connection (apply #'dbi:connect config)
          (handler-case
              (ecase db-type
                (:mysql (mito:execute-sql (format nil "DROP DATABASE `~A`" db-name)))
                (:postgres (mito:execute-sql (format nil "DROP DATABASE \"~A\"" db-name)))
                (:sqlite3))
            (dbi:<dbi-error> (e)
              (format *error-output* "~&~A~%" e))
            (error (e)
              (format *error-output* "~&[~A] ~A~%"
                      (type-of e)
                      e))))))))

(defun recreate (app)
  (drop app)
  (create app))

(defun reset (app)
  (drop app)
  (create app)
  (migrate app))

(defun migrate (app &key dry-run)
  (with-connection (connect app)
    (mito:migrate #P"db/" :dry-run dry-run)))

(defun migration-status (app)
  (with-connection (connect app)
    (mito:migration-status #P"db/")))

(defun generate-migrations (app)
  (let ((app (load-app app)))
    (with-connection (connect app)
      (load-models app)
      (mito:generate-migrations #P"db/"))))
