# Utopian

[![Quicklisp dist](http://quickdocs.org/badge/utopian.svg)](http://quickdocs.org/utopian/)

> The caveman in offering the first garland to his maiden thereby transcended the brute. He became a utopian in thus rising above the crude necessities of nature. He entered the realm of art when he perceived the subtle use of the useless.
> -- Okakura Tenshin, "The Book of Tea"

3 steps to write a better web application:

1. Choose the right language.
2. Choose the right web framework.
3. Write less.

Utopian is a web application framework for encouraging rapid web development.

## Requirements

* [Roswell](https://github.com/roswell/roswell)
* [Qlot](https://github.com/fukamachi/qlot)
* Node.js & npm
* SQLite3

## Getting started

### Installation

```
$ ros install fukamachi/utopian
$ ros install qlot
```

Ensure `~/.roswell/bin` is in your shell `$PATH`.

### Creating a new project

To generate the project skeleton, open a terminal and execute this command:

```
$ utopian new blog

# With PostgreSQL
$ utopian new blog --database postgres
```

### Installing dependencies

```
$ qlot install
$ npm install
```

### Setting database

The project includes the database settings at `config/environments/development.lisp`. Configure it and run this command:

```
$ qlot exec quicklisp/bin/lake db:create
```

### Starting a server

```
$ qlot exec quicklisp/bin/lake server
```

## Generating a new controller

```
$ utopian generate controller welcome index
writing controllers/welcome.lisp
writing views/welcome/index.html
writing assets/stylesheets/welcome/index.scss
```

## Generating a new model

```
$ utopian generate model user name:varchar:20 email:varchar:255
writing models/user.lisp
```

Run `qlot exec quicklisp/bin/lake db:generate-migrations` after this for generating a migration file and apply it with `qlot exec quicklisp/bin/lake db:migrate`.

## Deployment

```
$ APP_ENV=production clackup app.lisp --server woo --port 8080
```

## See Also

* [Caveman2](https://github.com/fukamachi/caveman)
* [Clack](http://clacklisp.org) / [Lack](https://github.com/fukamachi/lack)
* [Mito](https://github.com/fukamachi/mito)
* [Djula](https://github.com/mmontone/djula)

## Author

* Eitaro Fukamachi (e.arrows@gmail.com)

## Copyright

Copyright (c) 2016-2017 Eitaro Fukamachi

## License

Licensed under the LLGPL License.
