(defsystem "utopian"
  :class :package-inferred-system
  :version "0.9.1"
  :author "Eitaro Fukamachi"
  :license "LLGPL"
  :description "Web application framework"
  :pathname "src"
  :depends-on ("utopian/main")
  :in-order-to ((test-op (test-op "utopian-tests"))))

(register-system-packages "lack-component" '(#:lack.component))
(register-system-packages "lack-request" '(#:lack.request))
(register-system-packages "lack-response" '(#:lack.response))
(register-system-packages "mystic" '(#:mystic.util))
(register-system-packages "mystic-file-mixin" '(#:mystic.template.file))
