(defpackage #:utopian/tasks
  (:use #:cl)
  (:import-from #:utopian/config
                #:config
                #:appenv)
  (:import-from #:utopian/app
                #:with-config)
  (:import-from #:clack
                #:clackup)
  (:export #:db-connect
           #:migrate
           #:migration-status
           #:generate-migrations
           #:server))
(in-package #:utopian/tasks)

(defun db-connect (app)
  (with-config ((if (pathnamep app)
                    (clack::eval-file app)
                    app))
    (let ((config (config :database)))
      (unless config
        (error "No database settings. (APP_ENV=~A)" (appenv)))
      (apply #'mito:connect-toplevel config))))

(defun migrate (app &key dry-run)
  (db-connect app)
  (mito:migrate #P"db/" :dry-run dry-run))

(defun migration-status (app)
  (db-connect app)
  (mito:migration-status #P"db/"))

(defun generate-migrations (app)
  (db-connect app)
  ;; TODO: load models
  (mito:generate-migrations #P"db/"))

(defun server (app)
  (clack:clackup app :use-thread nil))
