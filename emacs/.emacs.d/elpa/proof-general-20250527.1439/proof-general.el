;;; proof-general.el --- A generic Emacs interface for proof assistants -*- lexical-binding: t; -*-

;; This file is part of Proof General.

;; Portions © Copyright 1994-2012  David Aspinall and University of Edinburgh
;; Portions © Copyright 2003-2022  Free Software Foundation, Inc.
;; Portions © Copyright 2001-2017  Pierre Courtieu
;; Portions © Copyright 2010, 2016  Erik Martin-Dorel
;; Portions © Copyright 2011-2013, 2016-2017  Hendrik Tews
;; Portions © Copyright 2015-2017  Clément Pit-Claudel

;; Authors: (see the AUTHORS file distributed along the sources)
;; Maintainer: proof-general-maintainers@groupes.renater.fr
;; URL: https://proofgeneral.github.io/
;; Package-Requires: ((emacs "25.2"))
;; Package-Version: 20250527.1439
;; Package-Revision: 964a5958e7c8

;; The software is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; Proof General is a generic Emacs interface for proof assistants
;; (also known as interactive theorem provers).
;;
;; It is supplied ready to use for the proof assistants Coq,
;; EasyCrypt, qrhl-tool, and PhoX.
;;
;; See https://proofgeneral.github.io/ for installation instructions
;; and online documentation.  Or browse the accompanying info manual:
;; (info-display-manual "ProofGeneral")
;;
;; Regarding the Coq proof assistant, you may be interested in the
;; company-coq extension of ProofGeneral (also available in MELPA).

;;; Code:

;; Proof General's initialization code (in generic/proof-site) is relatively
;; complex, in part because it was written before package.el existed, and in
;; part because package.el still doesn't look for autoloads in subdirectories.
;; This file is a thin, package.el-friendly wrapper around generic/proof-site,
;; suitable for execution on Emacs start-up.  It serves two purposes:
;;
;; * Setting up the load path when byte-compiling PG.
;; * Loading a minimal PG setup on startup (not all of Proof General, of course;
;;   mostly mode hooks and autoloads).

;;;###autoload
(eval-and-compile
  (defvar pg-init--script-full-path
    (or (bound-and-true-p byte-compile-current-file)
        (and load-in-progress load-file-name)

        (buffer-file-name)))
  (defvar pg-init--pg-root
    (file-name-directory pg-init--script-full-path)))

;;;###autoload
(unless (bound-and-true-p byte-compile-current-file)
  ;; This require breaks compilation, so it must only run when loading the package.
  (require 'proof-site (expand-file-name "generic/proof-site" pg-init--pg-root)))

(eval-when-compile
  ;; FIXME: [ This is used during installation of the ELPA package ]
  ;; We presume that this file will be compiled before any of the files in
  ;; sub-directories and we presume that all files are compiled within the same
  ;; session, so we here add to load-path all the subdirectories so
  ;; that files in (say) coq/ can (require 'coq-foo) and the compiler will find
  ;; the corresponding file.
  (let ((byte-compile-directories
         '("generic" "lib"
           "coq" "easycrypt" "pghaskell" "pgocaml" "pgshell" "phox" "qrhl"
           )))
    (dolist (dir byte-compile-directories)
      (add-to-list 'load-path (expand-file-name dir pg-init--pg-root)))))

(provide 'proof-general)
;;; proof-general.el ends here
