(defpackage #:utopian/skeleton
  (:use #:cl)
  (:import-from #:mystic.template.file
                #:file
                #:file-mixin)
  (:import-from #:mystic
                #:render-template
                #:prompt-option)
  (:import-from #:mystic.util
                #:render-string
                #:write-file)
  (:export #:standard-project))
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

(defclass standard-project (mystic.template.file:file-mixin)
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
    (make-instance 'mystic:prompt-option
                   :name :database
                   :title "Database"
                   :default "sqlite3"))
   :files (project-files)))

(defun normalize-database (value)
  (check-type value string)
  (cond
    ((member value '("sqlite" "sqlite3") :test 'string-equal)
     "sqlite3")
    ((member value '("postgres" "postgresql") :test 'string-equal)
     "postgres")
    ((member value '("mysql") :test 'string-equal)
     "mysql")
    (t (error "Unsupported database: ~S" value))))

(defmethod mystic:render-template progn ((template standard-project) options directory)
  (declare (type list options)
           (type pathname directory))
  (let ((options (append '(:controller "root"
                           :actions (((:name . "index")
                                      (:last . t)))
                           :environment "local")
                         options)))
    (flet ((render-and-write (file destination)
             (let ((file-path (parse-namestring (render-string destination options)))
                   (content (render-string (uiop:read-file-string (skeleton-file file))
                                           options)))
               (write-file content (merge-pathnames file-path directory)))))
      (render-and-write #P"files/asdf.lisp" "{{project-name}}.asd")
      (render-and-write #P"files/controller.lisp" "controllers/root.lisp")
      (render-and-write #P"files/view.lisp" "views/root.lisp")
      (render-and-write
       (make-pathname :name (normalize-database (getf options :database))
                      :type "lisp"
                      :defaults #P"files/environments/")
       "config/environments/{{environment}}.lisp"))))
