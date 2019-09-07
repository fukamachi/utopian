(defsystem "utopian-tests"
  :class :package-inferred-system
  :pathname "tests"
  :depends-on ("rove"
               "utopian-tests/tasks")
  :perform (test-op (o c) (symbol-call :rove '#:run c)))
