(in-package :gtk-cffi)

(defclass misc (widget)
  ())

(defcfun gtk-misc-set-alignment :void (misc pobject) (x :float) (y :float))

(defgeneric (setf alignment) (coords misc)
  (:method (coords (misc misc))
    (gtk-misc-set-alignment misc
                            (float (first coords))
                            (float (second coords)))))
(save-setter misc alignment)

(defcfun gtk-misc-get-alignment :void (misc pobject)
         (x :pointer) (y :pointer))

(defgeneric alignment (misc)
  (:method ((misc misc))
    (with-foreign-outs-list ((x :float) (y :float)) :ignore
                            (gtk-misc-get-alignment misc x y))))

(defcfun gtk-misc-set-padding :void (misc pobject) (x :int) (y :int))
(defgeneric (setf padding) (coords misc)
  (:method (coords (misc misc))
    (gtk-misc-set-padding misc
                          (first coords)
                          (second coords))))
(save-setter misc padding)

(defcfun gtk-misc-get-padding :void (misc pobject) (x :pointer) (y :pointer))
(defgeneric padding (misc)
  (:method ((misc misc))
    (with-foreign-outs-list ((x :int) (y :int)) :ignore
                            (gtk-misc-get-padding misc x y))))
