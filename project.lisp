(defpackage #:utopian/project
  (:use #:cl)
  (:import-from #:cl-ppcre
                #:scan-to-strings)
  (:export #:project-root
           #:project-path
           #:project-name
           #:project-relative-path
           #:project-models))
(in-package #:utopian/project)

(defvar *project-root* nil)
(defvar *project-name* nil)

(defun package-root-name (package)
  (string-downcase
   (ppcre:scan-to-strings "^[^/]+"
                          (package-name package))))

(defun project-root ()
  (or *project-root*
      (let ((system (asdf:find-system (project-name) nil)))
        (if system
            (asdf:component-pathname system)
            *default-pathname-defaults*))))

(defun (setf project-root) (root)
  (setf *project-root* root))

(defun project-path (path)
  (merge-pathnames path (project-root)))

(defun project-name ()
  (or *project-name*
      (package-root-name *package*)))

(defun (setf project-name) (name)
  (setf *project-name* name))

(defun project-relative-path (file)
  (unless (uiop:subpathp file (project-root))
    (error "File '~A' is not in the project directory." file))
  (pathname
   (subseq (namestring file)
           (length (namestring (project-root))))))

(defun project-models (&optional (project-root (project-root)))
  (labels ((directory-models (dir)
             (append
              (uiop:directory-files dir "*.lisp")
              (mapcan #'directory-models (uiop:subdirectories dir)))))
    (directory-models (merge-pathnames "models/" project-root))))
