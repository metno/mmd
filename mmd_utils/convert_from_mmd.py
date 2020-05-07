"""
Tool for converting metadata from MMD format to MM2,DIF,ISO format.

Author:    Magnar Martinsen,
Created:   23.03.2020 (dd.mm.YYYY)
Copyright: (c) Norwegian Meteorological Institute



Usage: See main method at the bottom of the script

NOTE:  This command should be run from the repository root, not in the src-dir.
TODO: Change references to xslt and xsd folders if script is supposed to run from src-dir
EXAMPLE: ./src/convert-from-mmd.py 

"""
import sys
import re
import lxml.etree as ET
import datetime
import logging
import os
import os.path

class ConvertFromMMD():
    """
    Class for converting from MMD to other metadata formats

    Args:
      inputfile:    path to input file for converting
      output_format: the metadata format of the outputfile
      outputfile:   path to output file for writing
      xslt:         path containg xslt transformations
      log_level:    ovveride default loglevel
    """

    #TODO: Change log_level back to INFO when script is working as supposed to
    def __init__(self,inputfile,output_format,outputfile,xslt='xslt',log_level='DEBUG'):
        #Initiate parameters from command-line
        self.inputfile = inputfile
        self.output_format = output_format
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
        self.logger.info("Format is : " + self.output_format)
        
        #TODO: Use file-extension of inputfile to determine input_format instead of cmd arg
        if self.output_format == 'mm2':
            self.convert_to_mm2()
        elif self.output_format == 'dif':
            self.convert_to_dif()
        elif self.output_format == 'iso':
            self.convert_to_iso()
        else:
            log.info('Unknown output_format. Please choose on of [mm2,dif,iso]')
            

    def convert_to_iso(self):

        """
        Convert from MMD to ISO
        """                
        #TODO: Implement batchprocessing if input/output are paths not files

        #Check that input file exsists and process file
        if os.path.isfile(self.inputfile):
            mmd_doc = ET.ElementTree(file=self.inputfile)

            #Validate the MMD input document
            xmlschema_mmd = ET.XMLSchema(ET.parse('xsd/mmd.xsd'))
            if not xmlschema_mmd.validate(mmd_doc):
                self.logger.warn("Input document not validated against MMD schema")
                self.logger.debug(xmlschema_mmd.error_log)

            #TODO: Evaluete right schema for transformation
            transform_to_iso = ET.XSLT(ET.parse('xslt/mmd-to-iso.xsl'))
            iso_doc = transform_to_iso(mmd_doc)
                    
                                                     
            xml_as_string = ET.tostring(iso_doc, xml_declaration=True, pretty_print=True,
                                        encoding=iso_doc.docinfo.encoding)

            #TODO: Validate transformed document against schema
            #xmlschema_iso = ET.XMLSchema(ET.pardse('xsd/iso.xsd'))
            #if not xmlschema_iso.validate(ET.fromstring(xml_as_string)):
            #    self.logger.warn("Output document not validated")
            #    self.logger.debug(xmlschema_dif.error_log)

            #Write xmlfile
            outputfile = open(self.outputfile, 'w')
            outputfile.write(str(xml_as_string))
            outputfile.close()
            self.logger.info("DIF file written to: " + self.outputfile)
             
    def convert_to_dif(self):

        """
        Convert from MMD to DIF
        """
        #FIXME: Some withcharacters not stripped. Bug in xslt?
              
        #TODO: Implement batchprocessing if input/output are paths not files

        #Check that input file exsists and process file
        if not os.path.isfile(self.inputfile):
            raise FileNotFoundError(self.inputfile)

        mmd_doc = ET.ElementTree(file=self.inputfile)

        #Validate the MMD input document
        xmlschema_mmd = ET.XMLSchema(ET.parse('xsd/mmd.xsd'))
        if not xmlschema_mmd.validate(mmd_doc):
            self.logger.warn("Input document not validated against MMD schema")
            self.logger.debug(xmlschema_mmd.error_log)

        #TODO: Evaluete right schema for transformation
        transform_to_dif = ET.XSLT(ET.parse('xslt/mmd-to-dif10.xsl'))
        dif_doc = transform_to_dif(mmd_doc)
                    
                                                     
        #Validate the translated doc to dif-schema
        #TODO: Evaluate right schema for validation
        xml_as_string = ET.tostring(dif_doc, xml_declaration=True, pretty_print=True,
                                    encoding=dif_doc.docinfo.encoding)

        xmlschema_dif = ET.XMLSchema(ET.parse('xsd/dif10/dif_v10.3.xsd'))
        if not xmlschema_dif.validate(ET.fromstring(xml_as_string)):
            self.logger.warn("Output document not validated")
            self.logger.debug(xmlschema_dif.error_log)

        #TODO: ET.tostring does not seem to return a proper string...
        xml_as_string = str(xml_as_string)

        #Write xmlfile
        outputfile = open(self.outputfile, 'w')
        outputfile.write(xml_as_string)
        outputfile.close()
        self.logger.info("DIF file written to: " + self.outputfile)

        
    def convert_to_mm2(self):

        """
        Convert from MMD to MM2
        """

        #FIXME: Output file not pretty-printed. Error in xslt?
        #TODO: Implement batchprocessing if input/output are paths not files

        #Check that input file exsists and process file
        if os.path.isfile(self.inputfile):
            mmd_doc = ET.ElementTree(file=self.inputfile)

            #Validate the MMD input document
            xmlschema_mmd = ET.XMLSchema(ET.parse('xsd/mmd.xsd'))
            if not xmlschema_mmd.validate(mmd_doc):
                self.logger.warn("Input document not validated against MMD schema")
                self.logger.debug(xmlschema_mmd.error_log)

            #TODO: Evaluete right schema for transformation
            transform_to_mm2 = ET.XSLT(ET.parse('xslt/mmd-to-mm2.xsl'))
            mm2_doc = transform_to_mm2(mmd_doc)

            #Validate the translated doc to mmd-schema
            xml_as_string = ET.tostring(mm2_doc, xml_declaration=True, pretty_print=True,
                                        encoding=mm2_doc.docinfo.encoding)

            #Validate against schema
            #if not xmlschema_mm2.validate(ET.fromstring(xml_as_string)):
            #    self.logger.warn("Output document not validated")
            #    self.logger.debug(xmlschema_dif.error_log)

            #Write xmlfile
            outputfile = open(self.outputfile, 'w')
            outputfile.write(str(xml_as_string))
            outputfile.close()
            self.logger.info("DIF file written to: " + self.outputfile)
