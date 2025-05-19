;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "magit" "20250217.2315"
  "A Git porcelain inside Emacs."
  '((emacs         "27.1")
    (compat        "30.0.2.0")
    (llama         "0.6.0")
    (magit-section "4.3.0")
    (seq           "2.24")
    (transient     "0.8.4")
    (with-editor   "3.4.3"))
  :url "https://github.com/magit/magit"
  :commit "12e1f3838cd6879fa79f5548eba5e80ad19d94f9"
  :revdesc "12e1f3838cd6"
  :keywords '("git" "tools" "vc")
  :authors '(("Marius Vollmer" . "marius.vollmer@gmail.com")
             ("Jonas Bernoulli" . "emacs.magit@jonas.bernoulli.dev"))
  :maintainers '(("Jonas Bernoulli" . "emacs.magit@jonas.bernoulli.dev")
                 ("Kyle Meyer" . "kyle@kyleam.com")))
