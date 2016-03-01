(uiop:define-package utopian/package
  (:nicknames :utopian)
  (:use-reexport :utopian/view
                 :utopian/config
                 :utopian/db
                 :utopian/app
                 :utopian/controller
                 :utopian/skeleton
                 :utopian/watcher
                 :utopian/tasks))
