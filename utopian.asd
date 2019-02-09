(defsystem "utopian"
  :class :package-inferred-system
  :version "0.1.0"
  :author "Eitaro Fukamachi"
  :license "LLGPL"
  :description "Web application framework"
  :depends-on ("utopian/main"))

(register-system-packages "lack-component" '(#:lack.component))
(register-system-packages "lack-request" '(#:lack.request))
(register-system-packages "lack-response" '(#:lack.response))
(register-system-packages "mystic-file-mixin" '(#:mystic.template.file))
(register-system-packages "mystic-gitignore-mixin" '(#:mystic.template.gitignore))
