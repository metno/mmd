#!/usr/bin/python
# -*- coding: UTF-8 -*-

"""
Script for converting metadata from MM2,DIF,ISO format to MMD format.

Author:    Magnar Martinsen,
Created:   23.03.2020 (dd.mm.YYYY)
Copyright: (c) Norwegian Meteorological Institute



Usage: See main method at the bottom of the script

NOTE:  This command should be run from the repository root, not in the src-dir.
TODO: Change references to xslt and xsd folders if script is supposed to run from src-dir
EXAMPLE: ./src/convert-to-mmd.py 

"""
import sys
import getopt
import re
import lxml.etree as ET
import datetime
import logging
import os
import os.path

def usage():
    print('')
    print('Usage: ' + sys.argv[0] +
          ' -i <input file> -f <format> -o <output file> [-xslt <path to xslt>] [-loglevel] [-h]')
    print('\t-i: inputfile to convert')
    print('\t-f: format of inputfile [dif,mm2,iso]')
    print('\t-o: outputfile')
    print('\t-xslt: path to xslt transformations. default xslt')
    print('\t-loglevel: loglevel. Default: INFO')
    print('\t-h: show this help text')
    print('')
    print("If input file and output file are paths, then process all files\n" + 
          "in input path and write to output path, output filename will be the metada_indentifier")
    sys.exit(2)


class ConvertToMMD():
    """
    Class for converting other metadata formats to MMD

    Args:
      inputfile:    path to input file for converting
      input_format: the metadata format of the inputfile
      outputfile:   path to output file for writing
      xslt:         path containg xslt transformations
      log_level:    ovveride default loglevel
    """

    #TODO: Change log_level back to INFO when script is working as supposed to
    def __init__(self,inputfile,input_format,outputfile,xslt='xslt',log_level='DEBUG'):
        #Initiate parameters from command-line
        self.inputfile = inputfile
        self.input_format = input_format
        self.outputfile = outputfile
        self.xslt = xslt

        #Initiate logger
        self.log_level = log_level
        logging.basicConfig(level=self.log_level)
        self.logger = logging.getLogger(__name__)
        
    def convert(self):
        """
        Check given input_format and call the right convert function
        for the given input_format
        """
        # Some debugging/info
        self.logger.info("Input file is: " + self.inputfile)
        self.logger.info("Format is : " + self.input_format)
        
        #TODO: Use file-extension of inputfile to determine input_format instead of cmd arg
        if self.input_format == 'mm2':
            self.convert_from_mm2()
        elif self.input_format == 'dif':
            self.convert_from_dif()
        elif self.input_format == 'iso':
            self.convert_from_iso()
        else:
            log.info('Unknown input_format. Please choose on of [mm2,dif,iso]')
            
        
    def convert_from_mm2(self):

        """
        Convert from MM2 to MMD
        """

        #TODO: Implement batchprocessing if input/output are paths not files

        #Check that input file exsists and process file
        if os.path.isfile(self.inputfile):
            mm2_doc = ET.ElementTree(file=self.inputfile).getRoot()

            #Get the xmd file with same filename as mm2 file
            base_filename = os.path.splitext(self.inputfile)[0]
            self.logger.debug("Base filename is: " + base_filename)
            base_filename = base_filename + '.xmd'
            self.logger.debug("xmd filename is: " + base_filename)      

            #Read the xmd-file
            xmd_doc = ET.ElementTree(file=base_filename).getRoot()

            #Merge the files
            mm2_doc.append(xmd_doc)
            
            #TODO: Implement MM2 Schema validation if we have usable mm2.xsd
            #Check inputfile against MM2 schema
            #xmlschema_mm2 = ET.XMLSchema(ET.parse('xsd/mm2.xsd'))
            #if not xmlschema_mm2.validate(doc):
            #    self.logger.warn("Inputfile: " + self.inputfile +
            #                     " does not validate against MM2 schema")

            
            
                


            #If input document validate against dif schema, transform to mmd
            #if xmlschema_mm2.validate(doc):    
            #Transform DIF to MMD.
            transform_to_mmd = ET.XSLT(ET.parse('xslt/mm2-to-mmd.xsl'))
            mm2_doc = ET.parse(self.inputfile)
            mmd_doc = transform_to_mmd(mm2_doc)
                    
            #Order elemets to comply with mmd.xsd
            ordered_mmd = self.correct_element_order(mmd_doc)
                    
            #Validate the translated doc to mmd-schema
            xmlschema_mmd = ET.XMLSchema(ET.parse('xsd/mmd.xsd'))
            xml_as_string = ET.tostring(ordered_mmd, xml_declaration=True, pretty_print=True, encoding=mmd_doc.docinfo.encoding)

            #TODO: Only warning and debug is logged to console if document do not validate.
            #      Should stop or continue writing to file
            if not xmlschema_mmd.validate(ET.fromstring(xml_as_string)):
                self.logger.warn("Document not validated")
                self.logger.debug(xmlschema_mmd.error_log)

            #Write xmlfile
            outputfile = open(self.outputfile, 'w')
            outputfile.write(xml_as_string)
            outputfile.close()
            self.logger.info("MMD file written to: " + self.outputfile)



    def convert_from_iso(self):

        """
        Convert from ISO to MMD
        """
        
        #TODO: Implement batchprocessing if input/output are paths not files

        #Check that input file exsists and process file
        if os.path.isfile(self.inputfile):
            iso_doc = ET.ElementTree(file=self.inputfile)
          
            #TODO: Implement schema validation for iso-xml files
            #xmlschema_iso = ET.XMLSchema(ET.parse('xsd/iso.xsd'))
            #if not xmlschema_iso.validate(doc):
            #    self.logger.warn("Inputfile: " + self.inputfile +
            #                     " does not validate against dif9 schema")

            
            
            #If input document validate against iso schema, transform to mmd
            #if xmlschema_iso.validate(doc):    
            #Transform DIF to MMD.
            transform_to_mmd = ET.XSLT(ET.parse('xslt/iso-to-mmd.xsl'))
            
            mmd_doc = transform_to_mmd(iso_doc)
                    
            #Order elemets to comply with mmd.xsd
            ordered_mmd = self.correct_element_order(mmd_doc)
                    
            #Validate the translated doc to mmd-schema
            xmlschema_mmd = ET.XMLSchema(ET.parse('xsd/mmd.xsd'))
            xml_as_string = ET.tostring(ordered_mmd, xml_declaration=True, pretty_print=True, encoding=mmd_doc.docinfo.encoding)

            #TODO: Only warning and debug is logged to console if document do not validate.
            #      Should stop or continue writing to file
            if not xmlschema_mmd.validate(ET.fromstring(xml_as_string)):
                self.logger.warn("Document not validated")
                self.logger.debug(xmlschema_mmd.error_log)

            #Write xmlfile
            outputfile = open(self.outputfile, 'w')
            outputfile.write(xml_as_string)
            outputfile.close()
            self.logger.info("MMD file written to: " + self.outputfile)

            



            
    def convert_from_dif(self):

        """
        Convert from DIF to MMD
        """

        #TODO: Should we be strict on validating input document against input schema?
        
        #Variable to keep track if document is validated or not
        isValidated = True
        
        #TODO: Implement batchprocessing if input/output are paths not files

        #Check that input file exsists and process file
        if os.path.isfile(self.inputfile):
            dif_doc = ET.ElementTree(file=self.inputfile)
            root = dif_doc.getroot()
            
            #Check DIF schema version
            schema_version = dif_doc.find('Metadata_Version', namespaces=root.nsmap).text
            self.logger.debug('DIF schema version is: ' + schema_version)
            schema_major_version = re.findall(r"(\d+).", schema_version)
            schema_major_version = schema_major_version[0]
            self.logger.debug('DIF major schema version is: ' + schema_major_version)

            #Check inputfile against DIF Version 9 schema
            if(schema_major_version == '9'):
                xmlschema_dif = ET.XMLSchema(ET.parse('xsd/dif9/dif_v9.9.3.xsd'))
                if not xmlschema_dif.validate(dif_doc):
                    isValidated = False
                    self.logger.warn("Inputfile: " + self.inputfile +
                                     " does not validate against dif9 schema")

            
            #Check inputfile against DIF Version 10 schema
            if(schema_major_version == '10'):
                xmlschema_dif = ET.XMLSchema(ET.parse('xsd/dif10/dif_v10.3.xsd'))
                if not xmlschema_dif.validate(dif_doc):
                    isValidated = False
                    self.logger.warn("Inputfile: " + self.inputfile +
                                     " does not validate against dif10 schema")


            #If input document validate against dif schema, transform to mmd
            if isValidated:    
                #Transform DIF to MMD.
                transform_to_mmd = ET.XSLT(ET.parse('xslt/dif-to-mmd.xsl'))
                mmd_doc = transform_to_mmd(dif_doc)
                    
                                  
                #Order elemets to comply with mmd.xsd
                ordered_mmd = self.correct_element_order(mmd_doc)
                    
                #Validate the translated doc to mmd-schema
                xmlschema_mmd = ET.XMLSchema(ET.parse('xsd/mmd.xsd'))
                xml_as_string = ET.tostring(ordered_mmd, xml_declaration=True, pretty_print=True, encoding=mmd_doc.docinfo.encoding)

                #TODO: Only warning and debug is logged to console if document do not validate.
                #      Should stop or continue writing to file
                if not xmlschema_mmd.validate(ET.fromstring(xml_as_string)):
                    self.logger.warn("Document not validated")
                    self.logger.debug(xmlschema_mmd.error_log)

                #Write xmlfile
                outputfile = open(self.outputfile, 'w')
                outputfile.write(xml_as_string)
                outputfile.close()
                self.logger.info("MMD file written to: " + self.outputfile)
             
                    
               
                


    #Correct element order to validate against schema
    def correct_element_order(self,doc):
            et_xslt = ET.parse('xslt/sort_mmd_according_to_xsd.xsl')
            transform = ET.XSLT(et_xslt)
            result = transform(doc)
            doc = result.getroot()
            return doc
        
def main(argv):

    # Parse command line arguments
    # print('Usage: ' + sys.argv[0] +
    #      ' -i <input file> -f <input_format> -o <output file> [-xslt <path to xslt>] [-loglevel] [-h]')
    try:
        opts, args = getopt.getopt(argv,"hi:f:o:xslt:loglevel:")
    except getopt.GetoptError:
        usage()

    iflg = oflg = fflg = False
    for opt, arg in opts:
        if opt == ("-h"):
            usage()
        elif opt in ("-i"):
            input_file = arg
            iflg =True
        elif opt in ("-o"):
            output_file = arg
            oflg =True
        elif opt in ("-f"):
            input_format = arg
            fflg =True
      
    if not iflg:
        usage()
    elif not oflg:
        usage()
    elif not fflg:
        usage()



    #Create class and do conversion
    my_converter = ConvertToMMD(input_file,input_format,output_file)
    my_converter.convert()
        
if __name__ == '__main__':
    main(sys.argv[1:])
    
