(defpackage #:utopian/cli/generate
  (:use #:cl)
  (:import-from #:utopian/tasks/db
                #:generate-migrations)
  (:import-from #:utopian/errors
                #:invalid-arguments
                #:unknown-command
                #:file-not-found))
(in-package #:utopian/cli/generate)

(defun print-usage ()
  (format *error-output* "~&Usage: utopian generate COMMAND
COMMANDS
    migration
        Generate a migration file.
"))

(defun main (&optional command)
  (unless command
    (print-usage)
    (error 'invalid-arguments))
  (let ((app-file #P"app.lisp"))
    (unless (probe-file app-file)
      (error 'file-not-found :file app-file))
    (cond
      ((equal command "migration")
       (utopian/tasks/db:generate-migrations app-file))
      (t
        (error 'unknown-command
               :given command
               :candidates '("migration"))))))
