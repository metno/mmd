#!/usr/bin/python3
# -*- coding: UTF-8 -*-

""" Script for checking if XML file satisfy MMD requirements by
    means of the MMD XSD.

Author:    Trygve Halsne,
Created:   20.11.2019 (dd.mm.YYYY)
Copyright: (c) Norwegian Meteorological Institute

Usage: See main method at the bottom of the script

UPDATED 29.01.2020 (dd.mm.YYYY):
Author: Magnar Martinsen

- Added urltest
- Added extra test to check if urls pointing to thredds has https protocol in url
"""
import sys
import lxml.etree as ET
import operator
import datetime
import requests
from urllib.parse import urlparse
import glob
import logging
import os

class CheckMMD():
    """ Class to verify if MMD file is in compliance with the requirements

        Args:
            mmd_file (file): absolute path to XML file
            xsd (file):      absolute path to XSD for MMD (in ../xslt/ folder)
            xslt (file):     absolute path to XSLT transforming MMD according
                             to required order in XSD (in ../xsd/ folder)
    """

    def __init__(self, mmd_file, xsd, xslt=None):
        self.mmd_file = mmd_file
        self.xsd = xsd
        self.xslt = xslt

        #Initialize logger
        self.logger = logging.getLogger(__name__)
        self.logger.setLevel(logging.WARNING)

        logger_handler = logging.FileHandler('checkMMD_warnings.log')
        logger_handler.setLevel(logging.WARNING)
        logger_formatter = logging.Formatter('%(levelname)s - %(message)s')
        logger_handler.setFormatter(logger_formatter)
        self.logger.addHandler(logger_handler)

    def check_abstract(self, abstract):
        """ Check if abstract is valid """
        languages = []
        for child in abstract:
            if not (list(child.attrib.values()) == []):
                languages.append(list(child.attrib.values()))

        return self.multipleLanguages(languages=languages)

    def check_title(self, title):
        """ Check title requirements """
        languages = []
        for child in title:
            if not len(child.text) <= 220:
                print("\t Title is to long \n")
                return False
            if not (list(child.attrib.values()) == []):
                languages.append(list(child.attrib.values()))

        return self.multipleLanguages(languages=languages)

    def check_metadata_identifier(self, metadata_identifier):
        """ Check if metadata_identifier fulfill requirements """
        invalid = '/\: '

        if len(metadata_identifier) > 1:
            print("\t Error: Multiple metadata_identifier elements in file")
            return False

        return self.validText(metadata_identifier[0].text, invalid)

    def check_temporal_extent(self, temporal_extent):
        """ Check if temporal extent fulfill requirements """
        valid_keywords = ['start_date','end_date']

        keywords = [date.tag for child in temporal_extent for date in child]
        validDates = [self.validDateFormat(date.text) for child in temporal_extent for date in child]

        if all(element == True for element in validDates) and self.containString(keywords, valid_keywords):
            return True
        else:
            print("\t Error: Wrong date format or keyword typos")
            return False

    def check_rectangle(self, rectangle):
        """ Check geographic extent/rectangle for projection points """
        valid_directions = ['north', 'south', 'west', 'east']

        if len(rectangle) > 1:
            print("\t Error: Multiple rectangle elements in file. \n")
            return False

        coord = {}
        try:
            for child in rectangle[0]:
                for direction in valid_directions:
                    if direction in child.tag:
                        coord[format(direction)] = float(child.text)

            if not (-180 <= coord['west'] <= coord['east'] <= 180): return False
            if not (-90 <= coord['south'] <= coord['north'] <= 90): return False

            return True
        except ValueError:
            print('\t Could not extract valid directions from rectangle. \n')
            return False

    def multipleLanguages(self, languages):
        """ Function to check if array contains several languages
            Inputdata:
                - @languages : list of xml attribute values
        """
        if len(languages) > 1:
            for i in range(1,len(languages)):
                if languages[i-1] == languages[i]:
                    print('Languages must be unique.')
                    return False
        return True

    def validKeywords(self, keywords, validKeywords):
        """ Inputdata: @keywords = list, @validKeywords = list"""
        for keyword in keywords:
            if not len([word for word in validKeywords if keyword.lower() == word.lower()]) > 0:
                print("\t Invalid keyword: " + keyword)
                return False
        return True

    def validText(self, text, invalidCharacters):
        """ Inputdata:
            @text = string,
            @invalidCharacters = string with invalid characters
        """
        invalid = set(invalidCharacters)
        if not any((char in invalid) for char in text):
            return True
        return False

    def containString(self, keywords, validKeywords):
        """ Function to check if string contains valid part
            Inputdata:
                - @keywords : list of xml element text values
                - @validKeywords : list of xml element text values
        """
        contained = []
        for keyword in keywords:
            tmp_boolean = False
            for validKeyword in validKeywords:
                if validKeyword in keyword:
                    tmp_boolean = True
            contained.append(tmp_boolean)
        if all(element == True for element in contained):
            return True
        else:
            return False

    def validDateFormat(self, date):
        """ Function to check if date has valid format after ISO 8601 standard
            NOTE: valid_formats should be extended if need for other formats
        """
        valid_formats = ["%Y-%m-%d","%Y-%m-%dT%H","%Y-%m-%dT%H:%M",
                        "%Y-%m-%dT%H:%M:%S","%Y-%m-%dT%H:%M:%S.%fZ",
                        "%Y-%m-%dT%H:%M:%S%fZ", "%Y-%m-%dT%H:%M:%S.%f"]
        for f in valid_formats:
            try:
                if datetime.datetime.strptime(date,f):
                    return True
            except:
                pass

        print(str("Does you input data: %s \nfollow ISO 8601 standard?" %date +
                  "\nIf YES, please edit the valid_dates in the validDateFormat function."))
        return False

    "Check mmd:resource url for response OK"
    def checkURL(self, url):
        response = False
        try:
            r = requests.get(url, timeout=30)
                    
            if(r.status_code == requests.codes.ok):
                response = True
            else:
                print("Error: " + r.raise_for_status())
                self.logger.warning("File: " + self.mmd_file)
                self.logger.warning("Invalid URL: " + url)
            r.close()
        except Exception as e:
            print(e)
            
        return response

    #Use urlparse to check url protocol and server address.
    #Print warning if url points to thredds.met.no and protocol is http
    def check_thredds_http(self,url):
        try:
            urlinfo = urlparse(url)
            if(urlinfo.netloc == 'thredds.met.no'):
                #print("url points to met thredds server")
                if(urlinfo.scheme != 'https'):
                    print(('\x1b[0;36;41m %s \x1b[0m : %-12s'
                       %('Warning!! ', 'resource points to unsecure thredds.met.no (http)')))
        except:
            print("Error parsing url: " + url) 

    def check_mmd(self):
        """ Method for initiating the verification process
        """
        mmd_file = self.mmd_file
        xsd = self.xsd
        xslt = self.xslt

        logical_tests = {'metadata_identifier' : False,
                            'title' : False, 'abstract' : False,
                            'temporal_extent': False,
                            'rectangle' : False }
        print(("\nChecking file: \n\t%s" % mmd_file))

        # Read MMD
        doc = ET.ElementTree(file=mmd_file)
        root = doc.getroot()

        # Correct element order (if necessary)
        if xslt:
            et_xslt = ET.parse(xslt)
            transform = ET.XSLT(et_xslt)
            result = transform(doc)
            doc = result.getroot()

        xmlschema_doc = ET.parse(xsd)
        xmlschema = ET.XMLSchema(xmlschema_doc)

        
        ##################################################################################
        # Get elements with url and check for OK response
        #
        # If URL points to thredds.met.no, check if protocol is https
        #
        ##################################################################################
        print("Checking for valid urls in document")

        #Check data_center_url
        elementR = doc.findall('./mmd:data_center/mmd:data_center_url',
                               namespaces=root.nsmap)
        for resource in elementR:
            self.check_thredds_http(resource.text)
            status = self.checkURL(resource.text)
            if(status):
                print(('\x1b[0;30;42m %s \x1b[0m : %-12s' %('Data Center URL OK',
                                                            resource.text)))
            else:
                print(('\x1b[0;36;41m %s \x1b[0m : %-12s' %('Data Center Invalid URL',
                                                            resource.text)))

        #Checking related information urls
        elementR = doc.findall('./mmd:related_information/mmd:resource',
                               namespaces=root.nsmap)
        for resource in elementR:
            self.check_thredds_http(resource.text)
            status = self.checkURL(resource.text)
            if(status):
                print(('\x1b[0;30;42m %s \x1b[0m : %-12s' %('Related Info URL OK',
                                                            resource.text)))
            else:
                print(('\x1b[0;36;41m %s \x1b[0m : %-12s' %('Related Info Invalid URL',
                                                            resource.text)))

        #Checking data access resource urls
        elementR = doc.findall('./mmd:data_access', namespaces=root.nsmap)
        for resource in elementR:
            #print 'Type: ', resource.find('{http://www.met.no/schema/mmd}type').text
            #print 'Resource: ', resource.find('{http://www.met.no/schema/mmd}resource').text
            try:
                rtype =  resource.find('{http://www.met.no/schema/mmd}type').text
                rurl = resource.find('{http://www.met.no/schema/mmd}resource').text
                self.check_thredds_http(rurl)
                if(rtype == "HTTP"):
                    status = self.checkURL(str(rurl))
                if(rtype == "OPeNDAP"):
                    status = self.checkURL(str(rurl) + '.html')
                if(rtype == "OGC WMS"):
                    status = self.checkURL(str(rurl) + '?SERVICE=WMS&REQUEST=GetCapabilities')
                if(status):
                    print(('\x1b[0;30;42m %s %s %s \x1b[0m: %-12s' %('Data Access', rtype,
                                                                  'URL OK', rurl)))
                else:
                    print(('\x1b[0;36;41m %s %s %s\x1b[0m: %-12s' %('Data Access', rtype,
                                                                 'URL Invalid',rurl)))
            except:
                print("Document have no element mmd:data_access")
        ###################################################################################        

        print("Comments: \n")
        for test in list(logical_tests.keys()):
            element = doc.findall('.//mmd:' + test, namespaces=root.nsmap)
            if element != []:
                if eval(str('self.check_' + test))(element):
                    logical_tests[test]=True
                else:
                    print(('\t ' + test + ' is None '))

        ### Go through results
        print('\nLogical tests:')
        for element in sorted(list(logical_tests.items()),key=operator.itemgetter(1),reverse=True):
            if element[1]:
                print(('\t  \x1b[0;30;42m %s \x1b[0m : %-12s' %('OK', element[0])))
            else:
                print(('\t  \x1b[0;36;41m %s \x1b[0m : %-12s' %('Invalid', element[0])))
                #self.logger.warning("File: " + mmd_file + " fails test: " + element[0])

        if not all(logical_tests.values()):
            print(('\n' + mmd_file + " - does not satisfy MMD requirements. Please edit your file according to the comments."))
            #self.logger.warning("File: " + mmd_file + " failed logical tests")
            return False

        if not xmlschema.validate(doc):
            print(("\nInvalid mmd file. See log \n:{}".format(xmlschema.error_log)))
            self.logger.warning("Invalid mmd file: " + mmd_file + "\n:{}\n\n".format(xmlschema.error_log))
            return False
        else:
            print(('\n' + mmd_file + " - satisfy MMD requirements."))
            return True


