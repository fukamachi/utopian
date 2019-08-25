(defpackage #:{{project-name}}/config/environments/{{environment}}
  (:use #:cl))
(in-package #:{{project-name}}/config/environments/{{environment}})

`(:databases
  ((:maindb . (:sqlite3
               :database-name ,(asdf:system-relative-pathname :{{project-name}} #P"db/{{environment}}.db")))))
