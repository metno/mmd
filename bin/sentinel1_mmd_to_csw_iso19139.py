#!/usr/bin/env python3

import lxml.etree as ET
import xmltodict
import pathlib
import os
import parmap
import pathlib
import sys


def xml_check(xml_file):
    if pathlib.Path(xml_file).is_file():
        try:
            xml = ET.parse(xml_file)
            return xml
        except ET.XMLSyntaxError:
            try:
                xml = ET.XML(bytes(bytearray(xml_file, encoding='utf-8')))
                return xml
            except ET.XMLSyntaxError:
                print('error at %s' % xml_file)
                return False
    else:
        print('File: %s, not found' % xml_file)
        return False


def filelist(directory):
    xml_files = []
    for subdir, dirs, files in os.walk(directory):
        for file in files:
            file_path = subdir + os.sep + file
            if file_path.endswith(".xml"):
                xml_files.append(file_path)
    return xml_files


def mmd2iso(mmd_file, xslt):
    try:
        mmd = ET.parse(mmd_file)
    except OSError as e:
        mmd = ET.XML(bytes(bytearray(mmd_file, encoding='utf-8')))
    xslt = ET.parse(xslt)
    transform = ET.XSLT(xslt)
    iso = transform(mmd)
    #return xmltodict.parse(iso)
    return iso


def fixrecord(doc, pretty=False):
    for i, v in enumerate(doc['gmd:MD_Metadata']
                          ['gmd:distributionInfo']
                          ['gmd:MD_Distribution']
                          ['gmd:transferOptions']
                          ['gmd:MD_DigitalTransferOptions']
                          ['gmd:onLine']):
        if v['gmd:CI_OnlineResource']\
                ['gmd:protocol']\
                ['gco:CharacterString']\
                ['#text'] == 'OPeNDAP':
            doc['gmd:MD_Metadata']\
                ['gmd:distributionInfo'] \
                ['gmd:MD_Distribution'] \
                ['gmd:transferOptions'] \
                ['gmd:MD_DigitalTransferOptions'] \
                ['gmd:onLine'] \
                [i] \
                ['gmd:CI_OnlineResource'] \
                ['gmd:linkage'] \
                ['gmd:URL'] = v['gmd:CI_OnlineResource']['gmd:linkage']['gmd:URL'] + '.html'
        if v['gmd:CI_OnlineResource'] \
                ['gmd:protocol'] \
                ['gco:CharacterString'] \
                ['#text'] == 'OGC WMS':
            doc['gmd:MD_Metadata'] \
                ['gmd:distributionInfo'] \
                ['gmd:MD_Distribution'] \
                ['gmd:transferOptions'] \
                ['gmd:MD_DigitalTransferOptions'] \
                ['gmd:onLine'][i]['gmd:CI_OnlineResource'] \
                ['gmd:protocol'] \
                ['gco:CharacterString'] \
                ['#text'] = 'OGC:WMS'
            doc['gmd:MD_Metadata'] \
                ['gmd:distributionInfo'] \
                ['gmd:MD_Distribution'] \
                ['gmd:transferOptions'] \
                ['gmd:MD_DigitalTransferOptions'] \
                ['gmd:onLine'][i]['gmd:CI_OnlineResource'] \
                ['gmd:description'] \
                ['gco:CharacterString'] \
                ['#text'] = 'OGC:WMS'
            if doc['gmd:MD_Metadata'] \
                       ['gmd:fileIdentifier'] \
                       ['gco:CharacterString'] \
                       ['#text'][:3] == 'S2A':
                doc['gmd:MD_Metadata'] \
                    ['gmd:distributionInfo'] \
                    ['gmd:MD_Distribution'] \
                    ['gmd:transferOptions'] \
                    ['gmd:MD_DigitalTransferOptions'] \
                    ['gmd:onLine'] \
                    [i] \
                    ['gmd:CI_OnlineResource'] \
                    ['gmd:linkage']['gmd:URL'] = v['gmd:CI_OnlineResource'] \
                                                     ['gmd:linkage'] \
                                                     ['gmd:URL'].replace('http://nbswms.met.no/thredds/wms/',
                                                                         'http://nbswms.met.no/thredds/wms_jpeg/') \
                                                 + "?SERVICE=WMS&amp;REQUEST=GetCapabilities"
            if doc['gmd:MD_Metadata'] \
                       ['gmd:fileIdentifier'] \
                       ['gco:CharacterString'] \
                       ['#text'][:3] in ['S1A', 'S1B', 'S2B']:
                doc['gmd:MD_Metadata'] \
                    ['gmd:distributionInfo'] \
                    ['gmd:MD_Distribution'] \
                    ['gmd:transferOptions'] \
                    ['gmd:MD_DigitalTransferOptions'] \
                    ['gmd:onLine'] \
                    [i] \
                    ['gmd:CI_OnlineResource'] \
                    ['gmd:linkage']['gmd:URL'] = v['gmd:CI_OnlineResource'] \
                                                     ['gmd:linkage'] \
                                                     ['gmd:URL'] + "?SERVICE=WMS&amp;REQUEST=GetCapabilities"
    return xmltodict.unparse(doc, pretty=pretty)


def writerecord(inputfile, outdir='/tmp'):
    pathlib.Path(outdir).mkdir(parents=True, exist_ok=True)
    xslt_file = os.path.join(os.getenv('XSLTPATH'), 'mmd-to-iso.xsl')
    if not os.path.isfile(xslt_file):
        raise Exception('XSLT file is missing')
    iso_xml = mmd2iso(inputfile, xslt_file)
    outputfile = pathlib.PurePosixPath(outdir).joinpath(pathlib.PurePosixPath(inputfile).name)
    iso_xml.write_output(str(outputfile))
    #with open(outputfile, 'w') as isofix:
        #isofix.write(fixrecord(iso_xml, pretty=True))
        #isofix.write(xmltodict.unparse(iso_xml, pretty=True))
        #isofix.write(iso_xml)


def main(metadata, outdir):
    xmlfiles = filelist(metadata)
    #y = parmap.map(writerecord, xmlfiles, outdir=outdir, pm_pbar=False)
    for e in xmlfiles:
        writerecord(e, outdir=outdir)



import argparse

def parse_arguments():
    parser = argparse.ArgumentParser(description='Convert mmd xml files to ISO')
    parser.add_argument("-i", "--input-dir", help="directory with input MMD")
    parser.add_argument("-o", "--output-dir", help="outpout directory with ISO")
    args = parser.parse_args()
    return args


if __name__ == '__main__':
    args = parse_arguments()
    main(metadata=args.input_dir, outdir=args.output_dir)
