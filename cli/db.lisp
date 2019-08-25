(defpackage #:utopian/cli/db
  (:use #:cl)
  (:import-from #:utopian/errors
                #:invalid-arguments
                #:unknown-command
                #:file-not-found)
  (:import-from #:utopian/tasks/db)
  (:export #:main))
(in-package #:utopian/cli/db)

(defun print-usage ()
  (format *error-output* "~&Usage: utopian db COMMAND
COMMANDS
    create
        Create a database

    recreate
        Drop and create a new database

    migrate
        Apply migrations.

    migrate:status
        See the status of the database schema version.
"))

(defun main (&optional command)
  (unless command
    (print-usage)
    (error 'invalid-arguments))
  (let ((app-file #P"app.lisp"))
    (unless (probe-file app-file)
      (error 'file-not-found :file app-file))
    (cond
      ((equal command "create")
       (utopian/tasks/db:create app-file))
      ((equal command "recreate")
       (utopian/tasks/db:recreate app-file))
      ((equal command "migrate")
       (utopian/tasks/db:migrate app-file))
      ((equal command "migrate:status")
       (utopian/tasks/db:migration-status app-file))
      ((equal command "generate-migrations")
       (utopian/tasks/db:generate-migrations app-file))
      (t
       (error 'unknown-command
              :given command
              :candidates '("create" "recreate" "migrate" "migrate:status" "generate-migrations"))))))
