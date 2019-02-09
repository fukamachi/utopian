(defpackage #:{{project-name}}/config/application
  (:use #:cl
        #:utopian)
  (:import-from #:lack.component
                #:to-app
                #:call)
  (:import-from #:lack
                #:builder)
  (:import-from #:cl-ppcre)
  (:export #:{{project-name}}-app))
(in-package #:{{project-name}}/config/application)

(defapp {{project-name}}-app ()
  ()
  (:config #P"environments/"))

(defmethod to-app ((app {{project-name}}-app))
  (builder
   (:static
    :path (lambda (path)
            (if (ppcre:scan "^(?:/assets/|/robot\\.txt$|/favicon\\.ico$)" path)
                path
                nil))
    :root (asdf:system-relative-pathname :{{project-name}} #P"public/"))
   :accesslog
   (:mito (config :database))
   :session
   (call-next-method)))
