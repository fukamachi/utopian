(defpackage <% @var appname %>/controllers/<% @var name %>
  (:use :cl
        :utopian)
  (:export <% @loop actions %>:<% @var name %>
           <%- @endloop %>))
(in-package :<% @var appname %>/controllers/<% @var name %>)

(syntax:use-syntax :annot)

(defclass <% @var name %> (controller) ())
(defvar *<% @var name %>* (make-instance '<% @var name %>))
(clear-routing-rules *<% @var name %>*)

<%- @loop actions %>
<% @include controller/action.lisp %>
<%- @endloop -%>
