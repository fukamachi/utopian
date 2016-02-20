(in-package #:cl-user)
(uiop:define-package utopian/tasks
  (:mix #:cl
        #:lake
        #:clack
        #:mito
        #:utopian/app
        #:utopian/watcher
        #:utopian/config
        #:utopian/db)
  (:export #:load-tasks))
(in-package #:utopian/tasks)

(defun load-tasks ()
  (task "default" ("server"))

  (task "server" ()
    (unless (productionp)
      (utopian/watcher:start-watching))
    (clack:clackup (project-path #P"app.lisp")
                   :use-thread nil
                   :debug (productionp)))

  (namespace "db"
    (apply #'mito:connect-toplevel (connection-settings :maindb))
    (task "migrate" ()
      (mito:migrate (project-path (format nil "db/~A/" (appenv)))))
    (task "generate-migrations" ()
      (mito:generate-migrations (project-path (format nil "db/~A/" (appenv)))))))
