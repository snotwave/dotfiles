;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "company-coq" "20221130.536"
  "A collection of extensions for Proof General's Coq mode."
  '((cl-lib       "0.5")
    (dash         "2.12.1")
    (yasnippet    "0.11.0")
    (company      "0.8.12")
    (company-math "1.1"))
  :url "https://github.com/cpitclaudel/company-coq"
  :commit "5affe7a96a25df9101f9e44bac8a828d8292c2fa"
  :revdesc "5affe7a96a25"
  :keywords '("convenience" "languages")
  :authors '(("Clément Pit-Claudel" . "clement.pitclaudel@live.com"))
  :maintainers '(("Clément Pit-Claudel" . "clement.pitclaudel@live.com")))
