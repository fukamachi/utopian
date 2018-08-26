all: server

server:
	ros -s myblog -e '(utopian/tasks:server myblog/app:blog-app)'

generate-migrations:
	ros -s myblog -e '(utopian/tasks:generate-migrations myblog/app:blog-app)'

migrate:
	ros -s myblog -e '(utopian/tasks:migrate myblog/app:blog-app)'
