# Utopian

> The caveman in offering the first garland to his maiden thereby transcended the brute. He became a utopian in thus rising above the crude necessities of nature. He entered the realm of art when he perceived the subtle use of the useless.
> -- Okakura Tenshin, "The Book of Tea"

Utopian is a web framework for Common Lisp never finished.

## Getting started

```common-lisp
(ql:quickload :utopian)
```

```common-lisp
(utopian:make-project #P"blog/")
;-> writing blog/blog.asd
;   writing blog/qlfile
;   writing blog/package.lisp
;   writing blog/app.lisp
;   writing blog/README.markdown
;   writing blog/Lakefile
;   writing blog/.gitignore
;   writing blog/config/routes.lisp
;   writing blog/config/application.lisp
;   writing blog/config/environments/development.lisp
;   writing blog/config/environments/production.lisp
;   writing blog/controllers/root.lisp
;   writing blog/db/migrations/.keep
;   writing blog/models/.keep
;   writing blog/public/stylesheets/style.css
;   writing blog/views/index.html
;   writing blog/views/errors/404.html
;   writing blog/views/layouts/default.html
```

```common-lisp
(ql:quickload :blog)
(blog:start)
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
