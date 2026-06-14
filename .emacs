(setq custom-file "~/.emacs.custom.el")
(package-initialize)

(add-to-list 'load-path "~/.emacs.local/")

(load "~/.emacs.rc/rc.el")

(load "~/.emacs.rc/misc-rc.el")
(load "~/.emacs.rc/org-mode-rc.el")
(load "~/.emacs.rc/autocommit-rc.el")
;;utf-8 coding system
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
;;; Appearance
(defun rc/get-default-font ()
  (cond
   ((eq system-type 'windows-nt)
    (when (member "JetBrainsMono NF" (font-family-list))
      "JetBrainsMono NF-10"))
   ((eq system-type 'gnu/linux)
    (when (member "JetBrainsMono NF" (font-family-list))
      "JetBrainsMono NF-18"))))

(add-to-list 'default-frame-alist `(font . ,(rc/get-default-font)))
(set-fontset-font t 'emoji "Segoe UI Emoji" nil 'prepend)
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)

(rc/require-theme 'gruber-darker)
;; (rc/require-theme 'zenburn)
;; (load-theme 'adwaita t)

(eval-after-load 'zenburn
  (set-face-attribute 'line-number nil :inherit 'default))

;;(global-set-key (kbd "M-o") 'ff-find-other-file)
(global-set-key (kbd "<f7>") 'ff-find-other-file)

;;; ido
(rc/require 'smex 'ido-completing-read+)

(require 'ido-completing-read+)

(ido-mode 1)
(ido-everywhere 1)
(ido-ubiquitous-mode 1)

(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)
(setq ido-auto-merge-work-directories-length -1)

;;; simpc
(require 'simpc-mode)
(add-to-list 'auto-mode-alist '("\\.[hc]\\(pp\\)?\\'" . simpc-mode))
(add-to-list 'auto-mode-alist '("\\.[b]\\'" . simpc-mode))
;;treesitter
(add-to-list 'exec-path "C:/Program Files/LLVM/bin")
(setenv "PATH" (concat "C:/Program Files/LLVM/bin;" (getenv "PATH")))
(add-to-list 'exec-path "C:/mingw64/bin")
(setenv "PATH" (concat "C:/mingw64/bin;" (getenv "PATH")))
(rc/require 'tree-sitter)
(rc/require 'tree-sitter-langs)
(require 'tree-sitter)
(require 'tree-sitter-langs)

(with-eval-after-load 'tree-sitter-hl
  (set-face-attribute 'tree-sitter-hl-face:function nil :foreground "#fb4934" :weight 'bold)
  (set-face-attribute 'tree-sitter-hl-face:type nil :foreground "#b8bb26" :weight 'bold)
  (set-face-attribute 'tree-sitter-hl-face:variable nil :foreground "#83a598")
  (set-face-attribute 'tree-sitter-hl-face:keyword nil :foreground "#fe8019" :weight 'bold)
  (set-face-attribute 'tree-sitter-hl-face:string nil :foreground "#b8bb26")
  (set-face-attribute 'tree-sitter-hl-face:number nil :foreground "#d3869b")
  (set-face-attribute 'tree-sitter-hl-face:operator nil :foreground "#fb4934")
  (set-face-attribute 'tree-sitter-hl-face:property nil :foreground "#83a598")
  (set-face-attribute 'tree-sitter-hl-face:punctuation nil :foreground "#ebdbb2")
  (set-face-attribute 'tree-sitter-hl-face:comment nil :foreground "#3a8b84" :weight 'bold)
  )

(add-hook 'simpc-mode-hook
          (lambda ()
            (setq-local tree-sitter-language (tree-sitter-require 'cpp))
            (tree-sitter-hl-mode 1)))

;;flycheck and avy
(rc/require 'avy)
(require 'avy)
(global-set-key (kbd "C-;") 'avy-goto-word-2)

(rc/require 'flycheck)
(require 'flycheck)
(global-flycheck-mode)

(rc/require 'projectile)
(require 'projectile)
(projectile-mode 1)

(flycheck-define-checker simpc-clang
  "A checker for simpc-mode using clang"
  :command ("clang"
            (eval (if (and buffer-file-name
                           (string-equal (file-name-extension buffer-file-name) "cpp"))
                      "-std=c++17"
                    "-std=c11"))
            "-Wall" "-Wextra" "-fsyntax-only"
            (option-list "-I" flycheck-clang-include-path)
            source)
  :error-patterns
  ((error line-start (file-name) ":" line ":" column ": error: " (message) line-end)
   (warning line-start (file-name) ":" line ":" column ": warning: " (message) line-end))
  :modes simpc-mode)

(add-to-list 'flycheck-checkers 'simpc-clang)

;; (add-hook 'simpc-mode-hook
;;           (lambda ()
;;             (flycheck-mode 1)
;;             (setq-local flycheck-checker 'simpc-clang)
;;             (setq-local flycheck-clang-language-standard "c++17")
;;             (when (and (fboundp 'projectile-project-p)
;;                        (projectile-project-p))
;;               (let* ((root (projectile-project-root))
;;                      (include-root (expand-file-name "include" root)))
;;                 (when (file-directory-p include-root)
;;                   (setq-local flycheck-clang-include-path
;;                               (cons include-root
;;                                     (seq-filter
;;                                      #'file-directory-p
;;                                      (directory-files-recursively
;;                                       include-root "." t)))))))))
;;this one collect all .h files
;; (add-hook 'simpc-mode-hook
;;           (lambda ()
;;             (flycheck-mode 1)
;;             (setq-local flycheck-checker 'simpc-clang)
;;             (setq-local flycheck-clang-language-standard "c++17")
;;             (when (and (fboundp 'projectile-project-p)
;;                        (projectile-project-p))
;;               (let* ((root (projectile-project-root))
;;                      (header-dirs
;;                       (delete-dups
;;                        (mapcar #'file-name-directory
;;                                (directory-files-recursively root "\\.h\\'" t)))))
;;                 (setq-local flycheck-clang-include-path header-dirs)))))
(add-hook 'simpc-mode-hook
          (lambda ()
            (flycheck-mode 1)
            (setq-local flycheck-checker 'simpc-clang)
            (setq-local flycheck-clang-language-standard "c++17")
            (when (and (fboundp 'projectile-project-p)
                       (projectile-project-p))
              (let* ((root (projectile-project-root))
                     (header-dirs
                      (delete-dups
                       (mapcar (lambda (f)
                                 (file-name-directory
                                  (directory-file-name
                                   (file-name-directory f))))
                               (directory-files-recursively root "\\.h\\'" t)))))
                (setq-local flycheck-clang-include-path header-dirs)))))
;;; c-mode
(setq-default c-basic-offset 4
              c-default-style '((java-mode . "java")
                                (awk-mode . "awk")
                                (other . "bsd")))

(add-hook 'c-mode-hook (lambda ()
                         (interactive)
                         (c-toggle-comment-style -1)))


;;; Paredit
(rc/require 'paredit)

(defun rc/turn-on-paredit ()
  (interactive)
  (paredit-mode 1))

(add-hook 'emacs-lisp-mode-hook  'rc/turn-on-paredit)
(add-hook 'clojure-mode-hook     'rc/turn-on-paredit)
(add-hook 'lisp-mode-hook        'rc/turn-on-paredit)
(add-hook 'common-lisp-mode-hook 'rc/turn-on-paredit)
(add-hook 'scheme-mode-hook      'rc/turn-on-paredit)
(add-hook 'racket-mode-hook      'rc/turn-on-paredit)

(setq tramp-auto-save-directory "/tmp")
;;;
(add-hook 'simpc-mode-hook 'electric-pair-local-mode)
;;; Emacs lisp
(add-hook 'emacs-lisp-mode-hook
          '(lambda ()
             (local-set-key (kbd "C-c C-j")
                            (quote eval-print-last-sexp))))
(add-to-list 'auto-mode-alist '("Cask" . emacs-lisp-mode))
;;; yasnippet
(rc/require 'yasnippet)

(require 'yasnippet)

(setq yas/triggers-in-field nil)
(setq yas-snippet-dirs '("~/.emacs.snippets/"))

(yas-global-mode 1)
;;; Multiple cursors
(rc/require 'multiple-cursors)

(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->")         'mc/mark-next-like-this)
(global-set-key (kbd "C-<")         'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<")     'mc/mark-all-like-this)
(global-set-key (kbd "C-\"")        'mc/skip-to-next-like-this)
(global-set-key (kbd "C-:")         'mc/skip-to-previous-like-this)

;;; Company
(rc/require 'company)
(require 'company)

(global-company-mode)

(add-hook 'tuareg-mode-hook
          (lambda ()
            (interactive)
            (company-mode 0)))

;;; Move Text
(rc/require 'move-text)
(global-set-key (kbd "M-p") 'move-text-up)
(global-set-key (kbd "M-n") 'move-text-down)

;;; Ebisp
(add-to-list 'auto-mode-alist '("\\.ebi\\'" . lisp-mode))

;;; Display line numbers
(when (version<= "26.0.50" emacs-version)
  (global-display-line-numbers-mode))

;;; Build system
(defun my/run-build-bat ()
  "Run build.bat in nearest directory."
  (interactive)
  (let ((root (locate-dominating-file default-directory "build.bat")))
    (if root
        (let ((default-directory root))
          (compile "build.bat"))
      (message "No build.bat found"))))

(global-set-key (kbd "<f5>") 'my/run-build-bat)
;;; Raylib build stuff
(defun my/run-build-sh ()
  "Run build.sh in nearest directory."
  (interactive)
  (let ((root (locate-dominating-file default-directory "build.sh")))
    (if root
        (let ((default-directory root))
          (compile "bash build.sh"))
      (message "No build.sh found"))))

(global-set-key (kbd "<f6>") 'my/run-build-sh)
;;; TODO/NOTE highlighting
(defface my/todo-face
  '((t (:foreground "#ff5555" :weight bold)))
  "Face for TODO")

(defface my/note-face
  '((t (:foreground "lime green" :weight bold)))
  "Face for NOTE")

(defun my/highlight-comments-only (limit)
  "Search for TODO/NOTE inside comments only."
  (let (found)
    (while (and (not found)
                (re-search-forward "\\<\\(TODO\\|NOTE\\)\\>" limit t))
      (when (nth 4 (syntax-ppss))
        (setq found t)))
    found))

(defun my/setup-todo-highlighting ()
  (font-lock-add-keywords
   nil
   '((my/highlight-comments-only
      (0 (cond
          ((string= (match-string 1) "TODO") 'my/todo-face)
          ((string= (match-string 1) "NOTE") 'my/note-face))
        t)))
   t)
  (font-lock-flush))

(add-hook 'prog-mode-hook 'my/setup-todo-highlighting)
;;; ====================================================================
;;; Markdown Support
;;; ====================================================================
(rc/require 'markdown-mode)
(require 'markdown-mode)

;; Use GitHub-Flavored Markdown for .md files
(add-to-list 'auto-mode-alist '("\\.md\\'" . gfm-mode))

;;; ====================================================================
;;; GLSL Shader Language Support
;;; ====================================================================
(rc/require 'glsl-mode)
(require 'glsl-mode)

(add-to-list 'auto-mode-alist '("\\.glsl\\'" . glsl-mode))
(add-to-list 'auto-mode-alist '("\\.vert\\'" . glsl-mode))
(add-to-list 'auto-mode-alist '("\\.frag\\'" . glsl-mode))
(add-to-list 'auto-mode-alist '("\\.geom\\'" . glsl-mode))

;; Hook into your existing Tree-Sitter highlighting & Electric Pair settings
(add-hook 'glsl-mode-hook
          (lambda ()
            (electric-pair-local-mode 1)
            (when (fboundp 'tree-sitter-hl-mode)
              ;; Automatically grabs standard 'glsl or 'cpp structures if installed
              (ignore-errors 
                (setq-local tree-sitter-language (tree-sitter-require 'glsl))
                (tree-sitter-hl-mode 1)))))

;;; Compilation buffer
(setq display-buffer-alist
      '(("\\*compilation\\*"
         (display-buffer-in-side-window)
         (side . bottom)
         (window-height . 0.25))))

(setq compilation-scroll-output t)

(add-hook 'compilation-mode-hook
          (lambda ()
            (setq-local cursor-type nil)))

(global-set-key (kbd "<f4>") 'compile)

(require 'compile)

;; Pascal error format: pascalik.pas(24,44) Error: ...
(add-to-list 'compilation-error-regexp-alist
             '("\\([a-zA-Z0-9\\.]+\\)(\\([0-9]+\\)\\(,\\([0-9]+\\)\\)?) \\(Warning:\\)?"
               1 2 (4) (5)))

(load-file custom-file)
