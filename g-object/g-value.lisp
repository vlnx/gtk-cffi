;;;; -*- Mode: lisp; indent-tabs-mode: nil -*-
;;;
;;; gvalue.lisp --- GValue wrappers for Common Lisp
;;;
;;;
;;; Copyright (C) 2007, Roman Klochkov <kalimehtar@mail.ru>
;;;
(declaim (optimize debug))

(in-package :g-object-cffi)

(defclass g-value (object) ())

(defcunion g-value-data
  (v-int :int)
  (v-uint :uint)
  (v-long :long)
  (v-ulong :ulong)
  (v-int64 :int64)
  (v-uint64 :uint64)
  (v-float :float)
  (v-double :double)
  (v-pointer :pointer))

(defcstruct* g-value-struct
    "GValue struct"
  (g-type-type :ulong)
  (data (:union g-value-data) :count 2))

(defcfun "g_value_init" :pointer (g-value pobject) (type g-type))
(defcfun "g_value_set_boolean" :void (g-value pobject) (val :boolean))
(defcfun "g_value_set_char" :void (g-value pobject) (val :char))
(defcfun "g_value_set_uchar" :void (g-value pobject) (val :uchar))
(defcfun "g_value_set_int" :void (g-value pobject) (val :int))
(defcfun "g_value_set_uint" :void (g-value pobject) (val :uint))
(defcfun "g_value_set_long" :void (g-value pobject) (val :long))
(defcfun "g_value_set_ulong" :void (g-value pobject) (val :ulong))
(defcfun "g_value_set_int64" :void (g-value pobject) (val :int64))
(defcfun "g_value_set_uint64" :void (g-value pobject) (val :uint64))
(defcfun "g_value_set_float" :void (g-value pobject) (val :float))
(defcfun "g_value_set_double" :void (g-value pobject) (val :double))
(defcfun "g_value_set_enum" :void (g-value pobject) (val :int))
(defcfun "g_value_set_flags" :void (g-value pobject) (val :uint))
(defcfun "g_value_set_string" :void (g-value pobject) (val :string))
(defcfun "g_value_set_param" :void (g-value pobject) (val :pointer))
(defcfun "g_value_set_boxed" :void (g-value pobject) (val :pointer))
(defcfun "g_value_set_pointer" :void (g-value pobject) (val :pointer))
(defcfun "g_value_set_object" :void (g-value pobject) (val pobject))


(defmethod gconstructor ((g-value g-value) &key
                                             (value nil value-p) g-type &allow-other-keys)
  (let ((struct (make-instance 'g-value-struct :new-struct t
                               :free-after nil)))
    (setf (g-type-type struct) 0)
    (init-g-value (pointer struct) g-type value value-p)
    (pointer struct)))

(defmethod (setf value) (val (g-value g-value))
  (g-value-set g-value val (g-type g-value)))

(defcfun g-value-unset :void (g-value pobject))

(defmethod unset ((g-value g-value))
                                        ;(when (/= (g-type g-value) 0)
                                        ;    (format t "Unset value ~a~%" g-value)
  (g-value-unset g-value))

(defun init-g-value (ptr type value value-p)
  (macrolet ((gtypecase (x &rest body)
               `(typecase ,x
                  ,@(mapcar (lambda (x)
                              (list (car x)
                                    (keyword->g-type (cdr x))))
                            body))))
    (let ((%type (or type
                     (when value-p
                       (gtypecase value
                                  (standard-char . :char)
                                  (fixnum . :int)
                                  (integer . :int64)
                                  (single-float . :float)
                                  (double-float . :double)
                                  (string . :string)
                                  (boolean . :boolean)
                                  (null . :boolean)
                                  (t . :pointer))))))
      (when %type
        (g-value-init ptr %type)
        (when value-p
          (g-value-set ptr value %type))))))

(defmethod init ((g-value g-value) &key (value nil value-p) g-type)
                                        ;  (format t "init ~a~%" g-value)
  (init-g-value (pointer g-value) g-type value value-p))


(defun type-g-value (value) ; value->g_type
  "Value is a pointer to G-Value. Type fetched from value->g_type.
Depends on implementation of GLib/GObject!
Returns integer GType."
  (if (null-pointer-p value) 0
      (let ((struct (make-instance 'g-value-struct :pointer value
                                   :free-after nil)))
        (g-type-type struct))))

(defmethod g-type ((g-value g-value) &rest rest)
  (declare (ignore rest))
  (type-g-value (pointer g-value)))


(defcfun "g_value_get_boolean" :boolean (g-value :pointer))
(defcfun "g_value_get_char" :char (g-value :pointer))
(defcfun "g_value_get_uchar" :uchar (g-value :pointer))
(defcfun "g_value_get_int" :int (g-value :pointer))
(defcfun "g_value_get_uint" :uint (g-value :pointer))
(defcfun "g_value_get_long" :long (g-value :pointer))
(defcfun "g_value_get_ulong" :ulong (g-value :pointer))
(defcfun "g_value_get_int64" :int64 (g-value :pointer))
(defcfun "g_value_get_uint64" :uint64 (g-value :pointer))
(defcfun "g_value_get_float" :float (g-value :pointer))
(defcfun "g_value_get_double" :double (g-value :pointer))
(defcfun "g_value_get_enum" :int (g-value :pointer))
(defcfun "g_value_get_flags" :uint (g-value :pointer))
(defcfun "g_value_get_string" :string (g-value :pointer))
(defcfun "g_value_get_param" :pointer (g-value :pointer))
(defcfun "g_value_get_boxed" :pointer (g-value :pointer))
(defcfun "g_value_get_pointer" pobject (g-value :pointer))
(defcfun "g_value_get_object" pobject (g-value :pointer))


(macrolet ((select-accessor (type prefix)
             `(ecase ,type
                ,@(mapcar (lambda (x)
                            `(,(keyword->g-type x)
                               (function
                                ,(symbolicate prefix x))))
                          (remove-if
                           (rcurry #'member '(:invalid :interface :void))
                           +fundamental-g-types+)))))

  (defun g-value-set (ptr value type)
    "PTR - foreign pointer, VALUE - lisp value, TYPE - GType id"
                                        ;    (debug-out "g-value-set: ~a ~a~%" value (g-type->keyword type))
    (let ((ftype (g-type-fundamental type)))
      (let ((val (case ftype
                   ((#.(keyword->g-type :enum)
                       #.(keyword->g-type :flags))
                    (convert-to-foreign value (g-type->lisp type)))
                   (#.(keyword->g-type :double)
                      (coerce value 'double-float))
                   (#.(keyword->g-type :float)
                      (coerce value 'single-float))
                   ((#.(keyword->g-type :int)
                       #.(keyword->g-type :uint)
                       #.(keyword->g-type :long)
                       #.(keyword->g-type :ulong)
                       #.(keyword->g-type :int64)
                       #.(keyword->g-type :uint64)) (round value))
                   (t value))))
                                        ;        (debug-out "  converted value ~a~%" val)
        (when (/= type 0)
          (funcall (select-accessor ftype :g-value-set-)
                   ptr val)))))

  (defun g-value-get (value)
    (unless (null-pointer-p value)
      (let* ((g-type (type-g-value value))
             (fundamental-type (g-type-fundamental g-type)))
                                        ;        (format t "g-val:~a ~a ~a~%" g-type fundamental-type
                                        ;                (g-type->lisp g-type))
        (let ((res (case fundamental-type
                     (#.(keyword->g-type :boxed)
                        (g-value-get-boxed value))
                     (#.(keyword->g-type :enum)
                        (convert-from-foreign
                         (g-value-get-enum value) (g-type->lisp g-type)))
                     (#.(keyword->g-type :flags)
                        (convert-from-foreign
                         (g-value-get-flags value) (g-type->lisp g-type)))
                     (#.(keyword->g-type :interface)
                        (g-value-get-object value))
                     (t
                      (when (/= fundamental-type 0)
                        (funcall (select-accessor
                                  fundamental-type :g-value-get-) value))))))
                                        ;(format t "g-val value:~a~%" res)
          res)))))



(defmethod value ((g-value g-value))
  (let ((l
         (g-value-get (pointer g-value))))
                                        ;(format t "g-val2: ~a~%" l)
    l))

(defmethod free :before ((g-value g-value))
  (g-value-unset g-value))

(defvar *g-value* (make-instance 'g-value))

(defmacro with-g-value (val &body body)
  "This macro allows recursive *g-value* binding"
  `(progn
     (let* ((changed? (/= 0 (g-type *g-value*)))
            (*g-value* (if changed? (make-instance 'g-value)
                           *g-value*)))
       (init *g-value* ,@val)
       (unwind-protect
            (progn
              ,@body
              (value *g-value*))
         (if changed?
             (free *g-value*)
             (unset *g-value*))))))
