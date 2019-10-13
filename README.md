# mmd

## Background
Specification of the MET Norway discovery and configuration metadata
standard. This is compatible with ISO19115 (various profiles), DataCite
and GCMD DIF. The repository contains the specification (in doc), the
schema (in xsd) and stylesheets for transformations (in xslt).

## How to build documentation
Documentation was originally provided in OpenDocumentFormat. This became
to difficult to maintain in a collaborative environment and it is now
moved to ASCIIDOC following the example outlined by the Climate and
Forecast convention community.

In order to build the documentation use the following command

HTML:
    asciidoctor -n mmd_specification.adoc

PDF:
    asciidoctor-pdf -n mmd_specification.adoc
