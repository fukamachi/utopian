(defpackage #:utopian/tasks
  (:use #:cl)
  (:import-from #:utopian/config
                #:config
                #:appenv)
  (:import-from #:utopian/app
                #:with-config
                #:load-models)
  (:import-from #:utopian/file-loader
                #:eval-file)
  (:import-from #:mito)
  (:import-from #:clack
                #:clackup)
  (:export #:db-connect
           #:create-db
           #:drop-db
           #:recreate-db
           #:reset-db
           #:migrate
           #:migration-status
           #:generate-migrations
           #:server))
(in-package #:utopian/tasks)

(defun load-app (app)
  (if (pathnamep app)
      (eval-file app)
      app))

(defmacro with-connection (conn &body body)
  `(let ((mito:*connection* ,conn))
     (unwind-protect (progn ,@body)
       (dbi:disconnect mito:*connection*))))

(defun db-connect (app)
  (with-config ((load-app app))
    (let ((config (config :database)))
      (unless config
        (error "No database settings. (APP_ENV=~A)" (appenv)))
      (apply #'dbi:connect config))))

(defun create-db (app)
  (let ((mito:*mito-logger-stream* t))
    (with-config ((load-app app))
      (let* ((config (copy-seq (config :database)))
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

(defun drop-db (app)
  (let ((mito:*mito-logger-stream* t))
    (with-config ((load-app app))
      (let* ((config (copy-seq (config :database)))
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

(defun recreate-db (app)
  (drop-db app)
  (create-db app))

(defun reset-db (app)
  (drop-db app)
  (create-db app)
  (migrate app))

(defun migrate (app &key dry-run)
  (with-connection (db-connect app)
    (mito:migrate #P"db/" :dry-run dry-run)))

(defun migration-status (app)
  (with-connection (db-connect app)
    (mito:migration-status #P"db/")))

(defun generate-migrations (app)
  (let ((app (load-app app)))
    (with-connection (db-connect app)
      (load-models app)
      (mito:generate-migrations #P"db/"))))

(defun server (app)
  (clack:clackup app :use-thread nil))
