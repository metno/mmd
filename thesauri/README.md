## Thesauri

This folder contains different RDF representations that are used within the MMD repository.

### mmd-thesauri

These files contain the SKOS representation of all the Concepts that are valid entries for MMD.
The turtle file is use to populate the METNO Vocabulary Service (https://vocab.met.no).

The Organisation Collection does not represent all the valid entries for Organisations in MMD, but it is just used to
support standardisations of names during the creations of MMD or to provide enriched information in the metadata
catalogues based on MMD. The Collection is created for internal purposes and it is not intended to be the authoritative
source of information for Organisations.

### nasjonal-temainndeling.rdf

This is a local copy of the (Norwegian) National topic category, i.e. the overall categorization of spatial data in Norway.
The file is used in the xslt translation sheets to map Concepts and corresponding URI.

### theme.en.rdf

This is a local copy of the INSPIRE theme register (https://inspire.ec.europa.eu/theme). The file is used in the xslt
translation to map Concepts and corresponding URI.


