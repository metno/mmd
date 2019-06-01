#!/bin/bash

# demo

usage()
{
    cat << EOF
usage: $0 <xsldir>
Generate a set of MMD examples into ./out from the stylesheets in xsldir.
EOF
    exit 1
}

xsl="$1"

if [ ! -d "$xsl" ]
then
    usage
fi

rm -rf out
mkdir out

for f in input-examples/*.iso
do
    xsltproc -o out"${f/input-examples/}".mmd $xsl/iso-to-mmd.xsl $f
done

for f in input-examples/*.dif
do
    xsltproc -o out"${f/input-examples/}".mmd $xsl/dif-to-mmd.xsl $f
done

for f in input-examples/*.ncml
do
    xsltproc -o out"${f/input-examples/}".mmd $xsl/nc-to-mmd.xsl $f
done

for f in input-examples/*.nc
do
    ncdump -x $f | xsltproc -o out"${f/input-examples/}".mmd $xsl/nc-to-mmd.xsl -
done

for f in input-examples/*.mm2
do
    base=`basename $f .mm2`
    #echo all your base is belong to $base
    xsltproc -o out"${f/input-examples/}".mmd --stringparam xmd "../input-examples/$base.xmd" $xsl/mm2-to-mmd.xsl $f
done

for f in input-examples/*.mmd
do
    xsltproc -o out"${f/input-examples/}".dif $xsl/mmd-to-dif.xsl $f
done

