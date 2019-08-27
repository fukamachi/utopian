(defpackage #:{{project-name}}/app
  (:use #:cl
        #:{{project-name}}/config/routes
        #:{{project-name}}/config/application))
(in-package #:{{project-name}}/app)

(make-instance '{{project-name}}-app
               :routes *routes*
               :models #P"models/")
