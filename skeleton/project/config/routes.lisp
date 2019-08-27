(defpackage #:{{project-name}}/config/routes
  (:use #:cl
        #:utopian)
  (:export #:*routes*))
(in-package #:{{project-name}}/config/routes)

(defroutes *routes* ()
  (:controllers #P"../controllers/"))

(route :GET "/" "root:index")
