;;; init.el --- My init.el  -*- lexical-binding: t; -*-

;;; Commentary:

;; My init.el.

;;; Code:

;; this enables this running method
;;   emacs -q -l ~/.debug.emacs.d/{{pkg}}/init.el
(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

(eval-and-compile
  (customize-set-variable
   'package-archives '(("org"   . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu"   . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)

    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))

;; ここにいっぱい設定を書く

(leaf leaf
  :config
  (leaf leaf-convert :ensure t)
  (leaf leaf-tree
    :ensure t
    :custom ((imenu-list-size . 30)
             (imenu-list-position . 'left))))

(leaf macrostep
  :ensure t
  :bind (("C-c e" . macrostep-expand)))

(leaf smartparens
  :ensure t
  :hook (after-init-hook . smartparens-global-strict-mode)
  :require smartparens-config
  :custom ((electric-pair-mode . nil))
  )

(leaf blacken
  :ensure t
  :custom ((blacken-line-length . 119)
           (blacken-skip-string-normalization . t)))

(leaf highlight-indent-guides
  :ensure t
  :blackout t
  :hook (((prog-mode-hook yaml-mode-hook) . highlight-indent-guides-mode))
  :custom (
           (highlight-indent-guides-method . 'character)
           (highlight-indent-guides-auto-enabled . t)
           (highlight-indent-guides-responsive . t)
           (highlight-indent-guides-character . ?\|))
  )

(leaf rainbow-delimiters
  :ensure t
  :hook
  ((prog-mode-hook . rainbow-delimiters-mode)))


(leaf whitespace
  :ensure t
  :commands whitespace-mode
  :bind ("C-c W" . whitespace-cleanup)
  :custom ((whitespace-style . '(face
                                 trailing
                                 tabs
                                 spaces
                                 empty
                                 space-mark
                                 tab-mark))
           (whitespace-display-mappings . '((space-mark ?\u3000 [?\u25a1])
                                            (tab-mark ?\t [?\u00BB ?\t] [?\\ ?\t])))
           (whitespace-space-regexp . "\\(\u3000+\\)")
           (whitespace-global-modes . '(emacs-lisp-mode
                                        shell-script-mode
                                        sh-mode
                                        python-mode
                                        org-mode))
           (global-whitespace-mode . t))
  :config
  (set-face-attribute 'whitespace-trailing nil
                      :background "Black"
                      :foreground "DeepPink"
                      :underline t)
  (set-face-attribute 'whitespace-tab nil
                      :background "Black"
                      :foreground "LightSkyBlue"
                      :underline t)
  (set-face-attribute 'whitespace-space nil
                      :background "Black"
                      :foreground "GreenYellow"
                      :weight 'bold)
  (set-face-attribute 'whitespace-empty nil
                      :background "Black")
  )


(leaf mwim
  :ensure t
  :bind (("C-a" . mwim-beginning-of-code-or-line)
         ("C-e" . mwim-end-of-code-or-line)))


(leaf py-isort :ensure t)

(leaf company
  :ensure t
  :leaf-defer nil
  :blackout company-mode
  :bind ((company-active-map
          ("M-n" . nil)
          ("M-p" . nil)
          ("C-s" . company-filter-candidates)
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)
          ("C-i" . company-complete-selection))
         (company-search-map
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)))
  :custom ((company-tooltip-limit         . 12)
           (company-idle-delay            . 0) ;; 補完の遅延なし
           (company-minimum-prefix-length . 1) ;; 1文字から補完開始
           (company-transformers          . '(company-sort-by-occurrence))
           (global-company-mode           . t)
           (company-selection-wrap-around . t)))



(leaf yasnippet
  :ensure t
  :blackout yas-minor-mode
  :custom ((yas-indent-line . 'fixed)
           (yas-global-mode . t)
           )
  :bind ((yas-keymap
          ("<tab>" . nil))            ; conflict with company
         (yas-minor-mode-map
          ("C-c y i" . yas-insert-snippet)
          ("C-c y n" . yas-new-snippet)
          ("C-c y v" . yas-visit-snippet-file)
          ("C-c y l" . yas-describe-tables)
          ("C-c y g" . yas-reload-all)))
  :config
  (leaf yasnippet-snippets :ensure t)
  (leaf yatemplate
    :ensure t
    :config
    (yatemplate-fill-alist))
  (defvar company-mode/enable-yas t
    "Enable yasnippet for all backends.")
  (defun company-mode/backend-with-yas (backend)
    (if (or (not company-mode/enable-yas) (and (listp backend) (member 'company-yasnippet backend)))
        backend
      (append (if (consp backend) backend (list backend))
              '(:with company-yasnippet))))
  (defun set-yas-as-company-backend ()
    (setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))
    )
  :hook
  ((company-mode-hook . set-yas-as-company-backend))
  )


(leaf flycheck
  :ensure t
  :hook (prog-mode-hook . flycheck-mode)
  :custom ((flycheck-display-errors-delay . 0.3)
           (flycheck-indication-mode . 'left-margin)) ;terminalで使うので、fringeではなくmarginに警告を表示
  :config (add-hook 'flycheck-mode-hook #'flycheck-set-indication-mode) ; flycheckのみでmarginを使用
  (leaf flycheck-inline
    :ensure t
    :hook (flycheck-mode-hook . flycheck-inline-mode)))


(leaf lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :config
  :custom ((lsp-keymap-prefix                  . "C-c l")
           (lsp-log-io                         . t)
           (lsp-keep-workspace-alive           . nil)
           (lsp-document-sync-method           . 2)
           (lsp-response-timeout               . 5)
           (lsp-enable-file-watchers           . nil))
  :hook (lsp-mode-hook . lsp-headerline-breadcrumb-mode)
  :init (leaf lsp-ui
          :ensure t
          :after lsp-mode
          :custom ((lsp-ui-doc-enable            . t)
                   (lsp-ui-doc-position          . 'at-point)
                   (lsp-ui-doc-header            . t)
                   (lsp-ui-doc-include-signature . t)
                   (lsp-ui-doc-max-width         . 150)
                   (lsp-ui-doc-max-height        . 30)
                   (lsp-ui-doc-use-childframe    . nil)
                   (lsp-ui-doc-use-webkit        . nil)
                   (lsp-ui-peek-enable           . t)
                   (lsp-ui-peek-peek-height      . 20)
                   (lsp-ui-peek-list-width       . 50))
          :bind ((lsp-ui-mode-map ([remap xref-find-definitions] .
                                   lsp-ui-peek-find-definitions)
                                  ([remap xref-find-references] .
                                   lsp-ui-peek-find-references))
                 (lsp-mode-map ("C-c s" . lsp-ui-sideline-mode)
                               ("C-c d" . lsp-ui-doc-mode)))
          :hook ((lsp-mode-hook . lsp-ui-mode))))


(leaf lsp-pyright
  :ensure t
  :hook (python-mode-hook . (lambda ()
                              (require 'lsp-pyright)
                              (lsp-deferred))))

(leaf pyvenv
  :ensure t)


(leaf magit
  :when (version<= "25.1" emacs-version)
  :ensure t
  :preface
  (defun c/git-commit-a ()
    "Commit after add anything."
    (interactive)
    (shell-command "git add .")
    (magit-commit-create))
  :bind (("M-=" . hydra-magit/body))
  :hydra (hydra-magit
          (:hint nil :exit t)
          "
^^         hydra-magit
^^------------------------------
 _s_   magit-status
 _C_   magit-clone
 _c_   magit-commit
 _d_   magit-diff-working-tree
 _M-=_ magit-commit-create"
          ("s" magit-status)
          ("C" magit-clone)
          ("c" magit-commit)
          ("d" magit-diff-working-tree)
          ("M-=" c/git-commit-a)))

(leaf hide-mode-line
  :hook (neotree-mode-hook imenu-list-minor-mode-hook minimap-mode-hook))

;; Theme
(leaf spaceline
  :doc "Modeline configuration library for powerline"
  :req "emacs-24.4" "cl-lib-0.5" "powerline-2.3" "dash-2.11.0" "s-1.10.0"
  :tag "spacemacs" "powerline" "mode-line" "emacs>=24.4"
  :url "https://github.com/TheBB/spaceline"
  :added "2022-12-13"
  :emacs>= 24.4
  :ensure t
  :after powerline
  :config
  (spaceline-spacemacs-theme)
  )

(leaf spacemacs-theme
  :doc "Color theme with a dark and light versions"
  :added "2022-12-13"
  :ensure t
  :config
  (load-theme 'spacemacs-dark t)
  )

(leaf leaf-convert
  :config
  (global-linum-mode t)
  (menu-bar-mode 0)
  (tool-bar-mode 0)
  (show-paren-mode t)
  )

(leaf leaf-convert
  :bind (("C-z" . undo)))

(provide 'init)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(magit pyvenv lsp-pyright lsp-ui lsp-mode flycheck-inline flycheck yatemplate yasnippet-snippets yasnippet company py-isort mwim whitespace rainbow-delimiters highlight-indent-guides blacken smartparens macrostep leaf-tree leaf-convert blackout el-get hydra leaf-keywords leaf)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
 ;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; init.el ends here
