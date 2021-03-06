;;;
;;; accel-label.lisp -- GtkAccelLabel
;;;
;;; Copyright (C) 2012, Roman Klochkov <kalimehtar@mail.ru>
;;;

(in-package :gtk-cffi)

(defclass accel-label (label)
  ())

(defcfun gtk-accel-label-new :pointer (text :string))

(defmethod gconstructor ((accel-label accel-label) &key text)
  (gtk-accel-label-new text))

(defslots accel-label
    accel-widget pobject)

(deffuns accel-label
    (:set accel-closure :pointer)
  (:get accel-width :uint)
  (refetch :boolean))

(init-slots accel-label)
