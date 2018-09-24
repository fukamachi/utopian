(defpackage #:myblog/controllers/entries
  (:use #:cl
        #:utopian
        #:myblog/models)
  (:import-from #:assoc-utils
                #:aget)
  (:export #:listing
           #:show))
(in-package #:myblog/controllers/entries)

(defroute listing ()
  (render :entries (mito:select-dao 'entry)))

(defroute show (params)
  (let ((entry (mito:find-dao 'entry :id (aget params :id))))
    (unless entry
      (throw-code 404))
    (render :entry entry)))
