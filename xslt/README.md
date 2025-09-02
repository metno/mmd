##  XSLT transformtaion sheets

This folder contains XLST (Extensible Stylesheet Language Transformations) transformation sheets to convert metadata records from/to different schemas.
These transformation sheets are integrated with the services built on top of the MMD specifications and include, when possible, integration with the controlled lists
defined in the [thesauri folder](../thesauri/).

The transformations from MMD are used to translate the MMD records to international standards, while the transformations to MMD are used to translate harvested records
from international standards to MMD.

### From MMD

- DIF10: mmd-to-dif10.xsl
- DIF9: mmd-to-dif.xsl
- DCAT: mmd-to-dcatap.xsl
- ISO Inspire: mmd-to-inspire.xsl
- Norwegian Profile ISO Inspire: mmd-to-NOiso.xsl
- ISO 19115-1: mmd-to-iso.xsl
- ISO 19115-2: mmd-to-iso2.xsl
- DATACITE: mmd-to-datacite.xsl
- Norwegian Profile ISO Inspire (MET Specific): mmd-to-geonorge.xsl
- WMO Core Metadata Profile (WCMP): mmd-to-wmo.xsl

### To MMD

- ISO 19115: iso-to-mmd.xsl
- DIF: dif-to-mmd.xsl
- DCAT: dcat-to-mmd.xsl
- EML: eml-to-mmd.xsl

### Additional XLST sheets

- mmd-to-mm2.xsl
- mmd2sequence.xsl
- sort_mmd_according_to_xsd.xsl
- nc-to-mmd.xsl
- gcmd-kw2mmd.xml
- mmdv2-to-mmdv3.xsl
- mm2-to-mmd.xsl
- mdform-to-mmd.xsl
- mdformsplit.xslt
- ecmwf-iso-to-mmd.xsl

### How to convert

To use XSLT sheets to convert from/to different standards provided in this folder use:

```
xsltproc <XSLT sheet> input.xml > output.xml
```

or use the script in the transformrecord [bin](../bin/) folder:

```
./transformrecord <XSLT sheet> input.xml
```