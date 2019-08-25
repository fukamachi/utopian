# Minimal example

```common-lisp
(ql:quickload '(:clack :utopian))
(clack:clackup #P"app.lisp")
```

Or, with `clackup` command:

```
$ clackup -s utopian app.lisp
```

And open http://localhost:5000 on your browser.
