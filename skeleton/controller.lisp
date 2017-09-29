(defpackage #:<% @var appname %>/controllers/<% @var name %>
  (:use #:cl
        #:utopian)
  (:export <% @loop actions %>#:<% @var name %>
           <%- @endloop %>))
(in-package #:<% @var appname %>/controllers/<% @var name %>)

<%- @loop actions %>
<% @include controller/action.lisp %>
<%- @endloop -%>
