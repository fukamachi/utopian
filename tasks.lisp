(defpackage #:utopian/tasks
  (:use #:cl
        #:utopian/errors)
  (:import-from #:utopian/config
                #:config
                #:appenv)
  (:import-from #:utopian/app
                #:with-config
                #:load-models)
  (:import-from #:utopian/file-loader
                #:eval-file)
  (:import-from #:utopian/skeleton
                #:standard-project)
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
           #:server
           #:new))
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

(defun server (app-file)
  (check-type app-file pathname)
  (unless (probe-file app-file)
    (error 'file-not-found :file app-file))
  (let ((package-name (second (asdf/package-inferred-system::file-defpackage-form app-file))))
    (unless (find-package package-name)
      (handler-case
          (progn
            #+quicklisp (ql:quickload package-name)
            #-quicklisp (asdf:load-system package-name))
        (#+quicklisp ql:system-not-found
         #-quicklisp asdf:missing-component ()
          (error 'system-not-found package-name)))))
  (clack:clackup app-file :use-thread nil))

(defun new (destination &rest options &key project-name description license author)
  (declare (ignore description license author))
  (let* ((destination (uiop:ensure-directory-pathname destination))
         (project-name (or project-name
                           (car (last (pathname-directory destination)))))
         (project-name
           (map 'string (lambda (char)
                          (if (char= char #\Space)
                              #\-
                              (char-downcase char)))
                project-name)))
    (setf (getf options :project-name) project-name)
    (mystic:render (make-instance 'standard-project)
                   options
                   destination)
    destination))
