(defpackage #:myblog/views/entries
  (:use #:cl
        #:lsx
        #:myblog/models
        #:utopian)
  (:export #:listing
           #:show))
(in-package #:myblog/views/entries)

(lsx:enable-lsx-syntax)

(defview listing ()
  (entries)
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

(defview show ()
  (entry)
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
