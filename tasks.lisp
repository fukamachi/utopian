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

(defun server (app-file)
  (check-type app-file pathname)
  (unless (probe-file app-file)
    (error 'file-not-found :file app-file))
  (let ((package-name (second (asdf/package-inferred-system::file-defpackage-form app-file))))
    (unless (find-package package-name)
      (handler-case
          (progn
            #+quicklisp (ql:quickload package-name)
            #-quicklisp (asdf:load-system package-name))
        (#+quicklisp ql:system-not-found
         #-quicklisp asdf:missing-component ()
          (error 'system-not-found :system package-name)))))
  (clack:clackup app-file :use-thread nil))

(defun read-new-value (name &optional default)
  (format t "~A~@[ [~A]~]: " name (if (equal default "") nil default))
  (force-output)
  (list (read-line)))

(define-condition ask-for-value ()
  ((name :initarg :name))
  (:report (lambda (condition stream)
             (format stream "'~A' is missing."
                     (slot-value condition 'name)))))

(defmacro check-and-ask-for (value name &optional default)
  (let ((g-value (gensym "VALUE"))
        (g-name (gensym "NAME"))
        (g-default (gensym "DEFAULT"))
        (new-value (gensym "NEW-VALUE")))
    `(let ((,g-value ,value)
           (,g-name ,name)
           (,g-default ,default))
       (or ,g-value
           (block nil
             (restart-case
                 (error 'ask-for-value :name ,g-name)
               (use-value (,new-value)
                 :report ,(format nil "Use a value for '~A' (Default: ~S)" name default)
                 :interactive (lambda () (read-new-value ,g-name ,g-default))
                 (return
                   (if (string= ,new-value "")
                       ,g-default
                       ,new-value)))))))))

(defun new (destination &rest options &key project-name description license author)
  (let ((destination (uiop:ensure-directory-pathname destination)))
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
      (setf (getf options :license)
            (check-and-ask-for license "License" ""))
      (setf (getf options :author)
            (check-and-ask-for author "Author" ""))
      (mystic:render (make-instance 'standard-project)
                     options
                     destination)
      destination)))
