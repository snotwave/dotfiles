;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "magit" "20250302.1612"
  "A Git porcelain inside Emacs."
  '((emacs         "27.1")
    (compat        "30.0.2.0")
    (llama         "0.6.1")
    (magit-section "4.3.1")
    (seq           "2.24")
    (transient     "0.8.5")
    (with-editor   "3.4.3"))
  :url "https://github.com/magit/magit"
  :commit "c0a8e694b9af60a7e255fa34252abab45096e523"
  :revdesc "c0a8e694b9af"
  :keywords '("git" "tools" "vc")
  :authors '(("Marius Vollmer" . "marius.vollmer@gmail.com")
             ("Jonas Bernoulli" . "emacs.magit@jonas.bernoulli.dev"))
  :maintainers '(("Jonas Bernoulli" . "emacs.magit@jonas.bernoulli.dev")
                 ("Kyle Meyer" . "kyle@kyleam.com")))
