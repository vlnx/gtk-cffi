;;;; -*- Mode: lisp; indent-tabs-mode: nil -*-
;;;
;;; text-view.lisp --- GtkTextView
;;;
;;; Copyright (C) 2012, Roman Klochkov <kalimehtar@mail.ru>
;;;

(in-package :gtk-cffi)

(defclass scrollable (object)
  ())

(defcenum scrollable-policy (:minimum 0) :natural)

(defslots scrollable
    hadjustment pobject
    vadjustment pobject
    hscroll-policy scrollable-policy
    vscroll-policy scrollable-policy)

(init-slots scrollable)
