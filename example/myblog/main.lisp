(defpackage #:myblog
  (:nicknames #:myblog/main)
  (:use #:cl)
  (:import-from #:myblog/config/application)
  (:import-from #:myblog/config/routes))
(in-package #:myblog)
