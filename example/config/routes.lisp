(defpackage #:myblog/config/routes
  (:use #:cl
        #:utopian)
  (:export #:*routes*))
(in-package #:myblog/config/routes)

(defroutes *routes*
  ((:GET "/" "root:index")
   (:GET "/entries" "entries:listing")
   (:GET "/entries/:id" "entries:show"))
  (:directory #P"../controllers/"))
