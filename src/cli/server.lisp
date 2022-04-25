(defpackage #:utopian/cli/server
  (:use #:cl)
  (:import-from #:utopian/tasks
                #:server)
  (:import-from #:utopian/errors
                #:simple-task-error
                #:invalid-arguments)
  (:import-from #:just-getopt-parser
                #:getopt
                #:unknown-option
                #:required-argument-missing)
  (:export #:main))
(in-package #:utopian/cli/server)

(defun print-usage ()
  (format t "~&Usage: utopian server [OPTIONS]

OPTIONS
    --address
        Address to bind the server. (Default: 127.0.0.1)
    --port
        Port to listen. (Default: 5000)
"))

(defun invalid-arguments (message)
  (format *error-output* "~&~A~%" message)
  (print-usage)
  (error 'invalid-arguments))

(defun main (argv)
  (multiple-value-bind (options args)
      (handler-bind ((unknown-option #'invalid-arguments)
                     (required-argument-missing #'invalid-arguments))
        (getopt argv
                '((:address "address" :required)
                  (:port "port" :required))
                :options-everywhere t
                :error-on-unknown-option t
                :error-on-argument-missing t))
    (when args
      (invalid-arguments (format nil "~&Extra arguments: ~{'~A'~^, ~}~%" args)))

    (when (assoc :port options)
      (let ((port-number (parse-integer (cdr (assoc :port options)) :junk-allowed t)))
        (if (and port-number (> port-number 0))
            (setf (cdr (assoc :port options)) port-number)
            (invalid-arguments (format nil "~&Port number must be positive number.~%" args)))))

    (let ((app-file (merge-pathnames #P"app.lisp" *default-pathname-defaults*)))
      (unless (uiop:file-exists-p app-file)
        (error 'simple-task-error
               :format-control "'app.lisp' file not found."))
      ;; TODO: Use the project local Quicklisp by using Qlot.
      (apply #'server app-file (mapcan (lambda (opt)
                                         (list (car opt) (cdr opt)))
                                       options)))))
