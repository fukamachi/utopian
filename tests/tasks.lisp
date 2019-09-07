(defpackage #:utopian-tests/tasks
  (:use #:cl
        #:rove
        #:utopian/tasks
        #:utopian-tests/utils))
(in-package #:utopian-tests/tasks)

(defun make-project-name (&optional (prefix "new-project-"))
  (concatenate 'string prefix (random-string)))

(deftest task-new-tests
  (let* ((project-name (make-project-name))
         (destination (merge-pathnames project-name
                                       uiop:*temporary-directory*)))
    (ok (new destination
             :description ""
             :author ""
             :database "sqlite3"
             :license ""))))
