(defpackage #:myblog/views/root
  (:use #:cl
        #:lsx)
  (:export #:index))
(in-package #:myblog/views/root)

(lsx:enable-lsx-syntax)

(defcomponent index ()
  ()
  (:render
   <html>
     <head>
       <title>Index - Myblog</title>
     </head>
     <body>
       <h1>Welcome</h1>
       <a href="entries">Show Entries</a>
     </body>
   </html>))
