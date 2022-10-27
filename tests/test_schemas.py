import os
import lxml
import pathlib
import unittest
import rdflib

import lxml.etree as ET

class TestXSDs(unittest.TestCase):

    def test_mmd_xsd(self):
        xsd_schema = os.path.join(pathlib.Path.cwd(), 'xsd', 'mmd.xsd')
        xmlschema_mmd = ET.XMLSchema(ET.parse(xsd_schema))
        self.assertIsInstance(xmlschema_mmd, lxml.etree.XMLSchema)

    def test_mmd_xsd_strict(self):
        xsd_schema = os.path.join(pathlib.Path.cwd(), 'xsd', 'mmd_strict.xsd')
        xmlschema_mmd = ET.XMLSchema(ET.parse(xsd_schema))
        self.assertIsInstance(xmlschema_mmd, lxml.etree.XMLSchema)

    def test_mmd_xsd_strict_fails_on_missing_attr(self):
        mmd_schema = ET.ElementTree(
                file = os.path.join(
                    pathlib.Path.cwd(),
                    'tests',
                    'data',
                    'precipitation_amount_st_92350_EMPTY_ATTR.xml'
                )
            )
        xsd_schema1 = os.path.join(pathlib.Path.cwd(), 'xsd', 'mmd_strict.xsd')
        xsd_schema2 = os.path.join(pathlib.Path.cwd(), 'xsd', 'mmd.xsd')
        xsd_obj1 = ET.XMLSchema(ET.parse(xsd_schema1))
        xsd_obj2 = ET.XMLSchema(ET.parse(xsd_schema2))
        valid1 = xsd_obj1.validate(mmd_schema)
        valid2 = xsd_obj2.validate(mmd_schema)
        self.assertFalse(valid1)
        self.assertFalse(valid2)

    def test_mmd_xsd_strict_fails_on_missing_lang_attr(self):
        mmd_schema = ET.ElementTree(
                file = os.path.join(
                    pathlib.Path.cwd(),
                    'tests',
                    'data',
                    'precipitation_amount_st_92350_NO_LANG_ATTR.xml'
                )
            )
        xsd_schema1 = os.path.join(pathlib.Path.cwd(), 'xsd', 'mmd_strict.xsd')
        xsd_obj1 = ET.XMLSchema(ET.parse(xsd_schema1))
        valid1 = xsd_obj1.validate(mmd_schema)
        self.assertFalse(valid1)

    #def test_mmd_xsd_passing(self):
    #    mmd_schema = ET.ElementTree(
    #            file = os.path.join(
    #                pathlib.Path.cwd(),
    #                'tests',
    #                'data',
    #                'precipitation_amount_st_92350.xml'
    #            )
    #        )
    #    xsd_schema2 = os.path.join(pathlib.Path.cwd(), 'xsd', 'mmd.xsd')
    #    xsd_obj2 = ET.XMLSchema(ET.parse(xsd_schema2))
    #    valid2 = xsd_obj2.validate(mmd_schema)
    #    self.assertTrue(valid2)

    def test_mmd_xsd_strict_passing(self):
        mmd_schema = ET.ElementTree(
                file = os.path.join(
                    pathlib.Path.cwd(),
                    'tests',
                    'data',
                    'precipitation_amount_st_92350.xml'
                )
            )
        xsd_schema1 = os.path.join(pathlib.Path.cwd(), 'xsd', 'mmd_strict.xsd')
        xsd_obj1 = ET.XMLSchema(ET.parse(xsd_schema1))
        valid1 = xsd_obj1.validate(mmd_schema)
        self.assertTrue(valid1)

class TestXSLTs(unittest.TestCase):

    def test_mmd_to_geonorge_xsl(self):
        translator = ET.XSLT(ET.parse('xslt/mmd-to-geonorge.xsl'))
        self.assertIsInstance(translator, lxml.etree.XSLT)
        
    def test_dcatap_xsl_instance(self):
        transform_to_dcat = ET.XSLT(ET.parse('xslt/mmd-to-dcatap.xsl'))
        self.assertIsInstance(transform_to_dcat, lxml.etree.XSLT)

    def test_mmd_to_dcatap_translation(self):
        inputpath = os.path.join(pathlib.Path.cwd(), 'input-examples', 'foo.xml')
        dom = ET.parse(inputpath)
        xsltfile = os.path.join(pathlib.Path.cwd(), 'xslt', 'mmd-to-dcatap.xsl')
        xslt = ET.parse(xsltfile)
        transform = ET.XSLT(xslt)
        newdom = transform(dom)
        graph = rdflib.Graph()
        dcatap = ET.tostring(newdom, xml_declaration = True, encoding='UTF-8', pretty_print=True)
        self.assertIsInstance(rdflib.Graph().parse(data=dcatap, format="xml"), rdflib.graph.Graph)
    
