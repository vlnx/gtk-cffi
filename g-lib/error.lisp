;;;; -*- Mode: lisp; indent-tabs-mode: nil -*-
;;;
;;; error.lisp -- interface to GError
;;;
;;; Copyright (C) 2007, Roman Klochkov <kalimehtar@mail.ru>
;;;

(in-package #:g-lib-cffi)

(defclass g-error (object)
  ()
  (:documentation "Stores GError**"))

(defmethod gconstructor ((g-error g-error)
                         &key &allow-other-keys)
  (foreign-alloc :pointer :initial-element (null-pointer)))

(defcfun g-clear-error :void (gerror object))

(defmethod free :before ((g-error g-error))
  (g-clear-error g-error))

(defcstruct* g-error-struct
    "GError struct"
  (domain g-quark)
  (errno :int)
  (message :string))

(defun get-error (g-error)
  (let ((p (make-instance 'g-error-struct
                          :pointer (mem-ref (pointer g-error) :pointer)
                          :free-after nil)))
    (when p
      (list :domain (domain p)
            :errno (errno p)
            :message (message p)))))

                                        ;(defmethod print-object ((g-error g-error) stream)
                                        ;  (let ((err (get-error g-error)))
                                        ;    (format stream "GError ~A (~A): ~A"
                                        ;            (g-quark-to-string (getf err :domain))
                                        ;            (getf err :errno) (getf err :message))))

(defun throw-g-error (g-error)
  (let ((err (get-error g-error)))
    (error "GError ~A (~A): ~A"
           (g-quark-to-string (getf err :domain))
           (getf err :errno) (getf err :message))))

(defmacro with-g-error (g-error &body body)
  `(let ((,g-error (make-instance 'g-error)))
     (unwind-protect
          ,@body
       (free g-error))))
