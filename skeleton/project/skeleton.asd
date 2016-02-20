#-asdf3.1 (error "<% @var name %> requires ASDF 3.1")
(asdf:defsystem <% @var name %>
  :class :package-inferred-system
  :version "0.1"
  :author "<% @var author %>"
  :license "<% @var license %>"
  :description "<% @var description %>"
  :depends-on ("<% @var name %>/package"))

(asdf:register-system-packages "<% @var name %>/package" '(:<% @var name %>))
