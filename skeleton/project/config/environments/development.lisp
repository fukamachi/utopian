(defpackage #:<% @var name %>/config/environments/development
  (:use #:cl
        #:utopian))
(in-package #:<% @var name %>/config/environments/development)

`(:databases
  ((:maindb . <% (cond ((string-equal (getf env :database) "postgres") -%>(:postgres :database-name "<% @var name %>"
                         ;; :username "<% @var name %>"
                         ;; :password ""
                         :microsecond-precision t)
              <%- ) ((string-equal (getf env :database) "mysql") -%>(:mysql :database-name "<% @var name %>"
                         :username "root"
                         :password "")
              <%- ) (t -%>(:sqlite3
               :database-name ,(project-path #P"db/development.db"))
              <%- )) %>))
  :error-log ,(project-path #P"log/error.log"))
