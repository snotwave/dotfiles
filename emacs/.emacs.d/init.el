; emacs customizations
;;(setq inhibit-startup-message t)
(require 'no-littering)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)

(setq default-tab-width 4)

(menu-bar-mode -1)
(xterm-mouse-mode 1)

(toggle-word-wrap)

(set-frame-font "Monaspace Neon 11" nil t)

(setq ring-bell-function 'ignore)

(dolist (mode '(text-mode-hook
                  prog-mode-hook
                  conf-mode-hook))
    (add-hook mode (lambda () (display-line-numbers-mode 1))))

(electric-pair-mode 1)

;; keybindings
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Configures package manager 
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("gnu" . "https://elpa.gnu.org/packages/")
			 ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; packages

;;; move backup saves elsewhere
(setq backup-directory-alist '(("." . "~/.emacs.d/backup"))
  backup-by-copying t    ; Don't delink hardlinks
  version-control t      ; Use version numbers on backups
  delete-old-versions t  ; Automatically delete excess backups
  kept-new-versions 20   ; how many of the newest versions to keep
  kept-old-versions 5    ; and how many of the old
)


;;; declutter config folder
(use-package no-littering)

;;; theme
(setq custom-safe-themes t)

(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-monokai-spectrum t)
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic nil)
  ;;(doom-themes-neotree-config)
  (doom-themes-org-config))

(use-package all-the-icons)

(use-package dimmer
  :config
  (dimmer-mode t))

(use-package solaire-mode
  :config
  (solaire-global-mode t))

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-center-content t)
  (setq dashboard-vertically-center-content t)
  (setq dashboard-startup-banner 1)
  (setq dashboard-display-icons-p t)
  (setq dashboard-icon-type 'nerd-icons)
  (setq dashboard-items '((recents   . 15))))

(use-package auto-package-update
  :config
  (auto-package-update-maybe))

;; as much as zoom has served me well, i think it's time to sunset this
;;(use-package zoom
;;  :config
;;  (zoom-mode f)
;;  (setq zoom-size '(0.6 . 0.8)))


;;(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/haki")
;;(load-theme 'haki)
;;(set-face-attribute 'haki-region nil :background "#2e8b57" :foreground "#ffffff")
;;(add-hook 'post-command-hook #'haki-modal-mode-line)

;;; org mode
(use-package org
  :config (setq org-startup-indented t)
  (setq org-hide-leading-stars t))

(use-package org-bullets
  :hook (org-mode . org-bullets-mode))

(use-package org-sticky-header
  :hook (org-mode . org-sticky-header-mode))

;;; pdf-tools
(use-package pdf-tools
  :demand t
  :init
  (pdf-tools-install)
  :config
  (add-hook 'pdf-isearch-minor-mode-hook (lambda () (ctrlf-local-mode -1)))
  (use-package org-pdftools
    :hook (org-mode . org-pdftools-setup-link)))

;;; autocomplete
(use-package ivy
  :config (ivy-mode 1))

(use-package ivy-rich
  :init (ivy-rich-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)))

;;; nice mode line that emulates VIM's
(use-package powerline
  :config (powerline-default-theme))

;;; makes it easier to determine delimiter levels
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;;; key completion
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-ley-idle-delay 0.1))

;;; git
(use-package magit)

;;; scrollbar
(use-package yascroll
  :hook
  (prog-mode . yascroll-bar-mode)
  (text-mode . yascroll-bar-mode))

;;; i am a vim user
(use-package evil
  :ensure t
  :init (setq evil-want-integration t
	      evil-want-keybinding nil)
  :config (add-hook 'neotree-mode-hook
              (lambda ()
                (define-key evil-normal-state-local-map (kbd "TAB") 'neotree-enter)
                (define-key evil-normal-state-local-map (kbd "SPC") 'neotree-quick-look)
                (define-key evil-normal-state-local-map (kbd "q") 'neotree-hide)
                (define-key evil-normal-state-local-map (kbd "RET") 'neotree-enter)
                (define-key evil-normal-state-local-map (kbd "g") 'neotree-refresh)
                (define-key evil-normal-state-local-map (kbd "n") 'neotree-next-line)
                (define-key evil-normal-state-local-map (kbd "p") 'neotree-previous-line)
                (define-key evil-normal-state-local-map (kbd "A") 'neotree-stretch-toggle)
                (define-key evil-normal-state-local-map (kbd "H") 'neotree-hidden-file-toggle)))
  (evil-mode 1))
  ;:hook  
  ;(dired-mode . turn-off-evil-mode) 
  ;(bookmark-bmenu-mode . turn-off-evil-mode) 
  ;(ibuffer-mode . turn-off-evil-mode))

(use-package evil-collection
  :after evil
  :ensure t
  :config (evil-collection-init))

(use-package evil-surround
  :ensure t
  :config (global-evil-surround-mode 1))

(use-package evil-org
  :ensure t
  :after org
  :hook (org-mode . (lambda () evil-org-mode))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;;; undo support
(use-package vundo
  :commands (vundo)

  :config
  ;; Take less on-screen space.
  (setq vundo-compact-display t)

  ;; Better contrasting highlight.
  (custom-set-faces
    '(vundo-node ((t (:foreground "#808080"))))
    '(vundo-stem ((t (:foreground "#808080"))))
    '(vundo-highlight ((t (:foreground "#FFFF00")))))

  ;; Use `HJKL` VIM-like motion, also Home/End to jump around.
  (define-key vundo-mode-map (kbd "l") #'vundo-forward)
  (define-key vundo-mode-map (kbd "<right>") #'vundo-forward)
  (define-key vundo-mode-map (kbd "h") #'vundo-backward)
  (define-key vundo-mode-map (kbd "<left>") #'vundo-backward)
  (define-key vundo-mode-map (kbd "j") #'vundo-next)
  (define-key vundo-mode-map (kbd "<down>") #'vundo-next)
  (define-key vundo-mode-map (kbd "k") #'vundo-previous)
  (define-key vundo-mode-map (kbd "<up>") #'vundo-previous)
  (define-key vundo-mode-map (kbd "<home>") #'vundo-stem-root)
  (define-key vundo-mode-map (kbd "<end>") #'vundo-stem-end)
  (define-key vundo-mode-map (kbd "q") #'vundo-quit)
  (define-key vundo-mode-map (kbd "C-g") #'vundo-quit)
  (define-key vundo-mode-map (kbd "RET") #'vundo-confirm))

(with-eval-after-load 'evil (evil-define-key 'normal 'global (kbd "C-M-u") 'vundo))

;;; tree
(use-package neotree
  :config
  (setq neo-window-position 'right)
  (setq neo-window-width 30)
  (setq line-number-mode 0)
  (setq neo-theme 'nerd)
  :bind (("<f6>" . neotree)))

;; IDE SHIT

;;; lsp-mode
(add-to-list 'exec-path "/path")
(add-to-list 'exec-path "$HOME/.zvm/bin")
(add-to-list 'exec-path "$HOME/.zvm/self")

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init (setq lsp-keymap-prefix "C-c l")
  :config (setq lsp-prefer-capf t)
  (setq lsp-auto-configure t)
  (setq lsp-headerline-arrow ">>"))

;;;; lsp-doctor recommended optimiztions
(setq gc-cons-threshold 100000000
      read-process-output-max (* 1024 1024))
(setq lsp-print-performance t)

(use-package company
  :commands (company-mode)
  :config
  (setq company-minimum-prefix-length 1
	company-tooltip-limit 6
	company-require-match nil
	company-dabbrev-downcase 0
	company-idle-delay 0
	company-selection-wrap-around 1)
  :hook (prog-mode . company-mode))

(use-package company-quickhelp
  :hook (company-mode . company-quickhelp-mode)
  :config
  (setq company-quickhelp-delay 1))

;;;; flycheck

(use-package flycheck
  :ensure t
  :config (global-flycheck-mode +1))

;;;;; flycheck has been giving errors with haskell-mode
(use-package flycheck-haskell
  :config
  (add-hook 'haskell-mode-hook #'flycheck-haskell-setup))

;;;; 80 column rule
(setq-default display-fill-column-indicator-column 79)
(setq-default display-fill-column-indicator-character ? )
(set-face-attribute 'fill-column-indicator nil :background "gray7")
(add-hook 'prog-mode-hook (lambda() (display-fill-column-indicator-mode 1)))

(global-hl-line-mode t)

;;; language-specific

;;;; agda

(load-file (let ((coding-system-for-read 'utf-8))
                (shell-command-to-string "agda-mode locate")))

;;; apl
(use-package gnu-apl-mode)
(use-package dyalog-mode
  :mode "\\.dyalog\\'")

;;; c/c++
(add-hook 'c-mode-hook 'lsp-mode)
(add-hook 'c++-mode-hook 'lsp-mode)

;;;; common lisp
(use-package slime
  :mode "\\.cl\\'"
  :config
  (setq inferior-lisp-program "sbcl")
  (slime-setup '(slime-fancy slime-company)))
(use-package slime-company
  :after (slime company)
  :config (setq slime-company-completion 'fuzzy
                slime-company-after-completion 'slime-company-just-one-space))
(load (expand-file-name "~/Files/src_clisp/quicklisp/slime-helper.el"))
(setq inferior-lisp-program "sbcl")

;;;; coq
(use-package proof-general)
(use-package company-coq
  :hook (coq-mode . company-coq-mode))

;;;; forth
(use-package forth-mode
  :commands (forth-mode))

;;;; haskell
(use-package haskell-mode
  :mode "\\.hs\\'"
  :commands (haskell-mode)
  :hook (haskell-mode . lsp)
  (haskell-mode . interactive-haskell-mode)
  )
(use-package lsp-haskell)

;;;; LaTeX
(use-package latex-preview-pane
  :hook (LaTeX-mode . latex-preview-pane-enable))

;;;; ocaml
;; Major mode for OCaml programming
(use-package tuareg
  :ensure t
  :mode (("\\.ocamlinit\\'" . tuareg-mode)))

;; Major mode for editing Dune project files
(use-package dune
  :ensure t)

;; Merlin provides advanced IDE features
(use-package merlin
  :ensure t
  :config
  (add-hook 'tuareg-mode-hook #'merlin-mode)
  (add-hook 'merlin-mode-hook #'company-mode)
  ;; we're using flycheck instead
  (setq merlin-error-after-save nil))

(use-package merlin-eldoc
  :ensure t
  :hook ((tuareg-mode) . merlin-eldoc-setup))

;; This uses Merlin internally
(use-package flycheck-ocaml
  :ensure t
  :config
  (flycheck-ocaml-setup))

(use-package utop
  :ensure t
  :config
  (add-hook 'tuareg-mode-hook #'utop-minor-mode))

;;;; python
(use-package python-mode
  :hook (python-mode . lsp-mode))
(use-package lsp-pyright
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp))))

(use-package code-cells
  :hook (python-mode . code-cells-mode-maybe))
(use-package elpy
  :hook (python-mode . elpy-mode)
  (python-mode . elpy-enable))

;;;; racket
(use-package racket-mode
  :hook (racket-mode . lsp-mode))

;;; rust
(use-package rust-mode
  :config (add-hook 'rust-mode-hook (lambda () (setq indent-tabs-mode nil)))
  :hook (rust-mode . lsp-mode))

;;;; uxntal
(use-package uxntal-mode)

;;;; zig
(use-package zig-mode
  :hook (zig-mode . lsp-mode))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(c-basic-offset 4)
 '(inhibit-startup-screen t)
 '(package-selected-packages
   '(all-the-icons apl-mode auto-package-update code-cells company
		   company-coq company-quickhelp corfu-mode
		   darcula-theme dashboard deldo dimmer doom-themes
		   dune dyalog-mode elpy evil evil-collection
		   evil-mode evil-org evil-surround forth-mode
		   gnu-apl-mode ivy-rich latex-preview-pane
		   lsp-haskell lsp-mode lsp-pyright madhat2r-theme
		   merlin merlin-eldoc neotree no-littering
		   org-bullets org-pdftools org-sticky-header
		   pdf-tools powerline proof-general python-mode
		   rainbow-delimiters rust-mode slime slime-company
		   slime-fancy smart-tabs-mode solaire-mode
		   tangotango-theme timu-macos-theme tuareg utop
		   uwu-theme which-key yascroll zig-mode zoom)))
 
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(vundo-highlight ((t (:foreground "#FFFF00"))))
 '(vundo-node ((t (:foreground "#808080"))))
 '(vundo-stem ((t (:foreground "#808080")))))

(put 'upcase-region 'disabled nil)
;; ## added by OPAM user-setup for emacs / base ## 56ab50dc8996d2bb95e7856a6eddb17b ## you can edit, but keep this line
(require 'opam-user-setup "~/.emacs.d/opam-user-setup.el")
;; ## end of OPAM user-setup addition for emacs / base ## keep this line
