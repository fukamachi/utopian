(defpackage #:utopian/file-loader
  (:use #:cl)
  (:import-from #:cl-ppcre)
  (:export #:load-file
           #:eval-file
           #:intern-rule))
(in-package #:utopian/file-loader)

(defun load-file (file &optional silent)
  (let ((package (second (asdf/package-inferred-system::file-defpackage-form file)))
        (retrying (make-hash-table :test 'equal)))
    (unless package
      (error "File '~A' is not a package inferred system." file))
    (handler-bind (#+asdf3.3 (asdf/operate:recursive-operate #'muffle-warning)
                   (asdf:missing-component
                     (lambda (e)
                       (unless (gethash (asdf::missing-requires e) retrying)
                         (setf (gethash (asdf::missing-requires e) retrying) t)
                         (when (find :quicklisp *features*)
                           (uiop:symbol-call '#:ql-dist '#:ensure-installed
                                             (uiop:symbol-call '#:ql-dist '#:find-system
                                                               (asdf::missing-requires e)))
                           (invoke-restart (find-restart 'asdf:clear-configuration-and-retry e)))))))
      (if (find :quicklisp *features*)
          (uiop:symbol-call '#:ql '#:quickload package :silent silent)
          (asdf:load-system package)))
    package))

(defvar *file-cache*
  (make-hash-table :test 'equal))

(defun file-cache (file fn)
  (let ((modified-at (file-write-date file)))
    (cond
      ((< (car (gethash file *file-cache* '(0 . nil)))
          modified-at)
       (let ((value (funcall fn)))
         (setf (gethash file *file-cache*) (cons modified-at value))
         value))
      (t
       (cdr (gethash file *file-cache*))))))

(defmacro with-file-cache (file &body body)
  `(file-cache ,file (lambda () ,@body)))

(defun %eval-file (file)
  (let ((dependencies (asdf/package-inferred-system::package-inferred-system-file-dependencies file)))
    (when dependencies
      (handler-bind (#+asdf3.3 (asdf/operate:recursive-operate #'muffle-warning))
        #+quicklisp
        (ql:quickload dependencies :silent t)
        #-quicklisp
        (asdf:load-system dependencies))))
  (let ((*package* *package*)
        (*readtable* (copy-readtable))
        (*load-pathname* file)
        (*load-truename* file))
    (with-open-file (in file)
      (uiop:eval-input in))))

(defun eval-file (file)
  (with-file-cache file (%eval-file file)))

(defun intern-rule (rule directory)
  (destructuring-bind (package-name action-name)
      (ppcre:split "::?" rule)
    (let* ((file
             (make-pathname :name package-name
                            :type "lisp"
                            :defaults directory))
           (package (find-package (load-file file))))
      (intern (string-upcase action-name) package))))
