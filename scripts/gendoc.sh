#/bin/bash
# Generate asciidoctor documentation
# Need to be run from same dir as script.
asciidoctor -B ../doc/ ../doc/mmd-specification.adoc
asciidoctor-pdf -B ../doc/ -D ../doc/ ../doc/mmd-specification.adoc 
