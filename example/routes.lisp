(defpackage #:myblog/routes
  (:use #:cl
        #:utopian
        #:myblog/views
        #:myblog/models)
  (:import-from #:assoc-utils
                #:aget)
  (:export #:index
           #:entries
           #:entry))
(in-package #:myblog/routes)

(defroute index ()
  (render))

(defroute entries ()
  (render :entries (mito:select-dao 'entry)))

(defroute entry (params)
  (let ((entry (mito:find-dao 'entry :id (aget params :id))))
    (unless entry
      (throw-code 404))
    (render :entry entry)))
