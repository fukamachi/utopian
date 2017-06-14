(in-package #:cl-user)
(uiop:define-package utopian/tasks
  (:mix #:cl
        #:lake
        #:clack
        #:mito
        #:utopian/project
        #:utopian/watcher
        #:utopian/config
        #:utopian/db
        #:uiop)
  (:export #:load-tasks))
(in-package #:utopian/tasks)

(defun connect-to-db ()
  (apply #'mito:connect-toplevel (connection-settings :maindb)))

(defun load-models ()
  (let ((root-models-path (project-path "models/")))
    (labels ((directory-models (dir)
               (append
                (uiop:directory-files dir "*.lisp")
                (mapcan #'directory-models (uiop:subdirectories dir))))
             (model-name (file)
               (format nil
                       "~A/models~{/~A~}/~A"
                       (project-name)
                       (subseq (pathname-directory file)
                               (length (pathname-directory root-models-path)))
                       (pathname-name file))))
      (dolist (model-file (directory-models root-models-path))
        #+quicklisp
        (ql:quickload (model-name model-file) :silent t)
        #-quicklisp
        (asdf:load-system (model-name model-file))))))

(defun task-migrate ()
  (mito:migrate (project-path "db/")))

(defun task-generate-migrations ()
  (mito:generate-migrations (project-path "db/")))

(defun load-tasks ()
  (task "default" ("server"))

  (task "server" ()
    (clack:clackup (project-path #P"app.lisp")
                   :use-thread nil
                   :debug (not (productionp))))

  (namespace "db"
    (task "migrate" ()
      (connect-to-db)
      (load-models)
      (task-migrate))
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
          (load seeds))))
    (task "recreate" ()
      (apply #'mito:connect-toplevel
             (car (connection-settings :maindb))
             :database-name "postgres"
             (alexandria:remove-from-plist
              (cdr (connection-settings :maindb))
              :database-name))
      (let ((dbname (getf (cdr (connection-settings :maindb)) :database-name)))
        (mito:execute-sql
         (format nil "DROP DATABASE \"~A\"" dbname))
        (mito:execute-sql
         (format nil "CREATE DATABASE \"~A\"" dbname)))
      (mapc #'delete-file (uiop:directory-files (project-path #P"db/migrations/")))
      (connect-to-db)
      (load-models)
      (task-generate-migrations)
      (task-migrate))))
