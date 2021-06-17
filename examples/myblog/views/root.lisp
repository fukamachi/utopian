(defpackage #:myblog/views/root
  (:use #:cl
        #:lsx
        #:utopian)
  (:export #:index-page))
(in-package #:myblog/views/root)

(named-readtables:in-readtable :lsx-syntax)

(defview index-page ()
  ()
  (:metaclass html-view-class)
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
