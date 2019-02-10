(defpackage #:myblog/config/environments/local
  (:use #:cl))
(in-package #:myblog/config/environments/local)

`(:databases
  ((:maindb . (:sqlite3
               :database-name ,(asdf:system-relative-pathname :myblog #P"db/myblog.db")))))
