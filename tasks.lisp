(in-package #:cl-user)
(uiop:define-package utopian/tasks
  (:mix #:cl
        #:lake
        #:clack
        #:mito
        #:utopian/app
        #:utopian/watcher
        #:utopian/config
        #:utopian/db
        #:uiop)
  (:export #:load-tasks))
(in-package #:utopian/tasks)

(defun run-gulp-watch ()
  (uiop/run-program::%process-info-pid
   (uiop/run-program::%run-program '("node_modules/.bin/gulp" "watch")
                                   :output *standard-output*
                                   :error-output *error-output*
                                   :wait nil)))

(defun load-tasks ()
  (task "default" ("server"))

  (task "server" ()
    (let (pid)
      (unless (productionp)
        (utopian/watcher:start-watching)
        (setf pid (run-gulp-watch)))
      (clack:clackup (project-path #P"app.lisp")
                     :use-thread nil
                     :debug (not (productionp)))
      (when pid
        (uiop:run-program `("kill" ,(write-to-string pid))))))

  (namespace "db"
    (apply #'mito:connect-toplevel (connection-settings :maindb))
    (task "migrate" ()
      (mito:migrate (project-path (format nil "db/~A/" (appenv)))))
    (task "generate-migrations" ()
      (mito:generate-migrations (project-path (format nil "db/~A/" (appenv)))))))
