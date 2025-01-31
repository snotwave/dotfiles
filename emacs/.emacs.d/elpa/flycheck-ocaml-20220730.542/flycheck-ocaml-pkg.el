;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "flycheck-ocaml" "20220730.542"
  "Flycheck: OCaml support."
  '((emacs     "24.3")
    (flycheck  "32")
    (merlin    "3.0.1")
    (let-alist "1.0.3"))
  :url "https://github.com/flycheck/flycheck-ocaml"
  :commit "7d7b969cba6ff75fd0e5694aa0ffd6be05beb390"
  :revdesc "7d7b969cba6f"
  :keywords '("convenience" "tools" "languages" "ocaml")
  :authors '(("Sebastian Wiesner" . "swiesner@lunaryorn.com"))
  :maintainers '(("Bozhidar Batsov" . "bozhidar@batsov.dev")))
