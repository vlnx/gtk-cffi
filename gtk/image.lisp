;;;
;;; image.lisp -- GtkImage
;;;
;;; Copyright (C) 2012, Roman Klochkov <kalimehtar@mail.ru>
;;;

(in-package :gtk-cffi)

(defclass image (misc)
  ())

(defcfun gtk-image-new-from-file :pointer (filename cffi-pathname))
(defcfun gtk-image-new-from-icon-set :pointer
  (icon-set pobject) (icon-size icon-size))
(defcfun gtk-image-new-from-pixbuf :pointer (pixbuf pobject))
(defcfun gtk-image-new-from-icon-name :pointer
  (icon-name :string) (icon-size icon-size))
(defcfun gtk-image-new-from-animation :pointer (animation pobject))
(defcfun gtk-image-new-from-stock :pointer
  (stock-id cffi-keyword) (size icon-size))
(defcfun gtk-image-new-from-gicon :pointer
  (gicon pobject) (icon-size icon-size))
(defcfun gtk-image-new :pointer)

(defmethod gconstructor ((image image)
                         &key file pixbuf stock-id gicon
                           icon-size icon-name icon-set animation)
  (cond
    (file (gtk-image-new-from-file file))
    (pixbuf (gtk-image-new-from-pixbuf pixbuf))
    (stock-id (gtk-image-new-from-stock stock-id icon-size))
    (icon-set (gtk-image-new-from-icon-set icon-set icon-size))
    (icon-name (gtk-image-new-from-icon-name icon-name icon-size))
    (animation (gtk-image-new-from-animation animation))
    (gicon (gtk-image-new-from-gicon gicon icon-size))
    (t (gtk-image-new))))

(defslots image
    pixel-size :int)


(defcfun gtk-image-set-from-file :pointer (image pobject) (filename :string))
(defcfun gtk-image-set-from-icon-set :pointer
  (image pobject) (icon-set pobject) (icon-size icon-size))
(defcfun gtk-image-set-from-pixbuf :pointer (image pobject) (pixbuf pobject))
(defcfun gtk-image-set-from-icon-name :pointer (image pobject)
         (icon-name :string) (icon-size icon-size))
(defcfun gtk-image-set-from-animation :pointer (image pobject)
         (animation pobject))
(defcfun gtk-image-set-from-stock :pointer
  (image pobject) (stock-id :string) (size icon-size))
(defcfun gtk-image-set-from-gicon :pointer
  (image pobject) (gicon pobject) (icon-size icon-size))


(defmethod reinitialize-instance ((image image) &key file pixbuf stock-id gicon
                                                  icon-size icon-name icon-set animation)
  (cond
    (file (gtk-image-set-from-file image file))
    (pixbuf (gtk-image-set-from-pixbuf image pixbuf))
    (stock-id (gtk-image-set-from-stock image stock-id icon-size))
    (icon-set (gtk-image-set-from-icon-set image icon-set icon-size))
    (icon-name (gtk-image-set-from-icon-name image icon-name icon-size))
    (animation (gtk-image-set-from-animation image animation))
    (gicon (gtk-image-set-from-gicon image gicon icon-size))
    (t (clear image))))

(defcenum image-type
  :empty :pixbuf :stock :icon-set :animation :icon-name :gicon)

(deffuns image
    (:get pixbuf pobject)
  (:get animation pobject)
  (:get storage-type image-type)
  (clear :void))

(defcfun gtk-image-get-icon-set :void (image pobject) (icon-set :pointer)
         (icon-size :pointer))
(defgeneric icon-set (image)
  (:method ((image image))
    (with-foreign-outs ((icon-set 'pobject) (icon-size 'icon-size)) :ignore
                       (gtk-image-get-icon-set image icon-set icon-size))))

(defcfun gtk-image-get-gicon :void (image pobject) (gicon :pointer)
         (icon-size :pointer))
(defgeneric gicon (image)
  (:method ((image image))
    (with-foreign-outs ((gicon 'pobject) (icon-size 'icon-size)) :ignore
                       (gtk-image-get-gicon image gicon icon-size))))

(defcfun gtk-image-get-icon-name :void (image pobject)
         (icon-name :pointer) (icon-size :pointer))
(defmethod icon-name ((image image))
  (with-foreign-outs ((icon-name :string) (icon-size 'icon-size)) :ignore
                     (gtk-image-get-icon-set image icon-name icon-size)))

(defcfun gtk-image-get-stock :void (image pobject)
         (stock :pointer) (icon-size :pointer))
(defgeneric stock (image)
  (:method ((image image))
    (with-foreign-outs ((stock :string) (icon-size 'icon-size)) :ignore
                       (gtk-image-get-stock image stock icon-size))))
