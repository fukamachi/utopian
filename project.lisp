(defpackage utopian/project
  (:use #:cl)
  (:import-from #:cl-ppcre
                #:scan-to-strings)
  (:export #:package-system
           #:project-root
           #:project-path
           #:project-name))
(in-package #:utopian/project)

(defun package-system (package)
  (asdf:find-system
   (asdf/package-inferred-system::package-name-system (package-name package))))

(defun package-root-name (package)
  (string-downcase
   (ppcre:scan-to-strings "^[^/]+"
                          (asdf:component-name
                           (package-system package)))))

(defun project-root ()
  (asdf:component-pathname (package-system *package*)))

(defun project-path (path)
  (merge-pathnames path (project-root)))

(defun project-name ()
  (package-root-name *package*))
