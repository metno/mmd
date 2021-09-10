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

class TestXSLTs(unittest.TestCase):

    def test_dcatap_xslt_instance(self):
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
        
