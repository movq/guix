;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2021 Maxim Cournoyer <maxim.cournoyer@gmail.com>
;;; Copyright © 2024 Sharlatan Hellseher <sharlatanus@gmail.com>
;;; Copyright © 2024 Artyom V. Poptsov <poptsov.artyom@gmail.com>
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

(define-module (gnu packages patool)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix build-system pyproject)
  #:use-module (gnu packages)
  #:use-module (gnu packages backup)
  #:use-module (gnu packages cdrom)
  #:use-module (gnu packages check)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cpio)
  #:use-module (gnu packages debian)
  #:use-module (gnu packages file)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages xiph))

(define-public patool
  (package
    (name "patool")
    (version "3.1.0")
    (source
     (origin
       (method git-fetch)               ;no test data in PyPI archive
       (uri (git-reference
             (url "https://github.com/wummel/patool")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1w20kiiq9ngy90lcgnjfjiwbp6zvf3vlhm34700ff8x85x9fknkr"))))
    (build-system pyproject-build-system)
    (native-inputs
     (list bzip2
           cabextract
           cdrtools
           clzip
           cpio
           dpkg
           file
           flac
           lhasa
           libarchive ;for bsdtar
           lrzip
           lzip
           lzop
           p7zip
           pbzip2
           pigz
           plzip
           python-pytest
           python-setuptools
           python-wheel
           rpm))
    (home-page "https://wummel.github.io/patool/")
    (synopsis "Portable archive file manager")
    (description "Patool provides a unified command line interface for a
plethora of archivers.  It supports the following archive formats natively:
@itemize
@item TAR (.tar, .cbt)
@item BZIP2 (.bz2)
@item GZIP (.gz)
@item ZIP (zip, .jar, .cbz).
@end itemize
The archive formats below are also supported as long as the corresponding
compressor or archiver commands are available:
@itemize
@item 7z (.7z, .cb7)
@item ACE (.ace, .cba)
@item ADF (.adf)
@item ALZIP (.alz)
@item APE (.ape)
@item AR (.a)
@item ARC (.arc)
@item ARJ (.arj)
@item CAB (.cab)
@item COMPRESS (.Z)
@item CPIO (.cpio)
@item DEB (.deb)
@item DMS (.dms)
@item FLAC (.flac)
@item GZIP (.gz)
@item ISO (.iso)
@item LRZIP (.lrz)
@item LZH (.lha, .lzh)
@item LZIP (.lz)
@item LZMA (.lzma)
@item LZOP (.lzo)
@item RPM (.rpm)
@item RAR (.rar, .cbr)
@item RZIP (.rz)
@item SHN (.shn)
@item TAR (.tar, .cbt)
@item XZ (.xz)
@item ZOO (.zoo).
@end itemize")
    (license license:gpl3+)))
