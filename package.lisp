(uiop:define-package utopian/package
  (:nicknames :utopian)
  (:use-reexport :utopian/view
                 :utopian/config
                 :utopian/db
                 :utopian/app
                 :utopian/skeleton
                 :utopian/watcher
                 :utopian/tasks)
  (:import-from :utopian/controller
                :controller
                :route
                :*action*)
  (:export :controller
           :route
           :*action*))
