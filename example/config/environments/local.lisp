(defpackage #:myblog/config/environments/local
  (:use #:cl))
(in-package #:myblog/config/environments/local)

`(:database (:sqlite3
             :database-name ,(asdf:system-relative-pathname :myblog #P"db/myblog.db")))
