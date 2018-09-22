all: server

server:
	ros -s myblog -e '(utopian/tasks:server #P"app.lisp")'

generate-migrations:
	ros -s myblog -e '(utopian/tasks:generate-migrations #P"app.lisp")'

migrate:
	ros -s myblog -e '(utopian/tasks:migrate #P"app.lisp")'
