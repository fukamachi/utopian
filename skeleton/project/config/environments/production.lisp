(defpackage #:<% @var name %>/config/environments/production
  (:use #:cl
        #:utopian))
(in-package #:<% @var name %>/config/environments/production)

(environment-config "development")
