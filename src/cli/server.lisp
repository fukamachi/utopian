(defpackage #:utopian/cli/server
  (:use #:cl)
  (:import-from #:utopian/tasks
                #:server)
  (:import-from #:utopian/errors
                #:simple-task-error)
  (:export #:main))
(in-package #:utopian/cli/server)

(defun print-usage ()
  (format t "~&Usage: utopian server~%"))

(defun main ()
  (let ((app-file (merge-pathnames #P"app.lisp" *default-pathname-defaults*)))
    (unless (uiop:file-exists-p app-file)
      (error 'simple-task-error
             :format-control "'app.lisp' file not found."))
    ;; TODO: Use the project local Quicklisp by using Qlot.
    (server app-file)))
