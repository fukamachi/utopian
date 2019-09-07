(defpackage #:{{project-name}}/controllers/{{controller}}
  (:use #:cl
        #:utopian
        #:{{project-name}}/views/{{controller}})
  (:export {{#actions}}#:{{name}}{{^last}}
           {{/last}}{{/actions}}))
(in-package #:{{project-name}}/controllers/{{controller}})
{{#actions}}

(defun {{name}} (params)
  (declare (ignore params))
  (render '{{name}}-page))
{{/actions}}
