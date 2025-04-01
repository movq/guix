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
  #:use-module (gnu packages check)
  #:use-module (gnu packages crates-io)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages digest)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-crypto)
  #:use-module (gnu packages python-science)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages rust-apps)
  #:use-module (gnu packages version-control)
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
\"aider.resources\" = [\"*\"]"))))
          (add-after 'unpack 'patch-requirements
            (lambda _
              (substitute* "pyproject.toml"
                (("dependencies = \\{ file = \"requirements.txt\" \\}") "")))))))
    (propagated-inputs (list python-configargparse
                             python-diff-match-patch
                             python-diskcache
                             python-dotenv
                             python-gitpython
                             python-grep-ast
                             python-httpx
                             python-importlib-resources
                             python-json5
                             python-litellm
                             python-networkx
                             python-openai
                             python-packaging
                             python-pexpect
                             python-pillow
                             python-prompt-toolkit
                             python-pydub
                             python-pyperclip
                             python-pyyaml
                             python-tqdm
                             python-watchfiles
                             python-wcwidth
                             python-yarl))
    (native-inputs (list python-setuptools))
    (home-page "https://github.com/paul-gauthier/aider")
    (synopsis "AI programming assistant")
    (description
     "This package provides a terminal-based AI programming assistant.")
    (license license:asl2.0)))

(define-public python-tiktoken
  (package
    (name "python-tiktoken")
    (version "0.9.0")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "tiktoken" version))
       (sha256
        (base32 "0p9cg6n8mzdi4lbbwxrrp26chy5hr14bqmzr3w74kq1qm6k5qanh"))))
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
                   (delete 'package)
                   (replace 'install
                     (assoc-ref py:%standard-phases
                                'install)))
      #:cargo-inputs
      `(("rust-bstr" ,rust-bstr-1)
        ("rust-fancy-regex" ,rust-fancy-regex-0.13)
        ("rust-pyo3" ,rust-pyo3-0.22))))
    (propagated-inputs (list python-regex python-requests))
    (native-inputs
     (list python-setuptools
           python-setuptools-rust
           python-wheel
           python-wrapper))
    (home-page #f)
    (synopsis "tiktoken is a fast BPE tokeniser for use with OpenAI's models")
    (description
     "tiktoken is a fast BPE tokeniser for use with @code{OpenAI's} models.")
    (license #f)))

(define-public python-sse-starlette
  (package
    (name "python-sse-starlette")
    (version "2.2.1")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "sse_starlette" version))
       (sha256
        (base32 "06dl330s5i7isw8kp58xhpm7kcxl105l6wylnbbfwji735ghsisl"))))
    (build-system pyproject-build-system)
    (propagated-inputs (list python-anyio python-starlette))
    (native-inputs (list python-setuptools python-wheel))
    (home-page #f)
    (synopsis "SSE plugin for Starlette")
    (description "SSE plugin for Starlette.")
    (license #f)))

(define-public python-litellm
  (package
    (name "python-litellm")
    (version "1.64.1")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "litellm" version))
       (sha256
        (base32 "12cgxkky7zyh990vmhyr0z14hgy5axv9c7k99pd7mmzvn68wifkk"))))
    (build-system pyproject-build-system)
    (propagated-inputs (list python-aiohttp
                             python-click
                             python-httpx
                             python-importlib-metadata
                             python-jinja2
                             python-jsonschema
                             python-openai
                             python-pydantic-2
                             python-dotenv
                             python-tiktoken
                             python-tokenizers))
    (native-inputs (list python-poetry-core python-wheel))
    (home-page #f)
    (synopsis "Library to easily interface with LLM API providers")
    (description "Library to easily interface with LLM API providers.")
    (license license:expat)))

(define-public python-fastavro
  (package
    (name "python-fastavro")
    (version "1.10.0")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "fastavro" version))
       (sha256
        (base32 "0vw8ssjh2lbn286r0fk6gfrj24rj0al7b3587m5gxkajdnn43gs7"))))
    (build-system pyproject-build-system)
    (native-inputs (list python-cython python-setuptools python-wheel))
    (home-page "https://github.com/fastavro/fastavro")
    (synopsis "Fast read/write of AVRO files")
    (description "Fast read/write of AVRO files.")
    (license license:expat)))

(define-public python-httpx-sse
  (package
    (name "python-httpx-sse")
    (version "0.4.0")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "httpx-sse" version))
       (sha256
        (base32 "08cp2dhzjlxpba8yrmjyyhbhixxm5va9wlnks6nj5qqc0yis708y"))))
    (build-system pyproject-build-system)
    (native-inputs (list python-setuptools python-setuptools-scm python-wheel))
    (propagated-inputs (list python-httpx))
    (home-page "")
    (synopsis "Consume Server-Sent Event (SSE) messages with HTTPX.")
    (description "Consume Server-Sent Event (SSE) messages with HTTPX.")
    (license license:expat)))

(define-public python-faiss-cpu
  (package
    (name "python-faiss-cpu")
    (version "1.10.0")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "faiss_cpu" version))
       (sha256
        (base32 "17a7dvacq8yajvj8vryl4qhqs6y9di6mm2kzsvs3dh2by9asbp2v"))))
    (build-system pyproject-build-system)
    (propagated-inputs (list python-numpy python-packaging))
    (native-inputs (list python-numpy python-setuptools python-wheel))
    (home-page #f)
    (synopsis
     "A library for efficient similarity search and clustering of dense vectors.")
    (description
     "This package provides a library for efficient similarity search and clustering
of dense vectors.")
    (license license:expat)))

(define-public python-tokenizers
  (package
    (name "python-tokenizers")
    (version "0.21.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/huggingface/tokenizers.git")
             (commit (string-append "v" version))))
       (sha256
        (base32 "0q0v2p9r201n1a12rni6qbc0814ynzx66y46is6hr7v7lq4xjbnx"))))
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
                   (add-after 'unpack 'cd-to-bindings-dir
                     (lambda _
                       (chdir "bindings/python")))
                   (replace 'build
                     (assoc-ref py:%standard-phases
                                'build))
                   (delete 'package)
                   (replace 'install
                     (assoc-ref py:%standard-phases
                                'install)))
      #:cargo-development-inputs
      `(("rust-serde" ,rust-serde-1)
        ("rust-serde-derive" ,rust-serde-derive-1))
      #:cargo-inputs `(
                       ("rust-derive-builder" ,rust-derive-builder-0.20)
                       ("rust-env-logger" ,rust-env-logger-0.11)
                       ("rust-esaxx-rs" ,rust-esaxx-rs-0.1)
                       ("rust-indicatif" ,rust-indicatif-0.17)
                       ("rust-itertools" ,rust-itertools-0.12)
                       ("rust-macro-rules-attribute" ,rust-macro-rules-attribute-0.2)
                       ("rust-monostate" ,rust-monostate-0.1)
                       ("rust-ndarray" ,rust-ndarray-0.16)
                       ("rust-numpy" ,rust-numpy-0.23)
                       ("rust-pyo3" ,rust-pyo3-0.23)
                       ("rust-rand" ,rust-rand-0.8)
                       ("rust-rayon" ,rust-rayon-1)
                       ("rust-rayon-cond" ,rust-rayon-cond-0.3)
                       ("rust-regex" ,rust-regex-1)
                       ("rust-regex-syntax" ,rust-regex-syntax-0.8)
                       ("rust-spm-precompiled" ,rust-spm-precompiled-0.1)
                       ("rust-unicode-normalization-alignments"
                        ,rust-unicode-normalization-alignments-0.1))))
    (propagated-inputs (list python-huggingface-hub python-huggingface-hub))
    (native-inputs (list python-black
                         maturin
                         python-numpy
                         python-pytest
                         python-requests
                         python-setuptools
                         python-wrapper))
    (home-page #f)
    (synopsis #f)
    (description #f)
    (license #f)))
