(uiop:define-package #:utopian/tasks
  (:mix #:cl
        #:lake
        #:clack
        #:mito
        #:utopian/project
        #:utopian/watcher
        #:utopian/config
        #:utopian/db
        #:uiop)
  (:import-from #:utopian/utils
                #:file-package-name)
  (:import-from #:bordeaux-threads)
  (:export #:load-tasks))
(in-package #:utopian/tasks)

(defun connect-to-db (&key (database-name nil database-specified-p))
  (destructuring-bind (driver &rest args)
      (connection-settings :maindb)
    (when (and database-specified-p
               (not (eq driver :sqlite3)))
      (setf args (append `(:database-name ,database-name) args)))
    (apply #'mito:connect-toplevel driver args)))

(defun load-file (file)
  (let ((system-name (file-package-name file)))
    #+quicklisp
    (ql:quickload system-name :silent t)
    #-quicklisp
    (asdf:load-system system-name)))

(defun load-models ()
  (labels ((directory-models (dir)
             (append
              (uiop:directory-files dir "*.lisp")
              (mapcan #'directory-models (uiop:subdirectories dir)))))
    (dolist (model-file (directory-models (project-path "models/")))
      (load-file model-file))))

(defun task-migrate (&key dry-run)
  (mito:migrate (project-path "db/") :dry-run dry-run))

(defun task-generate-migrations ()
  (mito:generate-migrations (project-path "db/")))

(defun spawn (commands)
  (let ((thread
          (bt:make-thread
           (lambda ()
             (uiop:run-program commands
                               :output :interactive
                               :error-output :interactive))
           :initial-bindings `((*standard-output* . ,*standard-output*)
                               (*error-output* . ,*error-output*)))))
    #+sbcl
    (push (lambda ()
            (when (and (bt:thread-alive-p thread)
                       (not (eq (bt:current-thread) thread)))
              (bt:destroy-thread thread)))
          sb-ext:*exit-hooks*)
    thread))

(defun load-tasks ()
  (task "default" ("server"))

  (task "build-assets" ()
    (uiop:run-program '("npm" "run" "build")
                      :output :interactive
                      :error-output :interactive))

  (task "webpack-dev-server" ()
    (spawn '("npm" "run" "dev-server")))

  (task "server" ()
    (if (productionp)
        (execute "build-assets")
        (execute "webpack-dev-server"))
    (clack:clackup (project-path #P"app.lisp")
                   :use-thread nil
                   :debug (not (productionp))))

  (namespace "db"
    (task "migrate" ()
      (connect-to-db)
      (load-models)
      (task-migrate))
    (namespace "migrate" ()
      (task "test" ()
        (connect-to-db)
        (load-models)
        (task-migrate :dry-run t)))
    (task "generate-migrations" ()
      (connect-to-db)
      (load-models)
      (task-generate-migrations))
    (task "seed" ()
      (connect-to-db)
      (let ((seeds (project-path #P"db/seeds.lisp")))
        (unless (probe-file seeds)
          (error "'db/seeds.lisp' doesn't exist."))
        (mito.logger:with-sql-logging
          (load-file seeds))))
    (task "create" ()
      (let ((mito:*mito-logger-stream* *standard-output*))
        (case (car (connection-settings :maindb))
          (:postgres
           (connect-to-db :database-name "postgres")
           (let ((dbname (getf (cdr (connection-settings :maindb)) :database-name)))
             (mito:execute-sql
              (format nil "CREATE DATABASE \"~A\"" dbname))))
          (:mysql
           (connect-to-db :database-name nil)
           (let ((dbname (getf (cdr (connection-settings :maindb)) :database-name)))
             (mito:execute-sql
              (format nil "CREATE DATABASE \"~A\"" dbname))))
          (:sqlite3
           (connect-to-db)))
        (load-models)
        (task-generate-migrations)
        (task-migrate)))
    (task "drop" ()
      (case (car (connection-settings :maindb))
        (:postgres
         (connect-to-db :database-name "postgres")
         (let ((dbname (getf (cdr (connection-settings :maindb)) :database-name)))
           (mito:execute-sql
            (format nil "DROP DATABASE \"~A\"" dbname))))
        (:mysql
         (connect-to-db :database-name nil)
         (let ((dbname (getf (cdr (connection-settings :maindb)) :database-name)))
           (mito:execute-sql
            (format nil "DROP DATABASE \"~A\"" dbname))))
        (:sqlite3
         (delete-file (getf (cdr (connection-settings :maindb)) :database-name)))))
    (task "recreate" ()
      (lake:execute "drop")
      (lake:execute "create"))))
