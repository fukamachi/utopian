(defpackage <% @var appname %>/models/<% @var name %>
  (:use :cl
        :mito)
  (:export :<% @var name %><%=
           (format nil "~{~{~%           :~A-~A~}~}"
                   (mapcar (lambda (column)
                             (list (getf env :name) (first column)))
                           (getf env :columns)))
           %>))
(in-package :<% @var appname %>/models/<% @var name %>)

(defclass <% @var name %> ()
  (<%=
   (format nil "~{~A~^~%   ~}"
           (loop for (name type . type-args) in (getf env :columns)
                 collect (format nil
                                 "(~A :col-type ~:[:~A~*~;(:~A~{ ~A~})~]
     ~A:initarg :~A
     ~A:accessor ~A-~A)"
                                 name
                                 type-args
                                 type
                                 type-args
                                 (make-string (length name) :initial-element #\Space)
                                 name
                                 (make-string (length name) :initial-element #\Space)
                                 (getf env :name)
                                 name)))
   %>)
  (:metaclass dao-table-class))
