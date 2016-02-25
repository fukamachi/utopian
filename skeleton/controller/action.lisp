@route GET "/<% @var name %>"
(defun <% @var name %> (params)
  (declare (ignore params))
  (render nil))
