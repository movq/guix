;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2025 Mike Jones <mike@mjones.io>
;;;
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.
(define-module (gnu packages aider)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages crates-io)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages rust-apps)
  #:use-module (gnu packages xdisorg)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system pyproject)
  #:use-module (guix build-system python)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils))

(define-public python-grep-ast
  (package
    (name "python-grep-ast")
    (version "0.8.1")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "grep_ast" version))
       (sha256
        (base32 "0zqqck9clf85kdqqlx9xar4611i9h0giwpx4qryz8ah48igjibwg"))))
    (build-system python-build-system)
    (propagated-inputs (list python-pathspec python-tree-sitter-language-pack))
    (native-inputs (list python-setuptools python-wheel))
    (home-page "https://github.com/paul-gauthier/grep-ast")
    (synopsis "A tool to grep through the AST of a source file")
    (description
     "This package provides a tool to grep through the AST of a source file.")
    (license license:asl2.0)))

(define-public python-watchfiles
  (package
    (name "python-watchfiles")
    (version "1.0.4")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "watchfiles" version))
       (sha256
        (base32 "01bjf55bv3fsnpjrypydfgfip72z4lqbghh09wzdfqhhs7pp793b"))))
    (build-system cargo-build-system)
    (arguments
     (list
      #:imported-modules `(,@%cargo-build-system-modules
                           ,@%pyproject-build-system-modules)
      #:modules '((guix build cargo-build-system)
                  ((guix build pyproject-build-system)
                   #:prefix py:)
                  (guix build utils))
      #:phases #~(modify-phases %standard-phases
                   (replace 'build
                     (assoc-ref py:%standard-phases
                                'build))
                   (replace 'install
                     (assoc-ref py:%standard-phases
                                'install))
                   (add-after 'install 'compile-bytecode
                     (assoc-ref py:%standard-phases
                                'compile-bytecode)))
      #:cargo-inputs `(("rust-crossbeam-channel" ,rust-crossbeam-channel-0.5)
                       ("rust-notify" ,rust-notify-7)
                       ("rust-pyo3" ,rust-pyo3-0.23))))

    (propagated-inputs (list python-anyio))
    (native-inputs (list maturin
                         python-wrapper))
    (home-page "https://github.com/samuelcolvin/watchfiles")
    (synopsis
     "Simple, modern and high performance file watching and code reload in python.")
    (description
     "Simple, modern and high performance file watching and code reload in python.")
    (license license:expat)))

(define-public aider
  (package
    (name "aider")
    (version "0.79.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/Aider-AI/aider")
              (commit (string-append "v" version))))
       (sha256
        (base32 "1gr05fh9jr34mxh13hvprn6a8xj9icb60gxr1dydls2wrsjvyw7i"))
       (patches (search-patches "aider-disable-analytics.patch"
                                "aider-disable-updater.patch"
                                "aider-disable-pypandoc.patch"))))
    (build-system pyproject-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'fix-installation
            (lambda _
              (substitute* "pyproject.toml"
                (("include = \\[\"aider\"\\]")
                 "include = [\"aider\", \"aider.*\"]

[tool.setuptools.package-data]
\"*\" = [\"*.scm\"]
\"aider.resources\" = [\"*\"]")))))))
    (propagated-inputs (list python-configargparse
                             python-diff-match-patch
                             python-diskcache
                             python-dotenv
                             python-grep-ast
                             python-httpx
                             python-importlib-resources
                             python-json5
                             python-packaging
                             python-pexpect
                             python-pillow
                             python-prompt-toolkit
                             python-pydub
                             python-pyperclip
                             python-pyyaml
                             python-tqdm
                             python-watchfiles))
    (native-inputs (list python-setuptools))
    (home-page "https://github.com/paul-gauthier/aider")
    (synopsis "AI programming assistant")
    (description
     "This package provides a terminal-based AI programming assistant.")
    (license license:asl2.0)))
