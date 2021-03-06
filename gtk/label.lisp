;;;
;;; label.lisp -- GtkLabel
;;;
;;; Copyright (C) 2007, Roman Klochkov <kalimehtar@mail.ru>
;;;

(in-package :gtk-cffi)

(defclass label (misc)
  ())

(defcenum justification
  :left :right :center :fill)

(defcfun gtk-label-new :pointer (text :string))

(defmethod gconstructor ((label label)
                         &key text &allow-other-keys)
  (gtk-label-new text))

(defcfun gtk-label-set-markup :void (label pobject) (text :string))

(defcfun gtk-label-set-markup-with-mnemonic
    :void (label pobject) (text :string))

(defcfun gtk-label-set-text-with-mnemonic
    :void (label pobject) (text :string))

(defcfun gtk-label-set-text
    :void (label pobject) (text :string))

(defmethod (setf text) (text (label label) &key mnemonic markup)
  (apply
   (if mnemonic
       (if markup
           #'gtk-label-set-markup-with-mnemonic
           #'gtk-label-set-text-with-mnemonic)
       (if markup #'gtk-label-set-markup
           #'gtk-label-set-text))
   (list label text))
  text)

(defcfun gtk-label-get-text :string (label pobject))

(defmethod text ((label label) &key markup)
  (apply
   (if markup #'gtk-label-get-label #'gtk-label-get-text)
   label))

(defslots label
    mnemonic-widget pobject
    justify justification
    ellipsize pango-cffi:ellipsize-mode
    width-chars :int
    max-width-chars :int
    line-wrap :boolean
    line-wrap-mode pango-cffi:wrap-mode
    selectable :boolean
    attributes pango-cffi:attr-list
    label :string
    use-markup :boolean
    use-underline :boolean
    single-line-mode :boolean
    angle :double
    track-visited-links :boolean)

(deffuns label
    (:set pattern :string)
  (:get layout pobject)
  (:get mnemonic-keyval :uint)
  (select-region :void (start :int) (end :int))
  (:get current-uri :string))


(defcfun gtk-label-get-layout-offsets :void (label pobject)
         (x :pointer) (y :pointer))

(defmethod layout-offsets ((label label))
  (with-foreign-outs-list ((x :int) (y :int)) :ignore
                          (gtk-label-get-layout-offsets label x y)))

(defcfun gtk-label-get-selection-bounds :void (label pobject)
         (start :pointer) (end :pointer))

(defmethod selection-bounds ((label label) &key)
  (with-foreign-outs-list ((start :int) (end :int)) :ignore
                          (gtk-label-get-selection-bounds label start end)))

;; taken from cells-gtk
(defun to-str (sym)
  (if (stringp sym)
      sym
      (string-downcase (format nil "~a" sym))))

(defmacro with-markup (markup &rest rest)
  (destructuring-bind (&key font-desc font-family face size style
                            weight variant stretch foreground background
                            underline rise strikethrough fallback lang) markup
    (let ((markup-start
           `(format nil "<span~{ ~a=~s~}>"
                    (list
                     ,@(when font-desc `("font-desc" (to-str ,font-desc)))
                     ,@(when font-family `("font-family" (to-str ,font-family)))
                     ,@(when face `("face" (to-str ,face)))
                     ,@(when size `("size" (to-str ,size)))
                     ,@(when style `("style" (to-str ,style)))
                     ,@(when weight `("weight" (to-str ,weight)))
                     ,@(when variant `("variant" (to-str ,variant)))
                     ,@(when stretch `("stretch" (to-str ,stretch)))
                     ,@(when foreground `("foreground" (to-str ,foreground)))
                     ,@(when background `("background" (to-str ,background)))
                     ,@(when underline `("underline" (to-str ,underline)))
                     ,@(when rise `("rise" (to-str ,rise)))
                     ,@(when strikethrough `("strikethrough"
                                             (if ,strikethrough "true" "false")))
                     ,@(when fallback `("fallback" (to-str ,fallback)))
                     ,@(when lang `("lang" (to-str ,lang)))))))

      `(format nil "~a ~a </span>" ,markup-start (format nil "~{~a~}"
                                                         (list ,@rest))))))
