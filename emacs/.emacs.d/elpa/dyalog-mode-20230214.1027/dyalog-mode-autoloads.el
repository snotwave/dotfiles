;;; dyalog-mode-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (directory-file-name (file-name-directory load-file-name))) (car load-path)))



;;; Generated autoloads from dyalog-mode.el

(autoload 'dyalog-fix-altgr-chars "dyalog-mode" "\
Fix a key map so AltGr+char isn't confused with C-M-char.

KEYMAP is an Emacs keymap.

APLCHARS is a string of APL-characters produced by pressing AltGr together
with some character.

REGULARCHARS is a string of the characters that when pressed
together with AltGr produce the corresponding apl character in APLCHARS.

(fn KEYMAP APLCHARS REGULARCHARS)")
(autoload 'dyalog-ediff-forward-word "dyalog-mode" "\
Move point forward one word." t)
(autoload 'dyalog-session-connect "dyalog-mode" "\
Connect to a Dyalog session.
HOST (defaults to localhost) and PORT (defaults to 7979) give
adress to connect to.

(fn &optional HOST PORT)" t)
(autoload 'dyalog-editor-connect "dyalog-mode" "\
Connect to a Dyalog process as an editor.
HOST (defaults to localhost) and PORT (defaults to 8080) give
adress to connect to.

(fn &optional HOST PORT)" t)
(autoload 'dyalog-mode "dyalog-mode" "\
Major mode for editing Dyalog APL code.

\\{dyalog-mode-map}

(fn)" t)
(autoload 'dyalog-array-mode "dyalog-mode" "\
Major mode for editing Dyalog APL arrays.

\\{dyalog-array-mode-map\\}

(fn)" t)
(add-to-list 'auto-mode-alist '("\\.dyalog$" . dyalog-mode))
(register-definition-prefixes "dyalog-mode" '("dyalog-"))

;;; End of scraped data

(provide 'dyalog-mode-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; dyalog-mode-autoloads.el ends here