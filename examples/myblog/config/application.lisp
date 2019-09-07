(defpackage #:myblog/config/application
  (:use #:cl
        #:utopian)
  (:import-from #:lack.component
                #:to-app
                #:call)
  (:import-from #:lack
                #:builder)
  (:import-from #:cl-ppcre)
  (:export #:blog-app))
(in-package #:myblog/config/application)

(defapp blog-app ()
  ()
  (:config #P"environments/"))

(defmethod to-app ((app blog-app))
  (builder
   (:static
    :path (lambda (path)
            (if (ppcre:scan "^(?:/assets/|/robot\\.txt$|/favicon\\.ico$)" path)
                path
                nil))
    :root (asdf:system-relative-pathname :myblog #P"public/"))
   :accesslog
   (:mito (db-settings :maindb))
   :session
   (call-next-method)))
