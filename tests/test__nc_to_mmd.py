from mock import patch, Mock, DEFAULT
import unittest

from utils.nc_to_mmd import Nc_to_mmd

class TestNC2MMD(unittest.TestCase):

    @patch('utils.nc_to_mmd.Nc_to_mmd.__init__')
    def test_required_mmd_elements(self, mock_init):
        mock_init.return_value = None
        nc2mmd = Nc_to_mmd()
        mmd_required_elements = {'metadata_identifier':None,
                           'metadata_status':None,
                            'collection':None,
                            'title': None,
                            'abstract': None,
                            'last_metadata_update': None,
                            'dataset_production_status': None,
                            'operational_status': None,
                            'iso_topic_category': None,
                            'keywords': '\n\t\t<mmd:keyword></mmd:keyword>\n\t',
                            'temporal_extent': '\n\t\t<mmd:start_date></mmd:start_date>\n\t',
                            'geographic_extent': str('\n\t\t<mmd:rectangle srsName=""> \n\t\t\t<mmd:north></mmd:north> \n\t\t\t<mmd:south></mmd:south> \n\t\t\t<mmd:east></mmd:east> \n\t\t\t<mmd:west></mmd:west> \n\t\t</mmd:rectangle>\n\t')
                            }
        self.assertEqual(nc2mmd.required_mmd_elements(), mmd_required_elements)

if __name__ == '__main__':
    unittest.main()
