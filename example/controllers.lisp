(defpackage #:myblog/controllers
  (:use #:cl
        #:utopian)
  (:import-from #:myblog/controllers/root)
  (:import-from #:myblog/controllers/entries)
  (:export #:*routes*))
(in-package #:myblog/controllers)

(defroutes *routes*
  ((:GET "/" #'myblog/controllers/root:index)
   (:GET "/entries" #'myblog/controllers/entries:listing)
   (:GET "/entries/:id" #'myblog/controllers/entries:show))
  (:directory #P"controllers/"))
