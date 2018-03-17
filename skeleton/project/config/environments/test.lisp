(defpackage #:<% @var name %>/config/environments/test
  (:use #:cl
        #:utopian))
(in-package #:<% @var name %>/config/environments/test)

`(:databases
  ((:maindb . <% (cond ((string-equal (getf env :database) "postgres") -%>(:postgres :database-name "<% @var name %>_test"
                         ;; :username "<% @var name %>"
                         ;; :password ""
                         :microsecond-precision t)
              <%- ) ((string-equal (getf env :database) "mysql") -%>(:mysql :database-name "<% @var name %>"
                         :username "root"
                         :password "")
              <%- ) (t -%>(:sqlite3
               :database-name ,(project-path #P"db/test.db"))
              <%- )) %>)))
