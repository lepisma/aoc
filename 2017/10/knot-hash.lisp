;; Knot hash
(ql:quickload '(:alexandria :serapeum))

(defun repeat (sequence times)
  (apply #'concatenate 'list (make-list times :initial-element sequence)))

(defun arange (limit)
  (make-array limit :initial-contents (alexandria:iota limit :start 0)))

(defun reverse-subarray (array from len)
  (let ((array (alexandria:rotate array (- from)))
        (slice (subseq array 0 len)))
    (setf (subseq array 0 len) (nreverse slice))
    (alexandria:rotate array from)))

(defun update-array (array lengths &optional (pos 0) (skip 0))
  (if (null lengths) array
      (update-array (reverse-subarray array pos (car lengths))
                    (cdr lengths) (+ pos (car lengths) skip) (+ skip 1))))

(defun knot-hash (input)
  (let* ((lengths `(,@(map 'list #'char-code input) 17 31 73 47 23))
         (numbers (arange 256))
         (results (update-array numbers (repeat lengths 64))))
    (format nil "~{~(~2,'0x~)~}" (mapcar (lambda (slice) (reduce #'logxor slice)) (serapeum:batches results 16)))))
