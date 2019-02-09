(defpackage #:utopian/skeleton
  (:use #:cl)
  (:import-from #:mystic.template.file
                #:file
                #:file-mixin)
  (:import-from #:mystic.template.gitignore
                #:gitignore-mixin))
(in-package #:utopian/skeleton)

(defun skeleton-file (file)
  (asdf:system-relative-pathname :utopian
                                 (merge-pathnames file #P"skeleton/")))

(defun make-relative-pathname (path base-directory)
  (make-pathname
   :defaults path
   :device nil
   :directory (cons :relative
                    (nthcdr (length (pathname-directory base-directory)) (pathname-directory path)))))

(defun project-files ()
  (let ((base-directory (asdf:system-relative-pathname :utopian #P"skeleton/project/")))
    (labels ((directory-project-files (dir)
               (append
                (loop for file in (uiop:directory-files dir)
                      collect (make-instance 'file
                                             :path (namestring (make-relative-pathname file base-directory))
                                             :content (uiop:read-file-string file)))
                (loop for subdir in (uiop:subdirectories dir)
                      append (directory-project-files subdir)))))
      (directory-project-files base-directory))))

(defclass standard-project (mystic.template.file:file-mixin
                            mystic.template.gitignore:gitignore-mixin)
  ()
  (:default-initargs
   :name "utopian-project"
   :options
   (list
    (make-instance 'mystic:prompt-option
                   :name :project-name
                   :title "Project Name"
                   :requiredp t)
    (make-instance 'mystic:prompt-option
                   :name :description
                   :title "Description"
                   :default "")
    (make-instance 'mystic:prompt-option
                   :name :license
                   :title "License"
                   :default "")
    (make-instance 'mystic:prompt-option
                   :name :author
                   :title "Author")
    (make-instance 'mystic:option
                   :name :controller
                   :default "root")
    (make-instance 'mystic:option
                   :name :actions
                   :default '((:name . "index")
                              (:last . t))))
   :files
   (list*
    (make-instance 'file
                   :path "{{project-name}}.asd"
                   :content (uiop:read-file-string (skeleton-file #P"files/asdf.lisp")))
    (make-instance 'file
                   :path "controllers/root.lisp"
                   :content (uiop:read-file-string (skeleton-file #P"files/controller.lisp")))
    (make-instance 'file
                   :path "views/root.lisp"
                   :content (uiop:read-file-string (skeleton-file #P"files/view.lisp")))
    (project-files))))
