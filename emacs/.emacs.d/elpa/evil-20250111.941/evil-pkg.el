;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "evil" "20250111.941"
  "Extensible vi layer."
  '((emacs    "24.1")
    (cl-lib   "0.5")
    (goto-chg "1.6")
    (nadvice  "0.3"))
  :url "https://github.com/emacs-evil/evil"
  :commit "a92c07383a426a90bfebca212f5b8f36a7a1c282"
  :revdesc "a92c07383a42"
  :keywords '("emulations")
  :maintainers '(("Tom Dalziel" . "tom.dalziel@gmail.com")))
