(defpackage #:myblog/config/application
  (:use #:cl
        #:utopian)
  (:import-from #:lack.component
                #:to-app
                #:call)
  (:import-from #:lack
                #:builder)
  (:import-from #:mito)
  (:import-from #:dbi)
  (:export #:blog-app))
(in-package #:myblog/config/application)

(defapp blog-app ()
  ()
  (:config #P"environments/"))

(defmethod to-app ((app blog-app))
  (builder
   :session
   (lambda (app)
     (lambda (env)
       (let* ((db-config (config :database))
              (mito:*connection* (and db-config (apply #'dbi:connect-cached db-config))))
         (funcall app env))))
   (call-next-method)))
