(defpackage #:myblog/views
  (:use #:cl
        #:utopian
        #:myblog/models)
  (:export #:index
           #:entries
           #:entry))
(in-package #:myblog/views)

(defview index ()
  ()
  (:render
    (html
      (head
        (title "Index | Myblog"))
      (body
        (h1 "Welcome")
        (a (:href "/entries") "Show Entries")))))

(defview entries ()
  (entries)
  (:render
    (html
      (head
        (title "Entries | Myblog"))
      (body
        (h1 "Entries")
        (ul
         (mapcar (lambda (entry)
                   (li
                    (a (:href (format nil "/entries/~A" (mito:object-id entry)))
                       (entry-title entry))))
                 entries))))))

(defview entry ()
  (entry)
  (:render
   (html
    (head
     (title (format nil "~A | Myblog" (entry-title entry))))
    (body
     (h1 (entry-title entry))
     (p "Blah blah blah")))))
