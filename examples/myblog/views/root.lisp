(defpackage #:myblog/views/root
  (:use #:cl
        #:lsx
        #:utopian)
  (:export #:index-page))
(in-package #:myblog/views/root)

(lsx:enable-lsx-syntax)

(defview index-page ()
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
