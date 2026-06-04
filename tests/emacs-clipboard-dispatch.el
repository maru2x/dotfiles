;;; emacs-clipboard-dispatch.el --- Clipboard dispatch checks -*- lexical-binding: t; -*-

(require 'cl-lib)

(let ((repo-root (file-name-directory
                  (directory-file-name
                   (file-name-directory (or load-file-name buffer-file-name))))))
  (load-file (expand-file-name "configs/spacemacs/.spacemacs" repo-root)))

;; The clipboard functions are defined before optional package configuration.
(condition-case nil
    (dotspacemacs/user-config)
  (error nil))

(cl-letf (((symbol-function 'display-graphic-p)
           (lambda (&optional _frame) t))
          ((symbol-function 'my/system-clipboard-paste)
           (lambda () (error "helper must not be called"))))
  (setq my/native-interprogram-paste-function (lambda () nil))
  (unless (null (my/interprogram-paste-dispatch))
    (error "Native nil result changed")))

(cl-letf (((symbol-function 'display-graphic-p)
           (lambda (&optional _frame) t))
          ((symbol-function 'my/system-clipboard-paste)
           (lambda () "fallback")))
  (setq my/native-interprogram-paste-function
        (lambda () (error "native clipboard failed")))
  (unless (equal (my/interprogram-paste-dispatch) "fallback")
    (error "Native clipboard error did not fall back")))

(princ "emacs clipboard dispatch: ok\n")

;;; emacs-clipboard-dispatch.el ends here
