(defsystem "myblog"
  :class :package-inferred-system
  :author "Eitaro Fukamachi"
  :version "0.1.0"
  :depends-on ("myblog/main"))

(register-system-packages "lack-component" '(#:lack.component))
