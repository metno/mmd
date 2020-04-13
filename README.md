# mmd

## Background
Specification of the MET Norway discovery and configuration metadata
standard. This is compatible with ISO19115 (various profiles), DataCite
and GCMD DIF. 

## Content

The repository contains the MMD standard (in the `xsd` folder), its
documentation (in the `docs` folder), xml-files to handle translation
between various metadata standards and MMD (in the `xslt` folder),
conversion scripts and examples (in the `src` folder), and example
metadata for example datasets (in the `input-examples` folder).

## How to build documentation
Documentation was originally provided in OpenDocumentFormat. This became
to difficult to maintain in a collaborative environment and it is now
moved to ASCIIDOC following the example outlined by the Climate and
Forecast convention community.

In order to build the documentation use the following command

HTML:
    asciidoctor -n mmd-specification.adoc

PDF:
    asciidoctor-pdf -n mmd-specification.adoc
    
## Licenses
GPL 3 or higher for software, Creative Commons BY for documents.
