(defpackage #:myblog/app
  (:use #:cl
        #:myblog/config/routes
        #:myblog/config/application))
(in-package #:myblog/app)

(make-instance 'blog-app
               :routes *routes*
               :models #P"models/")
