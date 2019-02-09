(defpackage #:{{project-name}}/config/environments/local
  (:use #:cl))
(in-package #:{{project-name}}/config/environments/local)

`(:database (:sqlite3
             :database-name ,(asdf:system-relative-pathname :{{project-name}} #P"db/{{project-name}}.db")))
