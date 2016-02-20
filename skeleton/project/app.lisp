(push (uiop:pathname-directory-pathname *load-pathname*)
      asdf:*central-registry*)
(ql:quickload :<% @var name %> :silent t)

(defpackage <% @var name %>/app
  (:use :cl
        :<% @var name %>
        :utopian)
  (:import-from :lack
                :builder)
  (:import-from :mito))
(in-package :<% @var name %>/app)

(apply #'mito:connect-toplevel (connection-settings :maindb))

(builder
 (:static
  :path "/public/"
  :root (project-path #P"public/"))
 :accesslog
 (when (config :error-log)
   `(:backtrace :output ,(config :error-log)))
 :session
 *app*)
