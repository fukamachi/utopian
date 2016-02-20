(defpackage <% @var appname %>/controllers/<% @var name %>
  (:use :cl
        :utopian)
  (:export <% @loop actions %>:<% @var name %>
           <%- @endloop %>))
(in-package :<% @var appname %>/controllers/<% @var name %>)

<%- @loop actions %>
(defun <% @var name %> (params)
  (declare (ignore params))
  (render #P"<% @var controller-name %>/<% @var name %>.html"))
<%- @endloop %>
