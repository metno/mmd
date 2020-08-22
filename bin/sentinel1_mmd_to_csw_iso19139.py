#!/usr/bin/env python

import lxml.etree as ET
import xmltodict
import pathlib
import os
import parmap
import pathlib
import sys


def xml_check(xml_file):
    """[validate xml syntax from filepath]

    Args:
        xml_file ([str]): [filepath to an xml file]

    Returns:
        [bool]: [return True if a valid xml filepath is provided, 
        return False if the xmlfile is invalid, or doesn't exist ]
    """
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
    """[return xml filelist from directory-path]

    Args:
        directory ([str]): [path to a directory]

    Returns:
        [list]: [return a list of path to xml files contained in the input directory]
    """
    xml_files = []
    for subdir, dirs, files in os.walk(directory):
        for file in files:
            file_path = subdir + os.sep + file
            if file_path.endswith(".xml"):
                xml_files.append(file_path)
    return xml_files


def mmd2iso(mmd_file, xslt):
    """[transform mmd xml_file contents to its iso represenation transformed using the given xslt file]

    Args:
        mmd_file ([str]): [path to a mmd xml file]
        xslt ([str]): [path to a mmd xslt file]

    Returns:
        [dict]: [return a dictionary iso representation of the given mmd xml file]
    """    
    try:
        mmd = ET.parse(mmd_file)
    except OSError as e:
        mmd = ET.XML(bytes(bytearray(mmd_file, encoding='utf-8')))
    xslt = ET.parse(xslt)
    transform = ET.XSLT(xslt)
    iso = transform(mmd)
    return xmltodict.parse(iso)


def fixrecord(doc, pretty=False):
    """[ takes a dict of iso records and fixes some of its values to allow CSW  to consume the metadata resources 
        - add .html extension to the opendap link # <-- note this should be removed - add a new value pointing to the opendap html landing page instead 
        - change the online resource protocol to be 'OGC:WMS' instead of 'OGC WMS']
        - fix WMS getcapabilities for S2A (Sentinel 2 A) products :
            -- replace 'wms' to 'wms_jpeg'
            -- complete the getcapabilities url string
        - fix WMS getcapabilities for S1A, S1B, S2B products : 
            -- complete the getcapabilities url string
    Args:
        doc ([dict]): [dict representing the xml iso record]

    Returns:
        [str]: [xml iso string]
    """  
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


def writerecord(inputfile, xsl='../xslt/mmd-to-iso.xsl', outdir='/tmp'):
    """[transform an mmd file to its iso representation by apply the fixes described in fixrecord,  write the output as xml 
        NOTE: this code applies only to mmd xml file related to the sentinel 1/2/A/B products ]

    Args:
        inputfile ([str]): [filepath to mmd xml file]
        xsl (str, optional): [xsl transformation file]. Defaults to '../xslt/mmd-to-iso.xsl'.
        outdir (str, optional): [output directory]. Defaults to '/tmp'.
    """
    pathlib.Path(outdir).mkdir(parents=True, exist_ok=True)
    iso_xml = mmd2iso(inputfile, xsl)
    outputfile = pathlib.PurePosixPath(outdir).joinpath(pathlib.PurePosixPath(inputfile).name)
    with open(outputfile, 'w') as isofix:
        isofix.write(fixrecord(iso_xml, pretty=True))


def main(metadata, outdir):
    xmlfiles = filelist(metadata)
    y = parmap.map(writerecord, xmlfiles, outdir=outdir, pm_pbar=False)



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
