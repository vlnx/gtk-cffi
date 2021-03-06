(asdf:oos 'asdf:load-op :gtk-cffi)
                                        ;(declaim (optimize speed))
(defpackage #:test
  (:use #:common-lisp #:gtk-cffi #:g-object-cffi))
(in-package #:test)

(defun main ()
  (gtk-init)
  (let ((window (make-instance 'window :width 400 :height 280))
        (hpane (make-instance 'h-paned)))

    (setf (gsignal window :destroy) :gtk-main-quit)

    (let ((v-box (make-instance 'v-box)))
      (add window v-box)

      (let ((title (make-instance 'label :text "Use of GtkHPaned")))
        (setf (font title) "Times New Roman Italic 10"
              (color title) "#0000ff")
        (setf (size-request title) '(-1 40))
        (pack v-box title :expand nil))

      (pack v-box (make-instance
                   'label :text "Click on the options on the left pane.")
            :expand nil)
      (pack v-box (make-instance 'label) :expand nil)
      (pack v-box hpane :fill t :expand t))

    (let ((left-pane (make-instance 'frame))
          (v-box (make-instance 'v-box)))
      (setf (shadow-type left-pane) :in)
      (add left-pane v-box)
      (pack v-box (make-instance 'label :text "Options:"))
      (pack v-box (create-link "Show All"))
      (pack v-box (create-link "Qty > 10"))
      (pack v-box (create-link "Price < $10"))
      (pack hpane left-pane))


    (let ((right-pane (make-instance 'frame))
          (data '(("row 0" "item 42" 2 3.1)
                  ("row 1" "item 36" 20 6.21)
                  ("row 2" "item 21" 8 9.36)
                  ("row 3" "item 10" 11 12.4)
                  ("row 4" "item 7" 5 15.5)
                  ("row 5" "item 4" 17 18.6)
                  ("row 6" "item 3" 20 21.73))))

      (setf data (append data data))
      (setf data (append data data))
      (setf data (append data data))

      (setf (shadow-type right-pane) :in)
      (pack hpane right-pane :pane-type 2 :resize t)
      (format t "parent of ~a is ~a~%" right-pane
              (property right-pane :parent))
      (display-table right-pane data))

    (show window :all t)
    (gtk-main)))

(defvar *model*)
(defvar *modelfilter1*)
(defvar *modelfilter2*)
(defvar *view*)

(defun display-table (container data)

  (setf *model*
        (make-instance 'list-store :columns
                       '(:string :string :long :double
                         :boolean :boolean ; filters
                         :string ; color
                         :string ; third column
                         )))

  (setf *modelfilter1*
        (make-instance 'tree-model-filter :model *model*))
  (setf (visible-column *modelfilter1*) 4)

  (setf *modelfilter2*
        (make-instance 'tree-model-filter :model *model*))
  (setf (visible-column *modelfilter2*) 5)

  (setf *view*
        (make-instance 'tree-view :model *model*))

  (let ((scrolled-win (make-instance 'scrolled-window)))
    (setf (policy scrolled-win) '(:automatic :automatic))
    (add container scrolled-win)
    (add scrolled-win *view*))

  (let ((field-header '("Row #" "Description" "Qty" "Price"))
        (field-justification '(0 0 .5 1)))
    (loop :for col :from 0 :below (length field-header) :do
       (let ((cell-renderer (make-instance 'cell-renderer-text)))
         (setf (property cell-renderer :xalign)
               (float (nth col field-justification)))
         (let ((column (make-instance 'tree-view-column
                                      :title (nth col field-header)
                                      :cell cell-renderer
                                      :attributes
                                      (list
                                       "text" (if (= col 3) 7 col)
                                       :cell-background 6))))
           (setf (alignment column) (nth col field-justification))
           (setf (sort-column-id column) col)

           (let ((label (make-instance 'label
                                       :text (nth col field-header))))
             (setf (font label) "Arial Bold")
             (setf (color label) "#0000FF")
             (setf (widget column) label)
             (show label))
           (if (/= col 0) (setf (reorderable column) t))
           (setf (cell-data-func column cell-renderer :data col)
                 (cffi:callback format-col))

           (append-column *view* column)))))
  (setf (gsignal *model* :rows-reordered) (cffi:callback reorder))

  (loop :for row :below (length data) :do
     (let ((values (nth row data)))
       (setf values (append values
                            (list (> (third values) 10)
                                  (< (fourth values) 10)
                                  (if (= (mod row 2) 1)
                                      "#dddddd" "#ffffff")
                                  (format nil "$~,2f" (fourth values)))))
       (append-values *model* values)))
  (format t "Num rows: ~a~%" (iter-n-children *model* nil))
  (let ((selection (selection *view*)))
                                        ;(setf (mode selection) :multiple)
    (format t "mode: ~a~%" (mode selection))
                                        ;(format t "read mode: ~a~%" (gtk-cffi::gtk-tree-selection-get-mode selection))
    (setf (gsignal selection :changed) (cffi:callback on-selection))
                                        ;(format t "signals selection: ~a~%" (signals selection))
    (format t "signals selection2: ~a~%" (gsignal selection :changed))
                                        ;(setf (gsignal selection :changed) nil)
                                        ;(format t "signals deleted: ~a~%" (gsignals selection))
                                        ;(set-signal (get-selection *view*) :changed (cffi:callback on-selection))
    ))

(defparameter *create-link-i* 0)
(defun create-link (str)
  (let ((event-box (make-instance 'event-box))
        (label (make-instance 'label
                              :text (format nil " ~a. ~a "
                                            (setf *create-link-i*
                                                  (+ 1 *create-link-i*))
                                            str))))
    (setf (color label) "#0000ff")
    (let ((h-box (make-instance 'h-box)))
      (pack h-box label)
      (pack h-box (make-instance 'label) :fill t :expand t)
      (add event-box h-box)
      (setf (gsignal event-box
                     :button-press-event
                     :data str)
            (cffi:callback link-clicked))
      event-box)))

(cffi:defcallback format-col
    :void ((column pobject) (cell pobject)
           (model pobject) (iter-ptr :pointer)
           (col-num pdata))
  (declare (ignore column))
  ;;(declare (optimize speed))
  ;;(format t
  ;;        "~A ~A ~A ~A ~A~%" column cell model iter col-num)
  (let* ((iter (make-instance 'tree-iter :pointer iter-ptr :free-after nil))
         ;; (row-num (cffi:mem-aref
         ;;       (gtk-cffi::gtk-tree-path-get-indices
         ;;        (gtk-cffi::gtk-tree-model-get-path
         ;;                  model iter)) :int 0)))

         ;;(row-num (parse-integer (gtk-cffi::iter-string model iter))))
         (row-num (aref (iter->path model iter) 0)))
    ;;                     (format t "~a ~a ~a~%" row-num col-num cell-ptr)

    ;;(format t "~a ~a ~a ~a ~a~%" column cell model iter col-num)
    ;;                    (let ((vals (get-values model iter
    ;;                                            3 :double
    ;;                                            2 :long)))
    ;;                       (format t "~a ~a ~a~%" cell col-num vals)
    (if (= col-num 3)
        (setf (property cell :text)
              (format nil "$~,2f"
                      (car (model-values model
                                         :tree-iter iter
                                         :column 3)))))
    ;;                       (if (and (= col-num 2) (> (cadr vals) 10))
    ;;                          (p-set cell :visible nil)
    ;;                       (p-set cell :visible t)))
    (setf (property cell :cell-background)
          (if (= (mod row-num 2) 1) "#dddddd" "#ffffff"))
    (setf (property cell :alignment) :left)))


;; (defun reformat-rows (model)
;;   (tree-model-foreach
;;    *model*
;;    (flet ((set-color (model path iter data)
;;                      (let ((row-num (get-index path)))
;;                        (setf (model-values model iter 6)
;;                              (list (if (= (mod row-num 2) 1)
;;                                        "#dddddd" "#ffffff"))))))
;;      (if (typep model 'list-store) #'set-color
;;        (lambda (m path iter data)
;;          (with-parent-path p model path
;;                           (when p (set-color m p iter data))))))))

(defun reformat-rows (model)
  (foreach
   model
   (lambda (model path iter data)
     (declare (ignore data))
     (let ((row-num (aref path 0)))
       (setf (model-values model :tree-iter iter :column 6)
             (list (if (= (mod row-num 2) 1)
                       "#dddddd" "#ffffff")))))))


(cffi:defcallback reorder :void ((model-ptr pobject))
  (reformat-rows model-ptr))

(cffi:defcallback link-clicked
    :boolean ((widget :pointer)
              (event :pointer)
              (str pdata))
  (declare (ignore widget event))
  (let ((model (cond
                 ((string= str "Show All") *model*)
                 ((string= str "Qty > 10") *modelfilter1*)
                 ((string= str "Price < $10")
                  *modelfilter2*))))
    (format t "link clicked: ~a~%" str)
    (when model
      (setf (model *view*) model)
      (reformat-rows model)
      (setf (property *view* :headers-clickable)
            (typep model 'list-store)))))


(cffi:defcallback on-selection
    :void ((selection pobject)
           (data-ptr :pointer))
  (declare (ignore data-ptr))
  (multiple-value-bind (tree-iter model) (selected selection)
    (when tree-iter
      (format
       t "You have selected ~a~%"
       (model-values model
                     :tree-iter tree-iter
                     :columns '(1 2 7))))))

(main)
