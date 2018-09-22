all: server

server:
	ros -s myblog -e '(utopian/tasks:server #P"app.lisp")'

generate-migrations:
	ros -s myblog -e '(utopian/tasks:generate-migrations #P"app.lisp")'

migrate:
	ros -s myblog -e '(utopian/tasks:migrate #P"app.lisp")'

createdb:
	ros -s myblog -e '(utopian/tasks:create-db #P"app.lisp")'

dropdb:
	ros -s myblog -e '(utopian/tasks:drop-db #P"app.lisp")'

recreatedb:
	ros -s myblog -e '(utopian/tasks:recreate-db #P"app.lisp")'

resetdb:
	ros -s myblog -e '(utopian/tasks:reset-db #P"app.lisp")'
