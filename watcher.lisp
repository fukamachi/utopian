(in-package #:cl-user)
(defpackage utopian/watcher
  (:use #:cl)
  (:import-from #:utopian/project
                #:project-path)
  (:export #:start-watching))
(in-package :utopian/watcher)

(defun files-including-subdirectories (path)
  (append (uiop:directory-files path)
          (mapcan #'files-including-subdirectories
                  (uiop:subdirectories path))))

(defvar *files-modified* (make-hash-table :test 'equal))

(defun project-files-to-watch ()
  (flet ((lisp-file-p (file)
           (equal (pathname-type file) "lisp"))
         (dot-file-p (file)
           (char= (aref (pathname-name file) 0) #\.)))
    (remove-if-not
     #'lisp-file-p
     (remove-if
      #'dot-file-p
      (append
       (list (project-path #P"config/routes.lisp"))
       (files-including-subdirectories (project-path #P"controllers/"))
       (files-including-subdirectories (project-path #P"models/")))))))

(defun on-update (file)
  (handler-case
      (let ((*load-verbose* t)
            (*package* *package*)
            (*readtable* *readtable*)
            (*load-pathname* file)
            (*load-truename* file))
        (load file))
    (error (e)
      (format *error-output*
              "~&Error while loading ~A:~%~A: ~A~%"
              file
              (type-of e)
              e))))

(defun check-update ()
  (dolist (file (project-files-to-watch))
    (when (< (gethash file *files-modified* 0)
             (file-write-date file))
      (on-update file)
      (setf (gethash file *files-modified*) (file-write-date file)))))

(defun start-watching ()
  #+thread-support
  (bt:make-thread
   (lambda ()
     (dolist (file (project-files-to-watch))
       (setf (gethash file *files-modified*)
             (file-write-date file)))
     (loop
       (sleep 1)
       (check-update)))
   :initial-bindings `((*standard-output* . ,*standard-output*)
                       (*error-output* . ,*error-output*)
                       (*terminal-io* . ,*terminal-io*)))
  #-thread-support
  (warn "No thread support in this implementation. Skip watching."))
