# Utopian

## Usage

```common-lisp
(defmodel entry ()
  ((title :col-type :text)))

(defview index ()
  ()
  (:render
    (html
      (head
        (title "Index"))
      (body
        (h1 "Welcome")
        (a (:href "/entries") "Show Entries")))))

(defview entries ()
  (entries)
  (:render
    (html
      (head
        (title "Entries"))
      (body
        (h1 "Entries")
        (ul
         (mapcar (lambda (entry)
                   (li
                    (a (:href #?"/entries/${(object-id entry)}")
                       (entry-title entry))))
                 entries))))))

(defroute index ()
  (render))

(defroute entries ()
  (render :entries (select-dao 'entry)))

(defroute entry (params)
  (render :entry (find-dao 'entry :id (aget params :id))))

(defapp blog-app
  ((:GET "/" #'index)
   (:GET "/entries" #'entries)
   (:GET "/entries/:id" #'entry))
  (:config #P"config/environments/"))

(clackup blog-app)
```
