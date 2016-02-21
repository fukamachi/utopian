# Utopian

> The caveman in offering the first garland to his maiden thereby transcended the brute. He became a utopian in thus rising above the crude necessities of nature. He entered the realm of art when he perceived the subtle use of the useless.
> -- Okakura Tenshin, "The Book of Tea"

Utopian is a web framework for Common Lisp never finished.

## Requirements

* [Roswell](https://github.com/roswell/roswell)
* [Qlot](https://github.com/fukamachi/qlot)
* [Lake](https://github.com/takagi/lake)
* Node.js & npm
* SQLite3

## Getting started

### Installation

```
$ git clone https://github.com/fukamachi/utopian
$ ros -l utopian/utopian.asd install utopian
```

Ensure `~/.roswell/bin` is in your shell `$PATH`.

### Creating a new project

```
$ utopian new blog
writing blog/blog.asd
writing blog/qlfile
writing blog/package.lisp
writing blog/package.json
writing blog/gulpfile.js
writing blog/app.lisp
writing blog/README.markdown
writing blog/Lakefile
writing blog/.gitignore
writing blog/.babelrc
writing blog/assets/javascripts/app.js
writing blog/assets/stylesheets/app.less
writing blog/config/webpack.config.js
writing blog/config/routes.lisp
writing blog/config/assets.js
writing blog/config/application.lisp
writing blog/config/environments/development.lisp
writing blog/config/environments/production.lisp
writing blog/controllers/root.lisp
writing blog/db/development/migrations/.keep
writing blog/db/production/migrations/.keep
writing blog/log/.keep
writing blog/models/.keep
writing blog/views/index.html.dj
writing blog/views/errors/404.html
writing blog/views/layouts/default.html.dj
```

### Starting a server

```
$ cd blog/
$ qlot exec lake server
```

## Generating a new controller

```
$ utopian generate controller welcome index
writing controllers/welcome.lisp
writing views/welcome/index.html
writing assets/stylesheets/welcome/index.less
```

## Generating a new model

```
$ utopian generate model user name:varchar:20 email:varchar:255
writing models/user.lisp
```

Run `qlot exec lake db:generate-migrations` after this for generating a migration file and apply it with `qlot exec lake db:migrate`.

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

Copyright (c) 2016 Eitaro Fukamachi

## License

Licensed under the LLGPL License.
