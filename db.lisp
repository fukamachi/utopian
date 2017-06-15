(in-package #:cl-user)
(defpackage utopian/db
  (:use #:cl)
  (:import-from #:utopian/config
                #:config)
  (:import-from #:cl-dbi
                #:connect-cached)
  (:import-from #:mito
                #:*connection*)
  (:export #:db
           #:connection-settings
           #:with-connection))
(in-package #:utopian/db)

(defun connection-settings (&optional (db :maindb))
  (cdr (assoc db (config :databases))))

(defun db (&optional (db :maindb))
  (apply #'dbi:connect-cached (connection-settings db)))

(defmacro with-connection ((&optional (db :maindb)) &body body)
  `(let ((mito:*connection* (db ,db)))
     ,@body))
