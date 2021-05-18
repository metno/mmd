import os
import lxml
import pathlib
import unittest

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
