# Building documentation

This file describe how to build the MMD specification documentation.

## Install Asciidoctor

You need to install these asciidoctor tools to build the documentation.
If you do not have asciidoctor installed, run the following commands.

```
gem install asciidoctor
```

```
gem install --pre asciidoctor-pdf
```

## Building the documentation
To build the documentation run the following commands.
```
asciidoctor -B doc/ doc/mmd-specification.adoc
```

```
asciidoctor-pdf -B doc/ -D doc/ doc/mmd-specification.adoc 
```

