(defpackage #:utopian/utils
  (:use #:cl)
  (:export #:file-package-name
           #:package-system))
(in-package #:utopian/utils)

;; The file pathname must be an absolute one.
(defun file-package-name (file)
  (second (asdf/package-inferred-system::file-defpackage-form file)))

(defun package-system (package)
  (asdf:find-system
   (asdf/package-inferred-system::package-name-system (package-name package))))
