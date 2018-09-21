(defpackage #:myblog/app
  (:use #:cl
        #:myblog/controllers
        #:myblog/config/application))
(in-package #:myblog/app)

(make-instance 'blog-app
               :routes *routes*)
