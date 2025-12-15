## Schemas

This folder contains different schemas that relates to the MMD respository and a script to generate the enumeration
of valid controlled vocabulary terms used in MMD.

### Schema enumeration script

The create_enum.py creates the enum_mmd.xsd which is then inclued in the mmd schemas. This script reads the valid terms
from the thesauri folder (mmd-vocabulary.ttl) and generates the list of valid terms in MMD. The enum_mmd.xsd file must
not be edited as it is overwritten by running the script.

In addition, the script generates the doc/ch04-md-contrvocabs.adoc which is included in the MMD documentation.

### MMD

The current folder contains the default MMD schema and its strict profile (MMD strict) as well as xml schema.

### DIF

The dif folder contains the DIF schemas from https://git.earthdata.nasa.gov/scm/emfd/dif-schemas.git
and an additional version of DIF 9 (v9.8.4)

### SOLR

The solr folder contains solr schemas used to configure SolR

### ISO

This folder contains ISO schemas

