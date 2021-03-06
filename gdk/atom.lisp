;;;; -*- Mode: lisp; indent-tabs-mode: nil -*-
;;;
;;; atom.lisp --- GdkAtom
;;;
;;; Copyright (C) 2007, Roman Klochkov <kalimehtar@mail.ru>
;;;

(in-package :gdk-cffi)

(defcfun gdk-atom-name :string (atom :pointer))
(defcfun gdk-atom-intern-static-string :pointer
  (val (:string :free-to-foreign nil)))
(defcfun gdk-atom-intern :pointer (val :string) (only-if-exists :boolean))

(define-foreign-type gatom ()
  ()
  (:actual-type :pointer)
  (:simple-parser gatom))

(defmethod translate-to-foreign (value (gatom gatom))
  (typecase value
    (foreign-pointer value)
    (integer (make-pointer value))
    (t (gdk-atom-intern value nil))))

(defmethod translate-from-foreign (value (gatom gatom))
  (make-keyword (gdk-atom-name value)))
