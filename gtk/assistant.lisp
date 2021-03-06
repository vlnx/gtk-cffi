;;;
;;; assistant.lisp -- GtkAssistant
;;;
;;; Copyright (C) 2012, Roman Klochkov <kalimehtar@mail.ru>
;;;
(in-package :gtk-cffi)

(defclass assistant (window)
  ())

(defcfun gtk-assistant-new :pointer)

(defmethod gconstructor ((assistant assistant) &key &allow-other-keys)
  (gtk-assistant-new))

(defslots assistant
    current-page :int)

(defcenum assistant-page-type
  :content :intro :confirm :summary :progress :custom)

(deffuns assistant
    (:get n-pages :int)
  (:get nth-page pobject (page-num :int))
  (prepend-page :int (page pobject))
  (append-page :int (page pobject))
  (insert-page :int (page pobject) (pos :int))
  #+gtk3.2 (remove-page :void (page-num :int))
  (:set-last page-type assistant-page-type (page pobject))
  (:get page-type assistant-page-type (page pobject))
  (:set-last page-title :string (page pobject))
  (:get page-title :string (page pobject))
  (:set-last page-complete :boolean (page pobject))
  (:get page-complete :boolean (page pobject))
  (add-action-widget :void (child pobject) &key)
  (remove-action-widget :void (child pobject))
  (update-buttons-state :void)
  (commit :void)
  (next-page :void)
  (previous-page :void))


(defcallback cb-forward-page-func :int ((cur-page :int) (data pdata))
  (funcall data cur-page))

(defcfun gtk-assistant-set-forward-page-func :void
  (assistant pobject) (func pfunction) (data pdata) (notify pfunction))


(defmethod (setf forward-page-func) (func (assistant assistant)
                                     &key data destroy-notify)
  (set-callback assistant gtk-assistant-set-forward-page-func
                cb-forward-page-func func data destroy-notify))

(init-slots assistant)
