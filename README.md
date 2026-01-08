![html/pdf](https://github.com/metno/mmd/workflows/html/pdf/badge.svg)

# MET Norway Metadata Format (MMD)

## Background
Specification of the MET Norway discovery and configuration metadata
standard. This is compatible with ISO19115 (various profiles), DataCite
and GCMD DIF.

## Content

The repository contains the specifications and related tools for the MMD standard.

- the xsd folder contains xsd schemas
- the doc folder contains the MMD documentation
- the xslt folder contains XSLT translation sheets
- the thesauri folder contains MMD and external controlled vocabularies
- the bin folder contains some executable scripts, some based on the tools in the mmd_utils folder
- the mmd_utils folder contains MMD related tools
- the mapping folder contains mapping between MMD and metadata standards.
- the input-examples folder contains some examples of metadata records
- the test folder contains some tests (see below)

The latest version of the mmd specification is available [here](https://htmlpreview.github.io/?https://github.com/metno/mmd/blob/master/doc/mmd-specification.html).

## Automatically generated content
The schema enumeration xsd/enum_mmd.xsd and the controlled vocabularies table within the documentation doc/ch04-md-contrvocabs.adoc are automatically built from the
content of the thesauri folder (mmd-vocabulary.ttl) through the xsd/create_enum.py. These two files MUST NOT be changed or edited as they will be ovewritten when the
script is running. Any changes to the vocabularies should be done updating the mmd-vocabulary.ttl file.

## How to build documentation
Documentation was originally provided in OpenDocumentFormat. This became
to difficult to maintain in a collaborative environment and it is now
moved to ASCIIDOC following the example outlined by the Climate and
Forecast convention community.

In order to build the documentation use the following command

### HTML:
```
asciidoctor -n mmd-specification.adoc
```

### PDF:
```
asciidoctor-pdf -a pdf-themesdir=./ -a pdf-theme=mmd -n mmd-specification.adoc
```

## Note on testing

All code should be tested (100% test coverage), i.e.,

- New functionality must be accompanied with a test suite
- Tests should be both positive (testing that the function work as intended with valid data) and negative (testing that the function behaves as expected with invalid data, e.g., that correct exceptions are thrown)
- If a function has optional arguments, separate tests for all options should be created
- Examples should be supported by doctests

Badges at the top of this README indicate if tests are passing, and the actual test coverage.

## Licenses
GPL 3 or higher for software, Creative Commons BY for documents.
