(defpackage #:{{project-name}}/views/{{controller}}
  (:use #:cl
        #:lsx
        #:utopian)
  (:export {{#actions}}#:{{name}}-page{{^last}}
           {{/last}}{{/actions}}))
(in-package #:{{project-name}}/views/{{controller}})

(named-readtables:in-readtable :lsx-syntax)
{{#actions}}

(defview {{name}}-page ()
  ()
  (:render
   <html>
     <head>
       <title>{{name}} | {{project-name}}</title>
     </head>
     <body>
       <h1>{{name}}</h1>
     </body>
   </html>))
{{/actions}}
