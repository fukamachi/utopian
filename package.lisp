(uiop:define-package utopian/package
  (:nicknames :utopian)
  (:use-reexport :utopian/view
                 :utopian/config
                 :utopian/db
                 :utopian/app
                 :utopian/skeleton))
