;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2022 Luis Henrique Gomes Higino <luishenriquegh2701@gmail.com>
;;; Copyright © 2022, 2023 Pierre Langlois <pierre.langlois@gmx.com>
;;; Copyright © 2022 muradm <mail@muradm.net>
;;; Copyright © 2022, 2024 Aleksandr Vityazev <avityazev@posteo.org>
;;; Copyright © 2023 Andrew Tropin <andrew@trop.in>
;;; Copyright © 2023, 2024 Nicolas Graves <ngraves@ngraves.fr>
;;; Copyright © 2023 Zheng Junjie <873216071@qq.com>
;;; Copyright © 2023, 2024 Raven Hallsby <karl@hallsby.com>
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

(define-module (gnu packages tree-sitter)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages crates-graphics)
  #:use-module (gnu packages crates-io)
  #:use-module (gnu packages crates-vcs)
  #:use-module (gnu packages crates-web)
  #:use-module (gnu packages graphviz)
  #:use-module (gnu packages icu4c)
  #:use-module (gnu packages node)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-xyz)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system pyproject)
  #:use-module (guix build-system python)
  #:use-module (guix build-system tree-sitter)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils))

(define-public python-tree-sitter
    (package
      (name "python-tree-sitter")
      (version "0.24.0")
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/tree-sitter/py-tree-sitter")
                      (commit (string-append "v" version))))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "00scl7srac55lp99kc4qsx9wbk7gx09rhmdh6hgwqxqa7s62divn"))))
      (build-system pyproject-build-system)
      (arguments
       (list
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'set-tree-sitter-lib-path
              (lambda _
                (invoke "patch" "-p1" "-i" #$(plain-file
                                               "python-tree-sitter-setup-py.patch"
"Index: gqlk2nfm7wigy42qkq097w1si046p17x-python-tree-sitter-0.24.0-checkout/setup.py
===================================================================
--- gqlk2nfm7wigy42qkq097w1si046p17x-python-tree-sitter-0.24.0-checkout.orig/setup.py
+++ gqlk2nfm7wigy42qkq097w1si046p17x-python-tree-sitter-0.24.0-checkout/setup.py
@@ -12,7 +12,6 @@ setup(
         Extension(
             name=\"tree_sitter._binding\",
             sources=[
-                \"tree_sitter/core/lib/src/lib.c\",
                 \"tree_sitter/binding/language.c\",
                 \"tree_sitter/binding/lookahead_iterator.c\",
                 \"tree_sitter/binding/lookahead_names_iterator.c\",
@@ -27,8 +26,13 @@ setup(
             ],
             include_dirs=[
                 \"tree_sitter/binding\",
-                \"tree_sitter/core/lib/include\",
-                \"tree_sitter/core/lib/src\",
+                INCLUDE_DIRS,
+            ],
+            library_dirs=[
+                LIBRARY_DIRS,
+            ],
+            libraries=[
+                \"tree-sitter\"
             ],
             define_macros=[
                 (\"PY_SSIZE_T_CLEAN\", None),
"))
                (let ((tree-sitter #$(this-package-input "tree-sitter")))
                  (substitute* "setup.py"
                    (("LIBRARY_DIRS")
                     (string-append
                      "\"" tree-sitter "/lib\""))
                    (("INCLUDE_DIRS")
                     (string-append
                      "\"" tree-sitter "/include\"")))))))))
      (inputs (list tree-sitter))
      (native-inputs
       (list python-setuptools python-wheel))
      (home-page "https://github.com/tree-sitter/py-tree-sitter")
      (synopsis "Python bindings to the Tree-sitter parsing library")
      (description "This package provides Python bindings to the
  Tree-sitter parsing library.")
      (license license:expat)))

(define-public rust-tree-sitter-bash-0.23
  (package
    (name "rust-tree-sitter-bash")
    (version "0.23.3")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-bash" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "0bm5chcqq5fvfb505h87d6ab5ny9l60lxy0x5ga3ghrsc944v6ij"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter/tree-sitter-bash")
    (synopsis "Bash grammar for tree-sitter")
    (description "This package provides a Bash grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-c-0.23
  (package
    (name "rust-tree-sitter-c")
    (version "0.23.4")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-c" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "0wcwdvp8k9qsyfb5zpa9cq05kc5dp0fx11wysvv2xp452nzv3lmg"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs (("rust-cc" ,rust-cc-1)
                       ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter/tree-sitter-c")
    (synopsis "C grammar for tree-sitter")
    (description "This package provides C grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-cpp-0.23
  (package
    (name "rust-tree-sitter-cpp")
    (version "0.23.4")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-cpp" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "0hs7p45av437iw8rzsyw46qs06axbam7wadr655apd27kpm9c8fz"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs (("rust-cc" ,rust-cc-1)
                       ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter/tree-sitter-cpp")
    (synopsis "C++ grammar for tree-sitter")
    (description "This package provides C++ grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-css-0.23
  (package
    (name "rust-tree-sitter-css")
    (version "0.23.2")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-css" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "17mjy7f1s3cq8dacxaj3ixhqixlra4755gkz5b8m04yljjblimjs"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs (("rust-cc" ,rust-cc-1)
                       ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter/tree-sitter-css")
    (synopsis "CSS grammar for tree-sitter")
    (description "This package provides CSS grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-c-sharp-0.23
  (package
    (name "rust-tree-sitter-c-sharp")
    (version "0.23.1")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-c-sharp" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "1c7w6wvjc54k6kh0qrlspm9ksr4y10aq4fv6b0bkaibvrb66mw37"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs (("rust-cc" ,rust-cc-1)
                       ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter/tree-sitter-c-sharp")
    (synopsis "C# grammar for tree-sitter")
    (description "This package provides C# grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-elixir-0.3
  (package
    (name "rust-tree-sitter-elixir")
    (version "0.3.4")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-elixir" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "0grdkbx6bqw3s1w3mkk94sibmhgdicdlqirjzpc57zdl8x348pg4"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs (("rust-cc" ,rust-cc-1)
                       ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs (("rust-tree-sitter" ,rust-tree-sitter-0.23))))
    (home-page "https://github.com/elixir-lang/tree-sitter-elixir")
    (synopsis "Elixir grammar for the tree-sitter parsing library")
    (description
     "This package provides Elixir grammar for the tree-sitter parsing library.")
    (license license:asl2.0)))

(define-public rust-tree-sitter-go-0.23
  (package
    (name "rust-tree-sitter-go")
    (version "0.23.4")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-go" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "0cc4w4p12inxpsn2hgpmbvw1nyf5cm0l9pa705hbw3928milfgdi"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter/tree-sitter-go")
    (synopsis "Go grammar for tree-sitter")
    (description "This package provides a Go grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-haskell-0.23
  (package
    (name "rust-tree-sitter-haskell")
    (version "0.23.1")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-haskell" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "19057d99kaq7bn8k86baf7v4q4mjv8p5mjr7zh9vm32l0kjm2z4p"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.23))))
    (home-page "https://github.com/tree-sitter/tree-sitter-haskell")
    (synopsis "Haskell grammar for tree-sitter")
    (description "This package provides a Haskell grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-html-0.23
  (package
    (name "rust-tree-sitter-html")
    (version "0.23.2")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-html" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "1vk3xyxnf3xv19qisyj2knd346dq4yjamawv6bg1w1ljbn7706r6"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter/tree-sitter-html")
    (synopsis "HTML grammar for tree-sitter")
    (description "This package provides a HTML grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-java-0.23
  (package
    (name "rust-tree-sitter-java")
    (version "0.23.5")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-java" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "1mlh3skj2nasrwdz0v865r4hxnk7v8037z8nwqab4yf6r36wp9ha"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter/tree-sitter-java")
    (synopsis "Java grammar for tree-sitter")
    (description "This package provides a Java grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-javascript-0.23
  (package
    (name "rust-tree-sitter-javascript")
    (version "0.23.1")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-javascript" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "1cf19p9rl96yqjjhzimhp0dpvp2xxq8fqg2w29nc25h4krcvyh5z"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter/tree-sitter-javascript")
    (synopsis "JavaScript grammar for tree-sitter")
    (description
     "This package provides @code{JavaScript} grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-json-0.24
  (package
    (name "rust-tree-sitter-json")
    (version "0.24.8")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-json" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "0wf4gsa5mcrcprg8wh647n76rwv4cx8kbky6zw605h06lk67lwjd"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter/tree-sitter-json")
    (synopsis "JSON grammar for tree-sitter")
    (description "This package provides a JSON grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-julia-0.23
  (package
    (name "rust-tree-sitter-julia")
    (version "0.23.1")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-julia" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "08z33mq5n5z3xgjjcjrha8b4rrci7f5ykc8rfs3fw4l82wd76i21"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter/tree-sitter-julia")
    (synopsis "Julia grammar for tree-sitter")
    (description "This package provides a Julia grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-lua-0.2
  (package
    (name "rust-tree-sitter-lua")
    (version "0.2.0")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-lua" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "07k4753h1nz3pbffcnclxjz2xcfvb6hb7jv0fs7cbzk517grmnsw"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.23))))
    (home-page "https://github.com/tree-sitter-grammars/tree-sitter-lua")
    (synopsis "Lua grammar for tree-sitter")
    (description "This package provides a Lua grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-make-1
  (package
    (name "rust-tree-sitter-make")
    (version "1.1.1")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-make" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "0101h5ilrv2aqjffdlnq2d2m9mpj5fcfzvwamsgv3nnbrg3qv6f5"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter-grammars/tree-sitter-make")
    (synopsis "Makefile grammar for tree-sitter")
    (description "This package provides a Makefile grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-nix-0.0.2
  (package
    (name "rust-tree-sitter-nix")
    (version "0.0.2")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-nix" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "0160v6rqal8lsw9slx7x52ccq7cc5lfk6xd088rdcxyk0n3lz39s"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/nix-community/tree-sitter-nix")
    (synopsis "Nix grammar for the Tree-sitter parsing library")
    (description
     "This package provides a Nix grammar for the Tree-sitter parsing library.")
    (license license:expat)))

(define-public rust-tree-sitter-objc-3
  (package
    (name "rust-tree-sitter-objc")
    (version "3.0.2")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-objc" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "1lp1570h6lwhknzq3nn9sf26cfkqbx99vrrm0mpigz13ciavpa4w"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter-grammars/tree-sitter-objc")
    (synopsis "Objective-C grammar for tree-sitter")
    (description "This package provides an Objective-C grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-ocaml-0.23
  (package
    (name "rust-tree-sitter-ocaml")
    (version "0.23.2")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-ocaml" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "0xz3dkvb40b5anir8ld7547w2kibbms75y7i1kfhcn8p7ni09hck"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter/tree-sitter-ocaml")
    (synopsis "OCaml grammar for tree-sitter")
    (description "This package provides an OCaml grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-php-0.23
  (package
    (name "rust-tree-sitter-php")
    (version "0.23.11")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-php" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "030kiknyk2lw54yj7mzj92kfr5v0qr81qymhvkqy9kvjj97fjrph"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter/tree-sitter-php")
    (synopsis "PHP grammar for tree-sitter")
    (description "This package provides a PHP grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-python-0.23
  (package
    (name "rust-tree-sitter-python")
    (version "0.23.6")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-python" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "012bgzycya91lpdbrrr8xnw9xjz116nf1w61c2pwxapk4ym5l1ix"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter/tree-sitter-python")
    (synopsis "Python grammar for tree-sitter")
    (description "This package provides a Python grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-ruby-0.23
  (package
    (name "rust-tree-sitter-ruby")
    (version "0.23.1")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-ruby" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "15cz4h1sfgf838r2pmf7vg9ahh0kwgkvvnjgbdbrrfzn9vm8815y"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter/tree-sitter-ruby")
    (synopsis "Ruby grammar for tree-sitter")
    (description "This package provides a Ruby grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-rust-0.23
  (package
    (name "rust-tree-sitter-rust")
    (version "0.23.2")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-rust" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "1bx4a58fdyqcbj99qywl4g572rk4daa46xrcaqy6hgm6ki24vmm4"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter/tree-sitter-rust")
    (synopsis "Rust grammar for tree-sitter")
    (description "This package provides a Rust grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-scala-0.23
  (package
    (name "rust-tree-sitter-scala")
    (version "0.23.4")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-scala" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "0bsxq5ihmi4qp1g3cfrnmgznp8h4y739d8mz2yn9wvkknil5xppg"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter/tree-sitter-scala")
    (synopsis "Scala grammar for tree-sitter")
    (description "This package provides a Scala grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-toml-ng-0.7
  (package
    (name "rust-tree-sitter-toml-ng")
    (version "0.7.0")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-toml-ng" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "1cgbwl6x33d033ws4dwf3nw2pyd37m0bwxbxhl776jdfk34c5bg9"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter-grammars/tree-sitter-toml")
    (synopsis "TOML grammar for tree-sitter")
    (description "This package provides a TOML grammar for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-typescript-0.23
  (package
    (name "rust-tree-sitter-typescript")
    (version "0.23.2")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-typescript" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "1zsyaxx3v1sd8gx2zkscwv6z1sq2nvccqpvd8k67ayllipnpcpvc"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter/tree-sitter-typescript")
    (synopsis "TypeScript and TSX grammars for tree-sitter")
    (description
     "This package provides @code{TypeScript} and TSX grammars for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-xml-0.7
  (package
    (name "rust-tree-sitter-xml")
    (version "0.7.0")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-xml" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "1cxnr3q72fvld0ia8xjc5hl0x4xw9s7wvpcpsma4z68xb4gh8w76"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter-grammars/tree-sitter-xml")
    (synopsis "XML & DTD grammars for tree-sitter")
    (description "This package provides XML & DTD grammars for tree-sitter.")
    (license license:expat)))

(define-public rust-tree-sitter-yaml-0.7
  (package
    (name "rust-tree-sitter-yaml")
    (version "0.7.0")
    (source
     (origin
       (method url-fetch)
       (uri (crate-uri "tree-sitter-yaml" version))
       (file-name (string-append name "-" version ".tar.gz"))
       (sha256
        (base32 "0phdym735blwnb8aff4225c5gyws6aljy8vbifhz2xxnj8mrzjfh"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
         (("rust-cc" ,rust-cc-1)
          ("rust-tree-sitter-language" ,rust-tree-sitter-language-0.1))
       #:cargo-development-inputs
         (("rust-tree-sitter" ,rust-tree-sitter-0.24))))
    (home-page "https://github.com/tree-sitter-grammars/tree-sitter-yaml")
    (synopsis "YAML grammar for tree-sitter")
    (description "This package provides a YAML grammar for tree-sitter.")
    (license license:expat)))

(define-public tree-sitter
  (package
    (name "tree-sitter")
    (version "0.24.7")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/tree-sitter/tree-sitter")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1shg4ylvshs9bf42l8zyskfbkpzpssj6fhi3xv1incvpcs2c1fcw"))
              (modules '((guix build utils)))
              (snippet #~(begin
                           ;; Remove bundled ICU parts
                           (delete-file-recursively "lib/src/unicode")
                           ;; _ts_dup is used by tree-sitter-cli, so make it
                           ;; available in the shared library.
                           (substitute* "lib/src/tree.c"
                             (("int _ts_dup")
                              "int __attribute__((visibility(\"default\"))) _ts_dup"))))))
    (build-system gnu-build-system)
    (inputs (list icu4c))
    (arguments
     (list #:phases
           #~(modify-phases %standard-phases
               (delete 'configure))
           #:tests? #f ; there are no tests for the runtime library
           #:make-flags
           #~(list (string-append "PREFIX=" #$output)
                   (string-append "CC=" #$(cc-for-target)))))
    (home-page "https://tree-sitter.github.io/tree-sitter/")
    (synopsis "Incremental parsing system for programming tools")
    (description
     "Tree-sitter is a parser generator tool and an incremental parsing
library.  It can build a concrete syntax tree for a source file and
efficiently update the syntax tree as the source file is edited.

Tree-sitter aims to be:

@itemize
@item General enough to parse any programming language
@item Fast enough to parse on every keystroke in a text editor
@item Robust enough to provide useful results even in the presence of syntax errors
@item Dependency-free so that the runtime library (which is written in pure C)
can be embedded in any application
@end itemize

This package includes the @code{libtree-sitter} runtime library.")
    (license license:expat)))

(define-public tree-sitter-cli
  (package
    (inherit tree-sitter)
    (name "tree-sitter-cli")
    (source (origin
              (inherit (package-source tree-sitter))
              (snippet
               #~(begin
                   ;; parser.h gets baked into the binary, so we need to preserve it.
                   (copy-file "lib/src/parser.h" "lib/parser.h")
                   (substitute*
                     '("lib/binding_rust/lib.rs"
                       "cli/src/tests/detect_language.rs")
                     (("src/parser\\.h") "parser.h"))
                   ;; stdlib-symbols.txt is also needed for the build.
                   (copy-file "lib/src/wasm/stdlib-symbols.txt" "lib/stdlib-symbols.txt")
                   ;; Remove the runtime library code and dynamically link to
                   ;; it instead.
                   (delete-file-recursively "lib/src")
                   (delete-file "lib/binding_rust/build.rs")
                   (with-output-to-file "lib/binding_rust/build.rs"
                     (lambda _
                       (format #t "use std::{env, fs, path::PathBuf};
                              fn main() {~@
                              let out_dir = PathBuf::from(env::var(\"OUT_DIR\").unwrap());
                              fs::copy(\"stdlib-symbols.txt\",
                                        out_dir.join(\"stdlib-symbols.txt\")).unwrap();
                              println!(\"cargo:rustc-link-lib=tree-sitter\");~@
                              }~%")))))))
    (build-system cargo-build-system)
    (inputs
     (list tree-sitter graphviz node-lts))
    (arguments
     (list
      #:cargo-test-flags
      ''("--"
         ;; Skip tests which rely on downloading grammar fixtures.  It is
         ;; difficult to support such tests given upstream does not encode
         ;; which version of the grammars are expected.
         ;; Instead, we do run some tests for each grammar in the tree-sitter
         ;; build-system, by running `tree-sitter test'.  This isn't as
         ;; complete as running all tests from tree-sitter-cli, but it's a
         ;; good compromise compared to maintaining two different sets of
         ;; grammars (Guix packages vs test fixtures).
         "--skip=tests::async_context_test"
         "--skip=tests::corpus_test"
         "--skip=tests::detect_language"
         "--skip=tests::github_issue_test"
         "--skip=tests::highlight_test"
         "--skip=tests::language_test"
         "--skip=tests::node_test"
         "--skip=tests::parser_hang_test"
         "--skip=tests::parser_test"
         "--skip=tests::pathological_test"
         "--skip=tests::query_test"
         "--skip=tests::tags_test"
         "--skip=tests::test_highlight_test"
         "--skip=tests::test_tags_test"
         "--skip=tests::text_provider_test"
         "--skip=tests::tree_test")
      ;; We're only packaging the CLI program so we do not need to install
      ;; sources.
      #:install-source? #f
      #:cargo-inputs
      `(("rust-ansi-colours" ,rust-ansi-colours-1)
        ("rust-ansi-term" ,rust-ansi-term-0.12)
        ("rust-anyhow" ,rust-anyhow-1)
        ("rust-atty" ,rust-atty-0.2)
        ("rust-bstr" ,rust-bstr-1)
        ("rust-cc" ,rust-cc-1)
        ("rust-clap" ,rust-clap-2)
        ("rust-clap-complete-nushell" ,rust-clap-complete-nushell-4)
        ("rust-ctor" ,rust-ctor-0.2)
        ("rust-difference" ,rust-difference-2)
        ("rust-dirs" ,rust-dirs-3)
        ("rust-etcetera" ,rust-etcetera-0.8)
        ("rust-fs4" ,rust-fs4-0.12)
        ("rust-git2", rust-git2-0.20)
        ("rust-html-escape" ,rust-html-escape-0.2)
        ("rust-libloading" ,rust-libloading-0.7)
        ("rust-notify" ,rust-notify-8)
        ("rust-notify-debouncer-full" ,rust-notify-debouncer-full-0.5)
        ("rust-path-slash" ,rust-path-slash-0.2)
        ("rust-rand" ,rust-rand-0.8)
        ("rust-rustc-hash" ,rust-rustc-hash-1)
        ("rust-semver" ,rust-semver-1)
        ("rust-similar" ,rust-similar-2)
        ("rust-smallbitvec" ,rust-smallbitvec-2)
        ("rust-streaming-iterator" ,rust-streaming-iterator-0.1)
        ("rust-thiserror" ,rust-thiserror-1)
        ("rust-tiny-http" ,rust-tiny-http-0.12)
        ("rust-toml" ,rust-toml-0.5)
        ("rust-ureq" ,rust-ureq-3)
        ("rust-walkdir" ,rust-walkdir-2)
        ("rust-wasmparser" ,rust-wasmparser-0.224)
        ("rust-wasmtime-c-api-impl" ,rust-wasmtime-c-api-impl-29)
        ("rust-webbrowser" ,rust-webbrowser-1)
        ("rust-which" ,rust-which-4))
      #:cargo-development-inputs
      `(("rust-bindgen" ,rust-bindgen-0.71)
        ("rust-ctor" ,rust-ctor-0.1)
        ("rust-pretty-assertions" ,rust-pretty-assertions-1)
        ("rust-rand" ,rust-rand-0.8)
        ("rust-tempfile" ,rust-tempfile-3)
        ("rust-unindent" ,rust-unindent-0.2))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'patch-node
            (lambda _
              (substitute* "cli/src/main.rs"
                (("default_value = \"node\"")
                 (string-append
                  "default_value = \"" #$node-lts "/bin/node\"")))))
          (add-after 'unpack 'patch-dot
            (lambda _
              (substitute* "cli/src/util.rs"
                (("Command::new\\(\"dot\"\\)")
                 (string-append
                  "Command::new(\"" #$graphviz "/bin/dot\")")))))
          (replace 'install
            (lambda _
              (let ((bin (string-append #$output "/bin")))
                (mkdir-p bin)
                (install-file "target/release/tree-sitter" bin)))))))
    (description "Tree-sitter is a parser generator tool and an incremental
parsing library.  It can build a concrete syntax tree for a source file and
efficiently update the syntax tree as the source file is edited.

Tree-sitter aims to be:

@enumerate
@item General enough to parse any programming language.
@item Fast enough to parse on every keystroke in a text editor.
@item Robust enough to provide useful results even in the presence of syntax
errors.
@item Dependency-free so that the runtime library (which is written in pure C)
can be embedded in any application.
@end enumerate

This package includes the @command{tree-sitter} command-line tool.")
    (license license:expat)))

(define (tree-sitter-delete-generated-files grammar-directories)
  #~(begin
      (use-modules (guix build utils))
      (delete-file "binding.gyp")
      (delete-file-recursively "bindings")
      (for-each
       (lambda (lang)
         (with-directory-excursion lang
           (delete-file "src/grammar.json")
           (delete-file "src/node-types.json")
           (delete-file "src/parser.c")
           (delete-file-recursively "src/tree_sitter")))
       '#$grammar-directories)))

(define* (tree-sitter-grammar
          name text hash version
          #:key
          (commit (string-append "v" version))
          (repository-url
           (format #f "https://github.com/tree-sitter/tree-sitter-~a" name))
          (grammar-directories '("."))
          (article "a")
          (inputs '())
          (get-cleanup-snippet tree-sitter-delete-generated-files)
          (phases #~%standard-phases)
          (license license:expat))
  "Returns a package for Tree-sitter grammar.  NAME will be used with
tree-sitter- prefix to generate package name and also for generating
REPOSITORY-URL value if it's not specified explicitly, TEXT is a string which
will be used in description and synopsis. GET-CLEANUP-SNIPPET is a function,
it receives GRAMMAR-DIRECTORIES as an argument and should return a G-exp,
which will be used as a snippet in origin. PHASES is a G-exp that can be
used to override the build phases."
  (let* ((multiple? (> (length grammar-directories) 1))
         (grammar-names (string-append text " grammar" (if multiple? "s" "")))
         (synopsis (string-append "Tree-sitter " grammar-names))
         (description
          (string-append "This package provides "
                         (if multiple? "" article) (if multiple? "" " ")
                         grammar-names " for the Tree-sitter library."))
         (name (string-append "tree-sitter-" name)))
    (package
      (name name)
      (version version)
      (home-page repository-url)
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url repository-url)
                      (commit commit)))
                (file-name (git-file-name name version))
                (sha256 (base32 hash))
                (snippet
                 (get-cleanup-snippet grammar-directories))))
      (build-system tree-sitter-build-system)
      (arguments (list #:grammar-directories grammar-directories
                       #:phases phases))
      (inputs inputs)
      (synopsis synopsis)
      (description description)
      (license license))))

(define-public tree-sitter-html
  (tree-sitter-grammar
   "html" "HTML"
   "0slhrmwcw2xax4ylyaykx4libkzlaz2lis8x8jmn6b3hbdxlrpix"
   "0.23.2"))

(define-public tree-sitter-javascript
  ;; Commit required by tree-sitter-typescript 0.20.3.
    (tree-sitter-grammar
     "javascript" "JavaScript(JSX)"
     "03v1gpr5lnifrk4lns690fviid8p02wn7hfdwp3ynp7lh1cid63a"
     "0.23.1"
     #:get-cleanup-snippet
     (lambda (grammar-directories)
       #~(begin
           (use-modules (guix build utils))
           (delete-file "binding.gyp")
           (delete-file-recursively "bindings")
           (for-each
            (lambda (lang)
              (with-directory-excursion lang
                (delete-file "src/grammar.json")
                (delete-file "src/node-types.json")
                (delete-file "src/parser.c")
                (delete-file-recursively "src/tree_sitter")))
            '#$grammar-directories)))))

(define-public tree-sitter-typescript
  (tree-sitter-grammar
   "typescript" "TypeScript and TSX"
   "0rlhhqp9dv6y0iljb4bf90d89f07zkfnsrxjb6rvw985ibwpjkh9"
   "0.23.2"
   #:inputs (list tree-sitter-javascript)
   #:grammar-directories '("typescript" "tsx")))

(define-public tree-sitter-bibtex
  (let ((commit "ccfd77db0ed799b6c22c214fe9d2937f47bc8b34")
        (revision "0"))
    (tree-sitter-grammar
     "bibtex" "Bibtex"
     "0m7f3dkqbmy8x1bhl11m8f4p6n76wfvh99rp46zrqv39355nw1y2"
     (git-version "0.1.0" revision commit)
     #:repository-url "https://github.com/latex-lsp/tree-sitter-bibtex"
     #:commit commit
     #:license license:expat)))

(define-public tree-sitter-css
  (tree-sitter-grammar
   "css" "CSS"
   "014jrlgi7zfza9g38hsr4vlbi8964i5p7iglaih6qmzaiml7bja2"
   "0.19.0"))

(define-public tree-sitter-c
  (tree-sitter-grammar
   "c" "C"
   "1vw7jd3wrb4vnigfllfmqxa8fwcpvgp1invswizz0grxv249piza"
   "0.23.5"))

(define-public tree-sitter-cpp
  (tree-sitter-grammar
   "cpp" "C++"
   "0sbvvfa718qrjmfr53p8x3q2c19i4vhw0n20106c8mrvpsxm7zml"
   "0.23.4"
   #:inputs (list tree-sitter-c)))

(define-public tree-sitter-cmake
  (tree-sitter-grammar
   "cmake" "CMake"
   "1z49jdachwxwbzrrapskpi2kxq3ydihfj45ab9892gbamfij2zp5"
   "0.4.1"
   #:repository-url "https://github.com/uyha/tree-sitter-cmake"))

(define-public tree-sitter-devicetree
  (tree-sitter-grammar
   "devicetree" "Devicetree"
   "0igkwrlgbwphn8dwj91fy2film2mxz4kjdjnc141kmwi4czglwbq"
   "0.8.0"
   #:repository-url "https://github.com/joelspadin/tree-sitter-devicetree"
   #:license license:expat))

(define-public tree-sitter-elixir
  (tree-sitter-grammar
   "elixir" "Elixir"
   "12i0z8afdzcznn5dzrssr7b7jx4h7wss4xvbh3nz12j6makc7kzl"
   "0.3.4"
   #:phases #~(modify-phases %standard-phases
                (add-after 'unpack 'delete-failing-test
                  (lambda _
                    (delete-file "test/highlight/module.ex"))))
   #:article "an"
   #:repository-url "https://github.com/elixir-lang/tree-sitter-elixir"
   #:license (list license:asl2.0 license:expat)))

(define-public tree-sitter-heex
  (tree-sitter-grammar
   "heex" "Heex"
   "0d0ljmxrvmr8k1wc0hd3qrjzwb31f1jaw6f1glamw1r948dxh9xf"
   "0.8.0"
   #:repository-url "https://github.com/phoenixframework/tree-sitter-heex"))

(define-public tree-sitter-bash
  (tree-sitter-grammar
   "bash" "Bash"
   "01sjympivwhr037c0gdx5fqw8fvzchq4fd4m8wlr8mdw50di0ag2"
   "0.20.4"))

(define-public tree-sitter-c-sharp
  (tree-sitter-grammar
   "c-sharp" "C#"
   "0lijbi5q49g50ji00p2lb45rvd76h07sif3xjl9b31yyxwillr6l"
   "0.20.0"))

(define-public tree-sitter-dockerfile
  (tree-sitter-grammar
   "dockerfile" "Dockerfile"
   "0kf4c4xs5naj8lpcmr3pbdvwj526wl9p6zphxxpimbll7qv6qfnd"
   "0.1.2"
   #:repository-url "https://github.com/camdencheek/tree-sitter-dockerfile"))

(define-public tree-sitter-erlang
  (let ((version "0.12.0") ; In Cargo.toml, but untagged
        (commit "370cea629eb62a8686504b9fb3252a5e1ae55313")
        (revision "0"))
  (tree-sitter-grammar
   "erlang" "Erlang"
   "01if10jrnmjdp8ksyrlypmr6g0ybm8pj4fqkhbwcma2xmyabj684"
   (git-version version revision commit)
   #:phases #~(modify-phases %standard-phases
                (add-before 'check 'delete-highlight-tests
                  (lambda _
                    (delete-file-recursively "test/highlight"))))
   #:repository-url "https://github.com/WhatsApp/tree-sitter-erlang"
   #:commit commit)))

(define-public tree-sitter-elm
  (let ((commit "e34bdc5c512918628b05b48e633f711123204e45")
        (revision "0"))
    (tree-sitter-grammar
     "elm" "Elm"
     "06lpq26c9pzx9nd7d9hvn93islp3fhsyr33ipja65zyn9r1di99c"
     (git-version "5.7.0" revision commit)
     #:phases #~(modify-phases %standard-phases
                  (add-before 'check 'delete-failing-test
                    (lambda _
                      (delete-file-recursively "test/highlight")
                      (delete-file "test/corpus/incomplete.txt"))))
     #:article "an"
     #:repository-url "https://github.com/elm-tooling/tree-sitter-elm"
     #:commit commit)))

(define-public tree-sitter-gomod
  (tree-sitter-grammar
   "gomod" "Go .mod"
   "1hblbi2bs4hlil703myqhvvq2y1x41rc3w903hg2bhbazh7x8yyf"
   "1.0.0"
   #:repository-url "https://github.com/camdencheek/tree-sitter-go-mod.git"))

(define-public tree-sitter-go
  (tree-sitter-grammar
   "go" "Go"
   "0wlhwcdlaj74japyn8wjza0fbwckqwbqv8iyyqdk0a5jf047rdqv"
   "0.20.0"))

(define-public tree-sitter-haskell
  (tree-sitter-grammar
   "haskell" "Haskell"
   "0gpdv2w82w6qikp19ma2v916jg5ksh9i26q0lnd3bgbqnllif23f"
   "0.23.1"))

(define-public tree-sitter-hcl
  (tree-sitter-grammar
   "hcl" "HCL"
   "1yydi61jki7xpabi0aq6ykz4w4cya15g8rp34apb6qq9hm4lm9di"
   "1.1.0"
   #:article "an"
   #:repository-url "https://github.com/tree-sitter-grammars/tree-sitter-hcl"
   #:license license:asl2.0))

(define-public tree-sitter-java
  (tree-sitter-grammar
   "java" "Java"
   "0440xh8x8rkbdlc1f1ail9wzl4583l29ic43x9lzl8290bm64q5l"
   "0.20.1"))

(define-public tree-sitter-json
  ;; Not tagged
  (let ((commit "5d992d9dd42d533aa25618b3a0588f4375adf9f3"))
    (tree-sitter-grammar
     "json" "JSON"
     "08kxzqyyl900al8mc0bwigxlkzsh2f14qzjyb5ki7506myxlmnql"
     "0.20.0"
     #:commit commit)))

(define-public tree-sitter-julia
  (tree-sitter-grammar
   "julia" "Julia"
   "1pbnmvhy2gq4vg1b0sjzmjm4s2gsgdjh7h01yj8qrrqbcl29c463"
   "0.19.0"))

(define-public tree-sitter-kdl
  (tree-sitter-grammar
   "kdl" "KDL"
   "1015x24ffrvzb0m0wbqdzmaqavpnjw0gvcagxi9b6vj3n1ynm0ps"
   "1.1.0"
   #:repository-url "https://github.com/tree-sitter-grammars/tree-sitter-kdl"))

(define-public tree-sitter-ocaml
  (tree-sitter-grammar
   "ocaml" "OCaml (.ml and .mli)"
   "021vnbpzzb4cca3ncd4qhzy583vynhndn3qhwayxrpgdl61m44i6"
   "0.20.1"
   #:grammar-directories '("ocaml" "interface")))

(define-public tree-sitter-php
  ;; There are a lot of additions, the last tag was placed more than 1 year ago
  (let ((commit "f860e598194f4a71747f91789bf536b393ad4a56")
        (revision "0"))
    (tree-sitter-grammar
     "php" "PHP"
     "02yc5b3qps8ghsmy4b5m5kldyr5pnqz9yw663v13pnz92r84k14g"
     (git-version "0.19.0" revision commit)
     #:commit commit)))

(define-public tree-sitter-prisma
  (tree-sitter-grammar
   "prisma" "Prisma"
   "19zb3dkwp2kpyivygqxk8yph0jpl7hn9zzcry15mshn2n0rs9sih"
   "1.4.0"
   #:repository-url "https://github.com/victorhqc/tree-sitter-prisma"
   #:license license:expat))

(define-public tree-sitter-python
  (tree-sitter-grammar
   "python" "Python"
   "1sxz3npk3mq86abcnghfjs38nzahx7nrn3wdh8f8940hy71d0pvi"
   "0.20.4"))

(define-public tree-sitter-r
  ;; No tags
  (let ((commit "80efda55672d1293aa738f956c7ae384ecdc31b4")
        (revision "0"))
    (tree-sitter-grammar
     "r" "R"
     "1n7yxi2wf9xj8snw0b85a5w40vhf7x1pwirnwfk78ilr6hhz4ix9"
     (git-version "0.0.1" revision commit)
     #:commit commit)))

(define-public tree-sitter-ron
  (tree-sitter-grammar
   "ron" "RON"
   "1la5v0nig3xp1z2v3sj36hb7wkkjch46dmxf457px7ly43x4cb83"
   "0.2.0"
   #:repository-url "https://github.com/tree-sitter-grammars/tree-sitter-ron"
   #:license (list license:asl2.0 license:expat)))

(define-public tree-sitter-ruby
  ;; There are a lot of additions, the last tag was placed more than 1 year ago
  (let ((commit "206c7077164372c596ffa8eaadb9435c28941364")
        (revision "0"))
    (tree-sitter-grammar
     "ruby" "Ruby"
     "1pqr24bj68lgi1w2cblr8asfby681l3032jrppq4n9x5zm23fi6n"
     (git-version "0.19.0" revision commit)
     #:commit commit)))

(define-public tree-sitter-rust
  (tree-sitter-grammar
   "rust" "Rust"
   "1pk4mb3gh62xk0qlhxa8ihhxvnf7grrcchwg2xv99yy6yb3yh26b"
   "0.20.4"))

(define-public tree-sitter-ungrammar
  ;; No releases yet.
  (let ((commit "debd26fed283d80456ebafa33a06957b0c52e451")
        (revision "0"))
    (tree-sitter-grammar
     "ungrammar" "Ungrammar"
     "09bbml1v1m6a9s9y9q1p2264ghf3fhb6kca1vj3qm19yq87xrnvy"
     (git-version "0.0.2" revision commit)
     #:commit commit
     #:repository-url "https://github.com/tree-sitter-grammars/tree-sitter-ungrammar"
     #:article "an")))

(define-public tree-sitter-clojure
  (tree-sitter-grammar
   "clojure" "Clojure"
   "1j41ba48sid6blnfzn6s9vsl829qxd86lr6yyrnl95m42x8q5cx4"
   "0.0.13"
   #:repository-url "https://github.com/sogaiu/tree-sitter-clojure"
   #:get-cleanup-snippet
   (lambda (grammar-directories)
     #~(begin
         (use-modules (guix build utils))
         (for-each
          (lambda (lang)
            (with-directory-excursion lang
              (delete-file "src/grammar.json")
              (delete-file "src/node-types.json")
              (delete-file "src/parser.c")
              (delete-file-recursively "src/tree_sitter")))
          '#$grammar-directories)))))

(define-public tree-sitter-markdown
  ;; No tags
  (let ((commit "ef3caf83663ea97ad9e88d891424fff6a20d878d")
        (revision "0"))
    (tree-sitter-grammar
     "markdown" "Markdown (CommonMark Spec v0.30)"
     "0p9mxpvkhzsxbndda36zx5ycd6g2r2qs60gpx4y56p10lhgzlyqj"
     "0.1.1"
     #:repository-url "https://github.com/MDeiml/tree-sitter-markdown"
     #:grammar-directories '("tree-sitter-markdown"
                             "tree-sitter-markdown-inline")
     #:commit commit)))

(define-public tree-sitter-markdown-gfm
  ;; Not updated for more than 1 year, can be deprecated when gfm will be
  ;; implemented in tree-sitter-markdown
  (tree-sitter-grammar
   "markdown-gfm" "Markdown (CommonMark Spec v0.29-gfm)"
   "1a2899x7i6dgbsrf13qzmh133hgfrlvmjsr3bbpffi1ixw1h7azk"
   "0.7.1"
   #:repository-url "https://github.com/ikatyang/tree-sitter-markdown"))

(define-public tree-sitter-matlab
  (let ((commit "79d8b25f57b48f83ae1333aff6723b83c9532e37")
        (revision "0"))
    (tree-sitter-grammar
     "matlab" "Matlab"
     "04ffhfnznskkcp91fbnv8jy3wkb9cd8ifwrkrdwcw74n1b2hq80c"
     (git-version "1.0.2" revision commit)
     #:repository-url "https://github.com/acristoffers/tree-sitter-matlab"
     #:commit commit
     #:license license:expat)))

(define-public tree-sitter-meson
  ;; tag 1.2 is Aug 24,2022  this commit is Feb 28,2023
  (let ((commit "3d6dfbdb2432603bc84ca7dc009bb39ed9a8a7b1")
        (revision "0"))
    (tree-sitter-grammar
     "meson" "Meson"
     "1rn7r76h65d41354czyccm59d1j9nzybcrjvjh934lpr59qrw61m"
     (git-version "1.2" revision commit)
     #:repository-url "https://github.com/Decodetalkers/tree-sitter-meson"
     #:commit commit
     #:license license:expat)))

(define-public tree-sitter-nix
  (tree-sitter-grammar
   "nix" "Nix"
   "0nn3ij8k6wkbf3kcvkyyp0vhfjcksi31wyyfwmsbx66maf2xgaii"
   "0.0.0"
   ;; The most recent commit at time of packaging, no tags.
   #:commit "763168fa916a333a459434f1424b5d30645f015d"
   #:repository-url "https://github.com/nix-community/tree-sitter-nix"))

(define-public tree-sitter-org
  ;; There are a lot of additions, the last tag was placed a while ago
  (let ((commit "081179c52b3e8175af62b9b91dc099d010c38770")
        (revision "0"))
    (tree-sitter-grammar
     "org" "Org"
     "0h9krbaq9j6ijf86sg0w221s0zbpbx5f7m1l0whzjahbrqpnqgxl"
     (git-version "1.3.1" revision commit)
     #:repository-url "https://github.com/milisims/tree-sitter-org"
     #:commit commit)))

(define-public tree-sitter-scheme
  ;; There are a lot of additions, the last tag was placed a while ago
  (let ((commit "67b90a365bebf4406af4e5a546d6336de787e135")
        (revision "0"))
    (tree-sitter-grammar
     "scheme" "Scheme (R5RS, R6RS)"
     "1pvxckza1kdfwqs78ka3lbwldrwkgymb31f5x1fq5vyawg60wxk8"
     (git-version "0.2.0" revision commit)
     #:repository-url "https://github.com/6cdh/tree-sitter-scheme"
     #:commit commit)))

(define-public tree-sitter-sway
  (tree-sitter-grammar
   "sway" "Sway"
   "016zq8jbyy0274qyr38f6kvvllzgni0w7742vlbkmpv8d2blr7xj"
   "1.0.0"
   #:repository-url "https://github.com/FuelLabs/tree-sitter-sway"))

(define-public tree-sitter-racket
  ;; No tags
  (let ((commit "1a5df0206b25a05cb1b35a68d2105fc7493df39b")
        (revision "0"))
    (tree-sitter-grammar
     "racket" "Racket"
     "06gwn3i7swhkvbkgxjlljdjgvx8y1afafbqmpwya70r9z635593h"
     (git-version "0.1.0" revision commit)
     #:repository-url "https://github.com/6cdh/tree-sitter-racket"
     #:commit commit)))

(define-public tree-sitter-plantuml
  ;; No tags
  (let ((commit "bea443ef909484938cb0a9176ebda7b8a3d108f7")
        (revision "0"))
    (tree-sitter-grammar
     "plantuml" "PlantUML"
     "0swqq4blhlvvgrvsb0h4cjl3pnfmmdpfd5r5kg9rpdwk0sn98x3a"
     (git-version "1.0.0" revision commit)
     #:repository-url "https://github.com/Decodetalkers/tree_sitter_plantuml"
     #:commit commit
     #:get-cleanup-snippet
     (lambda _
       #~(begin
           (use-modules (guix build utils))
           (delete-file "binding.gyp")
           (delete-file-recursively "bindings"))))))

(define-public tree-sitter-latex
  (tree-sitter-grammar
   "latex" "LaTeX"
   "0lc42x604f04x3kkp88vyqa5dx90wqyisiwl7nn861lyxl6phjnf"
   "0.3.0"
   #:repository-url "https://github.com/latex-lsp/tree-sitter-latex"))

(define-public tree-sitter-lua
  (tree-sitter-grammar
   "lua" "Lua"
   "05irhg6gg11r9cnzh0h3691pnxjhd396sa1x8xrgqjz2fd09brf3"
   "0.0.19"
   #:repository-url "https://github.com/MunifTanjim/tree-sitter-lua"))

(define-public tree-sitter-scala
  (tree-sitter-grammar
   "scala" "Scala"
   "0hs6gmkq5cx9qrmgfz1mh0c34flwffc0k2mhwf13laawswnywfkz"
   "0.20.2"))

(define-public tree-sitter-tlaplus
  (tree-sitter-grammar
   "tlaplus" "TLA+"
   "1k60dnzafj6m9c2d4xnwiz3d7yw3bg3iwx7c1anhwr76iyxdci3w"
   "1.0.8"
   ;; Version 1.2.1 is most recent, but requires tree-sitter >0.21.0
   #:repository-url "https://github.com/tlaplus-community/tree-sitter-tlaplus"))

(define-public tree-sitter-kotlin
  (tree-sitter-grammar
   "kotlin" "Kotlin"
   "0lqwjg778xy561hhf90c9m8zdjmv58z5kxgy0cjgys4xqsfbfri6"
   "0.3.6"
   #:repository-url "https://github.com/fwcd/tree-sitter-kotlin"
   #:commit "0.3.6"))

(define-public tree-sitter-awk
  (tree-sitter-grammar
   "awk" "AWK"
   "1far60pxkqfrxi85hhn811g2r7vhnzdvfp5piy89fmpxk33s4vmi"
   ;; Version 0.7.1 would be most recent, but would require tree-sitter >= 0.21.0.
   "0.6.2"
   #:repository-url "https://github.com/Beaglefoot/tree-sitter-awk"))

(define-public tree-sitter-verilog
  (let ((version "1.0.0") ; In package.json, but untagged
        (commit "075ebfc84543675f12e79a955f79d717772dcef3")
        (revision "0"))
    (tree-sitter-grammar
     "verilog" "Verilog"
     "0j5iycqm5dmvzy7dssm8km1djhr7hnfgk26zyzcxanhrwwq3wi4k"
     (git-version version revision commit)
     #:commit commit
     #:get-cleanup-snippet
     (lambda _
       #~(begin
           (use-modules (guix build utils))
           (delete-file "binding.gyp")
           (delete-file-recursively "bindings"))))))

(define-public tree-sitter-vhdl
  (let ((version "0.1.1") ; In package.json, but untagged
        (commit "a3b2d84990527c7f8f4ae219c332c00c33d2d8e5")
        (revision "0"))
    (tree-sitter-grammar
     "vhdl" "VHDL"
     "0gz2b0qg1jzi2q6wgj6k6g35kmni3pqglq4f5kblkxx909463n8a"
     (git-version version revision commit)
     #:repository-url "https://github.com/alemuller/tree-sitter-vhdl"
     #:commit commit
     #:get-cleanup-snippet
     (lambda _
       #~(begin
           (use-modules (guix build utils))
           (delete-file "binding.gyp")
           ;; tree-sitter-vhdl does not have bindings/ directory.
           (delete-file "src/grammar.json")
           (delete-file "src/node-types.json")
           (delete-file "src/parser.c")
           (delete-file-recursively "src/tree_sitter")
           ;; Fix a query error in the highlight.scm query test. This would be
           ;; easier with a patch, but this works too, and we still get to use
           ;; tree-sitter-grammar. The fix is taken from here:
           ;; https://github.com/n8tlarsen/tree-sitter-vhdl/commit/dabf157c6bb7220d72d3ceba0ce1abd90bf62187
           ;; This is a documented issue that has not been resolved for nearly 2
           ;; years.
           ;; https://github.com/alemuller/tree-sitter-vhdl/issues/2
           (substitute* "queries/highlights.scm"
             (("\\(integer_decimal\n") "(integer_decimal)\n")
             (("\\(integer\\)") "")
             (("\"0\")") "\"0\"")))))))

(define-public python-tree-sitter-c-sharp
  (package
    (name "python-tree-sitter-c-sharp")
    (version "0.23.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/tree-sitter/tree-sitter-c-sharp.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0w6xdb8m38brhin0bmqsdqggdl95xqs3lbwq7azm5gg94agz9qf1"))))
    (build-system pyproject-build-system)
    (native-inputs (list python-setuptools python-wheel))
    (inputs (list tree-sitter))
    (home-page #f)
    (synopsis "C# grammar for tree-sitter")
    (description "C# grammar for tree-sitter.")
    (license license:expat)))

(define-public python-tree-sitter-embedded-template
  (package
    (name "python-tree-sitter-embedded-template")
    (version "0.23.2")
    (source
     (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://github.com/tree-sitter/tree-sitter-embedded-template.git")
         (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1vq9dywd9vcy59f6i5mk5n7vwk67g8j5x77czg7avpznskgfhqhb"))))
    (build-system pyproject-build-system)
    (native-inputs (list python-setuptools python-wheel))
    (inputs (list tree-sitter))
    (home-page #f)
    (synopsis "Embedded Template (ERB, EJS) grammar for tree-sitter")
    (description "Embedded Template (ERB, EJS) grammar for tree-sitter.")
    (license license:expat)))

(define-public python-tree-sitter-yaml
  (package
    (name "python-tree-sitter-yaml")
    (version "0.7.0")
    (source
     (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://github.com/tree-sitter-grammars/tree-sitter-yaml.git")
         (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0z5fz9hiafzapi0ijhyz8np6rksq6c1pb16xv1vhnlfh75rg6zyv"))))
    (build-system pyproject-build-system)
    (native-inputs (list python-setuptools python-wheel))
    (home-page #f)
    (synopsis "YAML grammar for tree-sitter")
    (description "YAML grammar for tree-sitter.")
    (license license:expat)))

;; TODO: Unbundle the prebuilt parsers.
(define-public python-tree-sitter-language-pack
  (package
    (name "python-tree-sitter-language-pack")
    (version "0.6.1")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "tree_sitter_language_pack" version))
       (sha256
        (base32 "1f826jb7sikd7rsr92y8c3b4jaf8byifmr01v5i2ar4vdddmyqx4"))))
    (build-system pyproject-build-system)
    (propagated-inputs (list python-tree-sitter python-tree-sitter-c-sharp
                             python-tree-sitter-embedded-template
                             python-tree-sitter-yaml))
    (native-inputs (list python-cython python-setuptools
                         python-typing-extensions python-wheel))
    (home-page #f)
    (synopsis "Extensive Language Pack for Tree-Sitter")
    (description "Extensive Language Pack for Tree-Sitter.")
    (license #f)))
