;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "flycheck-haskell" "20230706.1439"
  "Flycheck: Automatic Haskell configuration."
  '((emacs        "24.3")
    (flycheck     "0.25")
    (haskell-mode "13.7")
    (dash         "2.4.0")
    (seq          "1.11")
    (let-alist    "1.0.1"))
  :url "https://github.com/flycheck/flycheck-haskell"
  :commit "b7c4861aa754220b7d0cfc05aa0895bb35665683"
  :revdesc "b7c4861aa754"
  :keywords '("tools" "convenience")
  :authors '(("Sebastian Wiesner" . "swiesner@lunaryorn.com"))
  :maintainers '(("Sebastian Wiesner" . "swiesner@lunaryorn.com")))
