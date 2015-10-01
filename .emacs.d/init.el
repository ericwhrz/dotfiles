(require 'cl)

(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)
(xterm-mouse-mode 1)
(global-hl-line-mode)

(setq-default indent-tabs-mode nil)

(fset 'yes-or-no-p 'y-or-n-p)

(setq backup-directory-alist '(("." . "~/.emacs-backups")))

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'molokai t)

(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "google-chrome-beta")

;; Open config (this file)
(global-set-key (kbd "<f12>") (lambda () (interactive) (find-file user-init-file)))

;; Here is how to preserve current working directory
;; (add-hook 'find-file-hook
;;           (lambda ()
;;             (setq default-directory command-line-default-directory)))
;; or put this in your project root (.dir-locals.el):
;; ((nil . ((default-directory . "project/directory/"))))

(setq dotfiles-directory (file-name-as-directory (expand-file-name ".." (file-name-directory (file-truename user-init-file)))))

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)

(when (not (package-installed-p 'use-package))
  (package-refresh-contents)
  (package-install 'use-package))

(setq use-package-always-ensure t)
(eval-when-compile
  (require 'use-package))
(require 'diminish)
(require 'bind-key)

(use-package helm
  :diminish helm-mode
  :config
  (require 'helm-config)

  (global-set-key (kbd "M-x") 'helm-M-x)
  (global-set-key (kbd "C-x C-b") 'helm-mini)
  (global-set-key (kbd "C-x C-f") 'helm-find-files)
  (global-set-key (kbd "C-h") 'helm-command-prefix)
  (global-set-key (kbd "C-c h g") 'helm-google-suggest)

  (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
  (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action)
  (define-key helm-map (kbd "C-z") 'helm-select-action)

  (when (executable-find "curl")
    (setq helm-google-suggest-use-curl-p t))

  (setq helm-move-to-line-cycle-in-source t
        helm-ff-search-library-in-sexp t
        helm-scroll-amount 8
        helm-ff-file-name-history-use-recentf t
        helm-M-x-fuzzy-match t)

  (helm-mode 1))

(use-package xclip
  :config
  (xclip-mode 1)
  (defun my-x-set-selection (f type data)
    (xclip-set-selection type data))
  (advice-add 'x-set-selection :around #'my-x-set-selection)

  (defun my-x-selection-value-internal (f type)
    (xclip-selection-value))
  (advice-add 'x-selection-value-internal :around #'my-x-selection-value-internal))

(use-package magit
  :bind ("C-c m" . magit-status))

(use-package yasnippet
  :defer 5
  :diminish yas-minor-mode
  :init
  (make-directory "~/.emacs.d/snippets" t)
  :config
  (yas-global-mode 1)
  (yas-load-directory "~/.emacs.d/snippets")
  (add-hook 'term-mode-hook (lambda ()
                              (setq yas-dont-activate t))))

(use-package projectile
  :diminish projectile-mode
  :config
  (projectile-global-mode)
  (setq projectile-completion-system 'helm))

(use-package helm-projectile
  :config
  (helm-projectile-on))

(use-package company
  :diminish company-mode
  :config
  (global-company-mode))

(use-package ycmd
  :config
  (set-variable 'ycmd-server-command
                (list "python" (concat dotfiles-directory "ycmd/ycmd")))
  (set-variable 'ycmd-global-config
                (concat dotfiles-directory ".nvim/.ycm_extra_conf.py"))
  (add-hook 'after-init-hook #'global-ycmd-mode))

(use-package company-ycmd
  :config
  (company-ycmd-setup))

(use-package company-ghc
  :config
  (add-to-list 'company-backends 'company-ghc))

(use-package haskell-mode
  :init
  (setq company-ghc-show-info t
        haskell-indent-spaces 4
        haskell-process-type (quote cabal-repl))
  :config
  (add-hook 'haskell-mode-hook 'haskell-indent-mode)
  (eval-after-load 'haskell-mode
    '(define-key haskell-mode-map [f8] 'haskell-navigate-imports))

  (eval-after-load "haskell-mode"
      '(define-key haskell-mode-map (kbd "C-c C-b") 'haskell-compile))

  (eval-after-load "haskell-mode"
    '(define-key haskell-mode-map (kbd "C-c v c") 'haskell-cabal-visit-file))

  (eval-after-load "haskell-cabal"
      '(define-key haskell-cabal-mode-map (kbd "C-c C-b") 'haskell-compile)))

(use-package ghc
  :config
  (autoload 'ghc-init "ghc" nil t)
  (setq ghc-ghc-options '("-fdefer-type-errors" "-XNamedWildCards"))
  (add-hook 'haskell-mode-hook (lambda () (ghc-init) (hare-init))))

(use-package evil
  :config
  (evil-mode 1)

  (defun nmap (key action)
    (define-key evil-normal-state-map (kbd key) action))
  
  (nmap "C-h"     'windmove-left)
  (nmap "C-j"     'windmove-down)
  (nmap "C-k"     'windmove-up)
  (nmap "C-l"     'windmove-right)
  
  (nmap "SPC"     nil)
  (nmap "SPC SPC" 'save-buffer)
  (nmap "H"       'move-beginning-of-line)
  (nmap "L"       'move-end-of-line)
  
  (nmap "SPC q"   'kill-emacs)
  (nmap "SPC w"   (lambda () (interactive) (save-buffers-kill-terminal t)))
  (nmap "C-c C-z" 'suspend-frame)
  (nmap "C-u"     'projectile-find-file)
  (nmap "C-]"     'helm-semantic-or-imenu))

(use-package yaml-mode
  :mode ("\\.yml$" . yaml-mode))

(use-package markdown-mode
  :mode ("\\.\\(markdown\\|mdown\\|md\\)$" . markdown-mode))

(use-package undo-tree
  :diminish undo-tree-mode)

(use-package cmake-mode
  :mode ("^CMakeLists\\.txt$" . cmake-mode))
(use-package company-cmake)
(use-package cmake-font-lock)

(use-package idris-mode
  :mode ("\\.idr$" . idris-mode))

(use-package rust-mode
  :mode ("\\.rs$" . rust-mode))

(use-package nim-mode
  :mode ("\\.nim$" . nim-mode))
;; Seems that I have to install nimsuggest first
; (custom-set-variables
;  '(nim-nimsuggest-path "~/.nimble/bin/nimsuggest"))
; (add-to-list 'company-backends 'company-nim)

(use-package lua-mode
  :mode ("\\.lua$" . lua-mode))

(use-package scala-mode2
  :mode ("\\.scala$" . scala-mode))

(use-package ensime
  :config
  (add-hook 'scala-mode-hook 'ensime-scala-mode-hook))

(use-package rainbow-delimiters
  :config
  (add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode)

  (set-face-attribute 'rainbow-delimiters-unmatched-face nil
                      :foreground 'unspecified
                      :background "purple"
                      :inherit 'error)
  (custom-set-faces
   '(rainbow-delimiters-depth-1-face ((t (:foreground "dark orange"))))
   '(rainbow-delimiters-depth-2-face ((t (:foreground "deep pink"))))
   '(rainbow-delimiters-depth-3-face ((t (:foreground "chartreuse"))))
   '(rainbow-delimiters-depth-4-face ((t (:foreground "deep sky blue"))))
   '(rainbow-delimiters-depth-5-face ((t (:foreground "yellow"))))
   '(rainbow-delimiters-depth-6-face ((t (:foreground "orchid"))))
   '(rainbow-delimiters-depth-7-face ((t (:foreground "spring green"))))
   '(rainbow-delimiters-depth-8-face ((t (:foreground "sienna1"))))))

(use-package term-run
  :commands (term-run term-run-shell-command))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun minicom ()
  (interactive)
  (term-run-shell-command
   (concat "minicom -D /dev/"
           (completing-read "Select terminal:"
                            (directory-files "/dev/" nil "ttyUSB.*\\|ttyACM.*")))))

(defun add-to-path (str)
  (setenv "PATH" (concat str ":" (getenv "PATH"))))

(c-add-style "savvy"
             '("k&r"
               (indent-tabs-mode .t)
               (c-basic-offset . 4)
               (tab-width . 4)
               (c-offsets-alist
                (case-label +))))
