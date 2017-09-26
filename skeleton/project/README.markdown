# <% @var name %>

## Requirements

* [Roswell](https://github.com/roswell/roswell)
* [Qlot](https://github.com/fukamachi/qlot)
* [Lake](https://github.com/takagi/lake)
* NPM (Only for development)

## Installation

```
$ npm install
$ ros install qlot lake
$ qlot install
```

## Run

### Development

```
$ qlot exec lake server
```

### Production

```
$ ros install clack  # for 'clackup' command

# TCP localhost
$ APP_ENV=production qlot exec clackup app.lisp --server woo --debug nil --address 127.0.0.1 --port 8080 --worker-num 4
# UNIX domain socket
$ APP_ENV=production qlot exec clackup app.lisp --server woo --debug nil --listen /tmp/app.sock --worker-num 4
```

## See Also

* [Utopian](https://github.com/fukamachi/utopian): Web application framework
* [Mito](https://github.com/fukamachi/mito): An ORM library
