""" Script for checking if XML file satisfy MMD requirements by
    means of the MMD XSD.

Author:    Trygve Halsne,
Created:   20.11.2019 (dd.mm.YYYY)
Copyright: (c) Norwegian Meteorological Institute

Usage: See main method at the bottom of the script

"""
import lxml.etree as ET
import operator
import datetime

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

        if not all(logical_tests.values()):
            print(('\n' + mmd_file + " - does not satisfy MMD requirements. Please edit your file according to the comments."))
            return False

        if not xmlschema.validate(doc):
            print(("\nInvalid mmd file. See log \n:{}".format(xmlschema.error_log)))
            return False
        else:
            print(('\n' + mmd_file + " - satisfy MMD requirements."))
            return True

def main():
    mmd_file = '/path/to/my/XML/myfile.xml'
    xsd = '../xsd/mmd.xsd' # The XSD is located in the "xsd" directory in this repo
    xslt ='../xslt/sort_mmd_according_to_xsd.xsl'# The XSLT is located in the "xslt" directory in this repo
    check_file = CheckMMD(mmd_file, xsd, xslt)
    print(check_file.check_mmd())

if __name__ == '__main__':
    main()
