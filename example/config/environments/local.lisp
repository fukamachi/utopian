(defpackage #:myblog/config/environments/local
  (:use #:cl))
(in-package #:myblog/config/environments/local)

'(:database (:sqlite3
             :database-name #P"db/myblog.db"))
