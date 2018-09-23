(defpackage #:myblog/config/routes
  (:use #:cl
        #:utopian)
  (:export #:*routes*))
(in-package #:myblog/config/routes)

(defroutes *routes*
  (:controllers #P"../controllers/"))

(route :GET "/" "root:index")
(route :GET "/entries" "entries:listing")
(route :GET "/entries/:id" "entries:show")
