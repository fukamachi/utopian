(defpackage #:utopian/tasks
  (:use #:cl
        #:utopian/errors)
  (:import-from #:utopian/skeleton
                #:standard-project)
  (:import-from #:clack
                #:clackup)
  (:export #:server
           #:new
           #:ask-for-value
           #:use-value))
(in-package #:utopian/tasks)

(defun server (app-file &rest args &key address port)
  (declare (ignore address port))
  (check-type app-file pathname)
  (unless (probe-file app-file)
    (error 'file-not-found :file app-file))
  (let ((package-name (second (asdf/package-inferred-system::file-defpackage-form app-file))))
    (unless (find-package package-name)
      (handler-case
          (progn
            #+quicklisp (ql:quickload package-name)
            #-quicklisp (asdf:load-system package-name))
        #+quicklisp
        (ql:system-not-found (e)
          (error 'system-not-found :system (ql:system-not-found-name e)))
        #-quicklisp
        (asdf:missing-component (e)
          (error 'system-not-found :system (asdf/find-component:missing-requires e))))))
  (apply #'clack:clackup app-file :use-thread nil
         args))

(defun read-new-value (name &optional default choices)
  (assert (or (null choices) (< 1 (length choices))))
  (loop
    (format t "~A~@[ [~A]~]~@[ one of ~{~A~^, ~} or ~A~]: "
            name
            (if (equal default "") nil default)
            (butlast choices)
            (car (last choices)))
    (force-output)
    (let ((line (read-line)))
      (when (or (null choices)
                (member line choices :test #'string=)
                default)
        (return (list line))))))

(define-condition ask-for-value ()
  ((name :initarg :name))
  (:report (lambda (condition stream)
             (format stream "'~A' is missing."
                     (slot-value condition 'name)))))

(defmacro check-and-ask-for (value name &optional default choices)
  (let ((g-value (gensym "VALUE"))
        (g-name (gensym "NAME"))
        (g-default (gensym "DEFAULT"))
        (g-choices (gensym "CHOICES"))
        (new-value (gensym "NEW-VALUE")))
    `(let ((,g-value ,value)
           (,g-name ,name)
           (,g-default ,default)
           (,g-choices ,choices))
       (or ,g-value
           (block nil
             (restart-case
                 (error 'ask-for-value :name ,g-name)
               (use-value (,new-value)
                 :report ,(format nil "Use a value for '~A' (Default: ~S)" name default)
                 :interactive (lambda () (read-new-value ,g-name ,g-default ,g-choices))
                 (return
                   (if (string= ,new-value "")
                       ,g-default
                       ,new-value)))))))))

(defun new (destination &rest options &key project-name description author database license)
  (let ((destination (uiop:ensure-absolute-pathname (uiop:ensure-directory-pathname destination)
                                                    *default-pathname-defaults*)))
    (when (uiop:directory-exists-p destination)
      (error 'directory-already-exists
             :directory destination))
    (let* ((project-name (or project-name
                             (car (last (pathname-directory destination)))))
           (project-name
             (map 'string (lambda (char)
                            (if (char= char #\Space)
                                #\-
                                (char-downcase char)))
                  project-name)))
      (setf (getf options :project-name) project-name)
      (setf (getf options :description)
            (check-and-ask-for description "Description" ""))
      (setf (getf options :author)
            (check-and-ask-for author "Author" ""))
      (setf (getf options :database)
            (check-and-ask-for database "Database" "sqlite3" '("sqlite3" "postgres" "mysql")))
      (setf (getf options :license)
            (check-and-ask-for license "License" ""))
      (mystic:render (make-instance 'standard-project)
                     options
                     destination)
      destination)))
