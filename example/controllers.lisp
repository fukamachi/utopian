(defpackage #:myblog/controllers
  (:use #:cl
        #:utopian)
  (:export #:*routes*))
(in-package #:myblog/controllers)

(defroutes *routes*
  ((:GET "/" "root:index")
   (:GET "/entries" "entries:listing")
   (:GET "/entries/:id" "entries:show"))
  (:directory #P"controllers/"))
