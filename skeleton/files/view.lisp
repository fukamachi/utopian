(defpackage #:{{project-name}}/views/{{controller}}
  (:use #:cl
        #:utopian)
  (:import-from #:lsx
                #:enable-lsx-syntax)
  (:export {{#actions}}#:{{name}}-page{{^last}}
           {{/last}}{{/actions}}))
(in-package #:{{project-name}}/views/{{controller}})

(enable-lsx-syntax)
{{#actions}}

(defview {{name}}-page ()
  ()
  (:metaclass html-view-class)
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
