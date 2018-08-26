(defpackage #:myblog/app
  (:use #:cl
        #:utopian
        #:myblog/routes)
  (:export #:blog-app))
(in-package #:myblog/app)

(defapp blog-app
  ((:GET "/" #'index)
   (:GET "/entries" #'entries)
   (:GET "/entries/:id" #'entry))
  (:config #P"config/environments/"))
