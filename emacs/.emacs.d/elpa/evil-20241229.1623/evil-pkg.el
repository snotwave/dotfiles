;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "evil" "20241229.1623"
  "Extensible vi layer."
  '((emacs    "24.1")
    (cl-lib   "0.5")
    (goto-chg "1.6")
    (nadvice  "0.3"))
  :url "https://github.com/emacs-evil/evil"
  :commit "cc1a7bde72b38cba3f3612aac460fce57f7c3f68"
  :revdesc "cc1a7bde72b3"
  :keywords '("emulations")
  :maintainers '(("Tom Dalziel" . "tom.dalziel@gmail.com")))
