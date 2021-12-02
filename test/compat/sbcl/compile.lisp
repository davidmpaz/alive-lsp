(defpackage :alive/test/compat/sbcl/compile
    (:use :cl)
    (:export :run-all)

    (:local-nicknames (:astreams :alive/streams))
)

(in-package :alive/test/compat/sbcl/compile)


(defun read-stuff (stdout out-stream)
    (lambda ()
        (handler-case
                (loop :until (astreams:eof-p out-stream)
                      :do (let ((line (read-line out-stream)))
                              (unless (eq line :eof)
                                      (format stdout "OUT ~A~%" line)
                              )))
            (t (c) (declare (ignore c)))
        )))


(defun read-err-stuff (stdout out-stream)
    (lambda ()
        (handler-case
                (loop :until (astreams:eof-p out-stream)
                      :do (let ((line (read-line out-stream)))
                              (unless (eq line :eof)
                                      (format stdout "ERR ~A~%" (string-upcase line))
                              )))
            (t (c) (declare (ignore c)))
        )))

(defun run-all ()
    (format T "SBCL Compile Tests~%")

    (let* ((orig-output *standard-output*)
           (orig-err *error-output*)
           (out-stream (make-instance 'astreams:rt-stream :stdout orig-output))
           (err-stream (make-instance 'astreams:rt-stream :stdout orig-err))
           (*standard-output* out-stream)
           (*error-output* err-stream)
           (thread (bt:make-thread (read-stuff orig-output out-stream)))
           (err-thread (bt:make-thread (read-err-stuff orig-output err-stream)))
          )
        (compile-file "test/compat/sbcl/files/foo.lisp")
        (close out-stream)
        (close err-stream)
        (bt:join-thread thread)
        (bt:join-thread err-thread)
    ))


(defun foo ()
    (loop :for i :from 1 :to 3 :do
              (format T "~A~%" i)
              (sleep 1)
    ))
