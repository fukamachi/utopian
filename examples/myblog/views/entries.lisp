(defpackage #:myblog/views/entries
  (:use #:cl
        #:lsx
        #:myblog/models/entry
        #:utopian)
  (:export #:listing-page
           #:show-page))
(in-package #:myblog/views/entries)

(named-readtables:in-readtable :lsx-syntax)

(defview listing-page ()
  (entries)
  (:metaclass html-view-class)
  (:render
   <html>
     <head>
       <title>Entries - Myblog</title>
     </head>
     <body>
       <h1>Entries</h1>
       <ul>
         {(mapcar (lambda (entry)
                    <li>
                      <a href={(format nil "/entries/~A" (mito:object-id entry))}>
                        {(entry-title entry)}
                      </a>
                    </li>)
                  entries)}
       </ul>
     </body>
   </html>))

(defview show-page ()
  (entry)
  (:metaclass html-view-class)
  (:render
   <html>
     <head>
       <title>
         {(entry-title entry)} - Myblog
       </title>
     </head>
     <body>
       <h1>{(entry-title entry)}</h1>
       <p>Blah blah blah</p>
     </body>
   </html>))
