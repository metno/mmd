from mock import patch, Mock, DEFAULT
import unittest

from mmd_utils.nc_to_mmd import Nc_to_mmd

class TestNC2MMD(unittest.TestCase):

    @patch('mmd_utils.nc_to_mmd.Nc_to_mmd.__init__')
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

    @patch('utils.nc_to_mmd.Nc_to_mmd.__init__')
    def test_generate_cf_mmd_lut_missing_acdd(self, mock_init):
        mock_init.return_value = None
        nc2mmd = Nc_to_mmd()
        cf_mmd_expected_elements = {'metadata_status': 'metadata_status',
                                    'collection': 'collection',
                                    'dataset_production_status': 'dataset_production_status',
                                    'iso_topic_category': 'iso_topic_category',
                                    'platform': 'platform,short_name',
                                    'platform_long_name': 'platform,long_name',
                                    'platform_resource': 'platform,resource',
                                    'instrument': 'platform,instrument,short_name',
                                    'instrument_long_name': 'platform,instrument,long_name',
                                    'instrument_resource': 'platform,instrument,resource',
                                    'ancillary_timeliness': 'platform,ancillary,timeliness',
                                    'title_lang': 'attrib_lang',
                                    'summary_lang': 'attrib_lang',
                                    'license': 'use_constraint,identifier',
                                    'license_resource': 'use_constraint,resource',
                                    'publisher_country': 'personnel,country',
                                    'creator_role': 'personnel,role',
                                    'date_metadata_modified': 'last_metadata_update,update,datetime',
                                    'date_metadata_modified_type': 'last_metadata_update,update,type',
                                    'date_metadata_modified_note': 'last_metadata_update,update,note'}

        self.assertEqual(nc2mmd.generate_cf_mmd_lut_missing_acdd(), cf_mmd_expected_elements)

    @patch('utils.nc_to_mmd.Nc_to_mmd.__init__')
    def test_generate_cf_acdd_mmd_lut(self, mock_init):
        mock_init.return_value = None
        nc2mmd = Nc_to_mmd()
        cf_acdd_mmd_lut_expected_elements = {'title': 'title',
                                             'summary': 'abstract',
                                             'keywords': 'keywords,keyword',
                                             'keywords_vocabulary': 'attrib_vocabulary',
                                             'Conventions': None,
                                             'id': 'metadata_identifier',
                                             'naming_authority': 'reference',
                                             'history': None,
                                             'source': 'activity_type',
                                             'processing_level': 'operational_status',
                                             'comment': None,
                                             'acknowledgement': 'reference',
                                             'license': 'use_constraint',
                                             'standard_name_vocabulary': None,
                                             'date_created': None,
                                             'creator_name': 'personnel,name',
                                             'creator_email': 'personnel,email',
                                             'creator_url': None,
                                             'project': 'project,long_name',
                                             'publisher_name': 'personnel,name',
                                             'publisher_email': 'personnel,email',
                                             'publisher_url': None,
                                             'geospatial_bounds': None,
                                             'geospatial_bounds_crs': 'attrib_srsName',
                                             'geospatial_bounds_vertical_crs':  None,
                                             'geospatial_lat_min': 'geographic_extent,rectangle,south',
                                             'geospatial_lat_max': 'geographic_extent,rectangle,north',
                                             'geospatial_lon_min': 'geographic_extent,rectangle,west',
                                             'geospatial_lon_max': 'geographic_extent,rectangle,east',
                                             'geospatial_vertical_min': None,
                                             'geospatial_vertical_max': None,
                                             'geospatial_vertical_positive': None,
                                             'time_coverage_start': 'temporal_extent,start_date',
                                             'time_coverage_end': 'temporal_extent,end_date',
                                             'time_coverage_duration': None,
                                             'time_coverage_resolution': None,
                                             'creator_type': None,
                                             'publisher_type': None,
                                             'publisher_institution': 'personnel,organisation',
                                             'contributor_name': 'data_center,contact,name',
                                             'contributor_role': 'data_center,contact,role',
                                             'institution': 'data_center,data_center_name,long_name',
                                             'creator_institution': 'dataset_citation,dataset_publisher',
                                             'metadata_link': 'dataset_citation,online_resource',
                                             'references': 'dataset_citation,other_citation_details',
                                             'product_version': 'dataset_citation,version',
                                             'geospatial_lat_units': None,
                                             'geospatial_lat_resolution': None,
                                             'geospatial_lon_units': None,
                                             'geospatial_lon_resolution': None,
                                             'geospatial_vertical_units': None,
                                             'geospatial_vertical_resolution': None,
                                             'date_modified': None,
                                             'date_issued': None,
                                             'date_metadata_modified': 'last_metadata_update',
                                             'platform': None,
                                             'platform_vocabulary': None,
                                             'instrument': 'instrument,long_name',
                                             'instrument_vocabulary': None,
                                             'cdm_data_type': None}
        self.assertEqual(nc2mmd.generate_cf_acdd_mmd_lut(), cf_acdd_mmd_lut_expected_elements)


if __name__ == '__main__':
    unittest.main()
