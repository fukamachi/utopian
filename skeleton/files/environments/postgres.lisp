(defpackage #:{{project-name}}/config/environments/{{environment}}
  (:use #:cl))
(in-package #:{{project-name}}/config/environments/{{environment}})

`(:databases
  ((:maindb . (:postgres
               :database-name "{{project-name}}"
               :username "{{project-name}}"
               :password ""))))
