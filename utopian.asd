#-asdf3.1 (error "Utopian requires ASDF 3.1")
(defsystem utopian
  :class :package-inferred-system
  :version "0.1"
  :author "Eitaro Fukamachi"
  :license "LLGPL"
  :description "Full stack web application framework"
  :depends-on ("utopian/package"
               :lack
               :mito))

(register-system-packages "utopian/package" '(#:utopian))
(register-system-packages "lack-component" '(#:lack.component))
