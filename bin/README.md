## Executables

This folder contains some executable scripts that can be used to check/manipulate MMD files.

### transformrecord

This script transforms metadata records in xml from/to other schemas, using [XSLT sheets](../xslt/)

For example, to translate between MMD and inspire:

```
./transformrecord ../xslt/mmd-to-inspire.xsl input_mmd.xml > output_inspire.xml
```
