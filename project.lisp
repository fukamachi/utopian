(defpackage utopian/project
  (:use #:cl)
  (:import-from #:cl-ppcre
                #:scan-to-strings)
  (:import-from #:utopian/utils
                #:pathname-in-directory-p)
  (:export #:package-system
           #:*project-root*
           #:*project-name*
           #:project-root
           #:project-path
           #:project-name
           #:project-relative-path))
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

(defun project-relative-path (file)
  (unless (pathname-in-directory-p file (project-root))
    (error "File '~A' is not in the project directory." file))
  (pathname
   (subseq (namestring file)
           (length (namestring (project-root))))))
