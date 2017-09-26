(defsystem "utopian"
  :class :package-inferred-system
  :version "0.2.0"
  :author "Eitaro Fukamachi"
  :license "LLGPL"
  :description "Full stack web application framework"
  :depends-on ("utopian/package"
               "lack"
               "mito"
               "bordeaux-threads"))

(register-system-packages "lack-component" '(#:lack.component))
(register-system-packages "lack-request" '(#:lack.request))
(register-system-packages "lack-response" '(#:lack.response))
(register-system-packages "lack-middleware-csrf" '(#:lack.middleware.csrf))
(register-system-packages "cl-annot" '(#:cl-annot #:cl-annot.util))
(register-system-packages "ningle" '(#:ningle #:ningle.app))
