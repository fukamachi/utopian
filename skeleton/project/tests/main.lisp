(defpackage #:<% @var name %>/tests/main
  (:use #:cl
        #:rove))
(in-package #:<% @var name %>/tests/main)

(deftest test-something
  (ok (= 1 1)))
