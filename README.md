![html/pdf](https://github.com/mortenwh/mmd/workflows/html/pdf/badge.svg)
![tests](https://github.com/mortenwh/mmd/workflows/tests/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/mortenwh/mmd/badge.svg)](https://coveralls.io/github/mortenwh/mmd)

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

## Scripts (src-folder)

### convert-to-mmd.py
This script convert metadata files from either dif,iso or mm2 to mmd format.
Schema validation is done on input and output documents. Failed validation will
be logged as warnings to stdout.

```
./src/convert-to-mmd.py -i <input file> -f <input format> -o <output file>
```

### convert-from-mmd.py
This script convert metadata files from mmd format to one of [dif,iso,mm2] format.
Schema validation is done on input and output documents. Failed validation
will be logged as warings to stdout.

```
./src/convert-from-mmd.py -i <input file> -f <output format> - o <output file>
```

### createMETUUID.py
This script reads the title and the time of the last metadata update of the
metadata file, and generate UUID for the dataset.

```
./createMETUUID.py -i <input file>
```

add -w to overwrite input file


### checkMMD.py
This script check that the XML file satisfy MMD requirements by means
of the MMD XSD. It also checks that urls in document points to a valid url.

```
./checkMMD.py -i <dataset_name>
```

### nc-to-mmd.py
Script for parsing metadata conent of NetCDF files and create MET Norway Metadata
format specification document (MMD) based on the discovery metadata.
This will work on CF and ACDD compliant files.

```
see main() method in end of script for usage
```

### send-to-geonetwork.pl
Send a list of MMD metadata files to a GeoNetwork instance as ISO19139 metadata.
Read a file with a liost of URLs to MMD metadata files. For each file, convert
the file to ISO19139 and then send it to the GeoNetwork instance.

```
./send-to-geonetwork.pl <file with metadata file urls> <tmp directory>
```

## How to build documentation
Documentation was originally provided in OpenDocumentFormat. This became
to difficult to maintain in a collaborative environment and it is now
moved to ASCIIDOC following the example outlined by the Climate and
Forecast convention community.

In order to build the documentation use the following command

### HTML:
```
asciidoctor -n mmd_specification.adoc
```

### PDF:
```
asciidoctor-pdf -a pdf-themesdir=./ -a pdf-theme=mmd -n mmd_specification.adoc
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
