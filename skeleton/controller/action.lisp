(defun <% @var name %> (params)
  (declare (ignore params))
  (render #P"<% @var controller-name %>/<% @var name %>.html"))
