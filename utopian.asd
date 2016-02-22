#-asdf3.1 (error "Utopian requires ASDF 3.1")
(asdf:defsystem utopian
  :class :package-inferred-system
  :version "0.1"
  :author "Eitaro Fukamachi"
  :license "LLGPL"
  :description "Full stack web application framework"
  :depends-on ("utopian/package"
               :lack
               :mito
               :bordeaux-threads))

(asdf:register-system-packages "lack-component" '(#:lack.component))
(asdf:register-system-packages "lack-request" '(#:lack.request))
(asdf:register-system-packages "lack-middleware-csrf" '(#:lack.middleware.csrf))
