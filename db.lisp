(in-package #:cl-user)
(defpackage utopian/db
  (:use #:cl)
  (:import-from #:utopian/config
                #:config)
  (:import-from #:cl-dbi
                #:connect-cached)
  (:export #:db
           #:connection-settings))
(in-package #:utopian/db)

(defun connection-settings (&optional (db :maindb))
  (cdr (assoc db (config :databases))))

(defun db (&optional (db :maindb))
  (apply #'dbi:connect-cached (connection-settings db)))
