(defpackage utopian/project
  (:use #:cl)
  (:import-from #:cl-ppcre
                #:scan-to-strings)
  (:export #:package-system
           #:*project-root*
           #:*project-name*
           #:project-root
           #:project-path
           #:project-name))
(in-package #:utopian/project)

(defvar *project-root* nil)
(defvar *project-name* nil)

(defun package-system (package)
  (asdf:find-system
   (asdf/package-inferred-system::package-name-system (package-name package))))

(defun package-root-name (package)
  (string-downcase
   (ppcre:scan-to-strings "^[^/]+"
                          (package-name package))))

(defun project-root ()
  (or *project-root*
      (asdf:component-pathname (asdf:find-system (project-name) t))))

(defun project-path (path)
  (merge-pathnames path (project-root)))

(defun project-name ()
  (or *project-name*
      (package-root-name *package*)))
