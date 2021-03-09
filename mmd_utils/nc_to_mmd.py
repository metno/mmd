""" Script for parsing metadata content of NetCDF files and create a MET Norway
Metadata format specification document (MMD) based on the discovery metadata .

Will work on CF and ACDD compliant files.

Author(s):     Trygve Halsne
Created:       2019-11-25 (YYYY-mm-dd)
Modifications:
Copyright:     (c) Norwegian Meteorological Institute, 2019
Usage:         See main() method at the bottom of the script

"""
from pathlib import Path
from netCDF4 import Dataset
import lxml.etree as ET
import datetime as dt


class Nc_to_mmd(object):

    def __init__(self, output_path, output_name, netcdf_product,
            parse_services=False, parse_wmslayers=False, print_file=False):
        """
        Class for creating an MMD XML file based on the discovery metadata provided in the global attributes of NetCDF
        files that are compliant with the CF-conventions and ACDD.

        Args:
            output_path (str): Output path for mmd.
            output_name (str): Output name for mmd.
            netcdf_product (str: nc file or OPeNDAP url): input NetCDF file.

        """
        super(Nc_to_mmd, self).__init__()
        self.output_path = output_path
        self.output_name = output_name
        self.netcdf_product = netcdf_product
        self.parse_services = parse_services
        self.parse_wmslayers = parse_wmslayers
        self.print_file = print_file

    def to_mmd(self):
        """
        Method for parsing content of NetCDF file, mapping discovery
        metadata to MMD, and writes MMD to disk.
        """

        # Why
        cf_mmd_lut = self.generate_cf_acdd_mmd_lut()
        # Some mandatory MMD does not have equivalent in ACDD
        # Make one to one mapping
        cf_mmd_lut.update(self.generate_cf_mmd_lut_missing_acdd())
        mmd_required_elements = self.required_mmd_elements()

        try:
            ncin = Dataset(self.netcdf_product)
        except Exception as e:
            print('Couldn\'t open file:', self.netcdf_product)
            print('Error: ',e)
            return

        global_attributes = ncin.ncattrs()
        all_netcdf_variables = [var for var in ncin.variables]

        # Create XML file with namespaces
        ns_map = {'mmd': "http://www.met.no/schema/mmd"}
                 # 'gml': "http://www.opengis.net/gml"}
        root = ET.Element(ET.QName(ns_map['mmd'], 'mmd'), nsmap=ns_map)

        # Add mandatory elements if not done
        if 'date_metadata_modified' not in global_attributes:
            # Add last_metadata_update
            myel = ET.SubElement(root,ET.QName(ns_map['mmd'],'last_metadata_update'))
            myel2 = ET.SubElement(myel,ET.QName(ns_map['mmd'],'update'))
            ET.SubElement(myel2,
                    ET.QName(ns_map['mmd'],'datetime')).text = dt.datetime.now().strftime('%Y-%m-%dT%H:%M:%SZ')
            ET.SubElement(myel2,ET.QName(ns_map['mmd'],'type')).text = 'Created'
            ET.SubElement(myel2,ET.QName(ns_map['mmd'],'note')).text = 'Automatically generated from ACDD elements'

        # Write MMD elements from global attributes in NetCDF
        for ga in global_attributes:

            # Check if global attribute is in the Look Up Table
            if ga in cf_mmd_lut.keys():
                # Check if global attribute has a MMD mapping
                if cf_mmd_lut[ga]:
                    all_elements = cf_mmd_lut[ga].split(',')
                    len_elements = len(all_elements)
                    parent_element = root
                    for i, e in enumerate(all_elements):
                        if ga in [
                            'creator_email','creator_url',
                            'publisher_email',
                            'institution']:
                            continue

                        # Check if the element is an attribute to an element
                        # Postpone handling to next loop
                        if e.startswith('attrib_'):
                            continue

                        # Check if we have iterated to the end of the children
                        # Not good since we duplicate code, check this
                        # later
                        elif i == len_elements-1:
                            value_list = [ncin.getncattr(ga)]
                            # Split some elements by comma into list
                            if ga in 'iso_topic_category':
                                value_list = ncin.getncattr(ga).split(',')
                            elif ga in 'keywords' and ',' in ncin.getncattr(ga):
                                value_list = ncin.getncattr(ga).split(',')
                            # Need to create a new personnel tag for each
                            # and add role as well... i.e. nesting
                            # elements
                            elif ga in 'creator_name':
                                value_list = ncin.getncattr(ga).split(',')
                                org_list = ncin.getncattr('creator_institution').split(',')
                                email_list = ncin.getncattr('creator_email').split(',')

                            for k,value in enumerate(value_list):
                                if ga in 'creator_name':
                                    parent_element = ET.SubElement(root,
                                            ET.QName(ns_map['mmd'],
                                                'personnel'))
                                    current_element = ET.SubElement(
                                            parent_element, 
                                            ET.QName(ns_map['mmd'], e))
                                    ET.SubElement(parent_element,
                                        ET.QName(ns_map['mmd'],
                                            'role')).text = 'Investigator'
                                    if 'org_list' in locals() and k < len(org_list) and org_list[k]:
                                        ET.SubElement(parent_element,
                                            ET.QName(ns_map['mmd'],
                                                'organisation')).text = org_list[k]
                                    else:
                                        ET.SubElement(parent_element,
                                            ET.QName(ns_map['mmd'],
                                                'organisation')).text = 'Not available' 
                                    if 'email_list' in locals() and k < len(email_list) and email_list[k]:
                                        ET.SubElement(parent_element,
                                            ET.QName(ns_map['mmd'],
                                                'email')).text = email_list[k]
                                    else:
                                        ET.SubElement(parent_element,
                                            ET.QName(ns_map['mmd'],
                                                'email')).text = 'Not available' 
                                elif ga in 'publisher_name':
                                    org_list = ncin.getncattr('institution').split(',')
                                    email_list = ncin.getncattr('publisher_email').split(',')
                                    parent_element = ET.SubElement(root,
                                            ET.QName(ns_map['mmd'],
                                                'personnel'))
                                    current_element = ET.SubElement(
                                            parent_element, 
                                            ET.QName(ns_map['mmd'], e))
                                    ET.SubElement(parent_element,
                                        ET.QName(ns_map['mmd'],
                                            'role')).text = 'Technical contact'
                                    if k < len(org_list) and org_list[k]:
                                        ET.SubElement(parent_element,
                                            ET.QName(ns_map['mmd'],
                                                'organisation')).text = org_list[k]
                                    else:
                                        ET.SubElement(parent_element,
                                            ET.QName(ns_map['mmd'],
                                                'organisation')).text = 'Not available' 
                                    if k < len(org_list) and email_list[k]:
                                        ET.SubElement(parent_element,
                                            ET.QName(ns_map['mmd'],
                                                'email')).text = email_list[k]
                                    else:
                                        ET.SubElement(parent_element,
                                            ET.QName(ns_map['mmd'],
                                                'email')).text = 'Not available' 
                                elif ga in 'publisher_url':
                                    #current_element = ET.SubElement(parent_element,
                                    #        ET.QName(ns_map['mmd'],
                                    #            'data_center'))
                                    sub_element = ET.SubElement(current_element,
                                            ET.QName(ns_map['mmd'],
                                                'data_center_name'))
                                    if ncin.getncattr('publisher_name'):
                                        # Split string, assuming long and
                                        # short names are divided by
                                        # paranetheses (short within
                                        # parantheses)
                                        mystring = ncin.getncattr('publisher_name')
                                        if '(' in mystring:
                                            mylongname = mystring.split('(')[0].rstrip()
                                            myshortname = mystring.split('(')[1].rstrip(')') 
                                        else:
                                            mylongname = mystring
                                            myshortname = 'Not available'
                                    elif ncin.getncattr('institution'):
                                        mystring = ncin.getncattr('institution')
                                        if '(' in mystring:
                                            mylongname = mystring.split('(')[0].rstrip()
                                            myshortname = mystring.split('(')[1].rstrip(')') 
                                        else:
                                            mylongname = mystring
                                            myshortname = 'Not available'
                                    else:
                                        mylongname = 'Not available'
                                        myshortname = 'Not available'
                                    ET.SubElement(sub_element,
                                        ET.QName(ns_map['mmd'],
                                            'long_name')).text = mylongname
                                    ET.SubElement(sub_element,
                                        ET.QName(ns_map['mmd'],
                                            'short_name')).text = myshortname
                                    if  ncin.getncattr('publisher_url'):
                                        ET.SubElement(current_element,
                                                ET.QName(ns_map['mmd'],
                                                    'data_centre_url')).text = ncin.getncattr('publisher_url')
                                    else:
                                        ET.SubElement(current_element,
                                                ET.QName(ns_map['mmd'],
                                                    'data_centre_url')).text = 'Not available' 
                                else:
                                    if ga != 'project':
                                        current_element = ET.SubElement(parent_element, ET.QName(ns_map['mmd'], e))
                                if ga == 'project':
                                    project_list = value.split(',')
                                    # Check if project anem contains ()
                                    # and split in long and short name if
                                    # so
                                    for el in project_list:
                                        if '(' in value:
                                            mylongname = el.split('(')[0].rstrip()
                                            myshortname = el.split('(')[1].rstrip(')')
                                        else:
                                            mylongname = el
                                            myshortname = 'Not available'
                                            
                                        #current_element.text = mylongname
                                        current_element =ET.SubElement(parent_element,ET.QName(ns_map['mmd'],'project'))
                                        ET.SubElement(current_element,
                                                ET.QName(ns_map['mmd'],'long_name')).text = mylongname
                                        ET.SubElement(current_element,
                                                ET.QName(ns_map['mmd'],'short_name')).text = myshortname
                                elif ga != 'publisher_url':
                                    current_element.text = str(value).lstrip()

                        # Checks to avoid duplication
                        else:

                            # Check if parent element already exist to avoid duplication
                            if root.findall(parent_element.tag):
                                parent_element = root.findall(parent_element.tag)[0]

                            # Check if current_element already exist to
                            # avoid duplication
                            current_element = None
                            for c in parent_element.getchildren():
                                if c.tag == ET.QName(ns_map['mmd'], e):
                                    current_element = c
                                    continue

                            # If element doesn't exist, add it (some
                            # constraints)
                            if current_element is None:
                                if e not in ['personnel','project']:
                                    current_element = ET.SubElement(parent_element, ET.QName(ns_map['mmd'], e))
                                else:
                                    continue
                                # Set this to None by default and change
                                # if specified in next loop
                                if e == 'keywords':
                                    current_element.set('vocabulary','None')

                            parent_element = current_element

                        #print('>>>>\n',ga)
                        #print('\n',ET.tostring(current_element))


        # add MMD attribute values from CF and ACDD
        for ga in global_attributes:

            if ga in cf_mmd_lut.keys():
                if cf_mmd_lut[ga]:
                    all_elements = cf_mmd_lut[ga].split(',')
                    len_elements = len(all_elements)
                    parent_element = root

                    for i, e in enumerate(all_elements):
                        if e.startswith('attrib_'):
                            if ga == 'keywords_vocabulary':
                                attrib = e.split('_')[-1]
                                for keywords_element in root.findall(ET.QName(ns_map['mmd'], 'keywords')):
                                    keywords_element.attrib[attrib] = ncin.getncattr(ga)
                            elif ga == 'geospatial_bounds_crs':
                                attrib = e.split('_')[-1]
                                for geospatial_element in root.findall(ET.QName(ns_map['mmd'], 'rectangle')):
                                    geospatial_element.attrib[attrib] = ncin.getncattr(ga)
                            elif ga == 'title_lang':
                                attrib = e.split('_')[-1]
                                for title_element in root.findall(ET.QName(ns_map['mmd'], 'title')):
                                    title_element.attrib[
                                            '{http://www.w3.org/XML/1998/namespace}' + attrib] = ncin.getncattr(ga)
                            elif ga == 'summary_lang':
                                attrib = e.split('_')[-1]
                                for element in root.findall(ET.QName(ns_map['mmd'], 'abstract')):
                                    element.attrib[
                                            '{http://www.w3.org/XML/1998/namespace}' + attrib] = ncin.getncattr(ga)
                            else:
                                print("Warning: don't know how to handle attrib: ", e)

        # Add empty/commented required  MMD elements that are not found in NetCDF file
        """ Removed by Øystein Godøy, METNO/FOU, 2020-10-21 
        for k, v in mmd_required_elements.items():

            # check if required element is part of output MMD (ie. of NetCDF file)
            if not len(root.findall(ET.QName(ns_map['mmd'], k))) > 0:
                print('Did not find required element: {}.'.format(k))
                if not v:
                    root.append(ET.Comment('<mmd:{}></mmd:{}>'.format(k, k)))
                else:
                    root.append(ET.Comment('<mmd:{}>{}</mmd:{}>'.format(k, v, k)))
        """

        # Add OPeNDAP data_access if "netcdf_product" is OPeNDAP url
        if 'dodsC' in self.netcdf_product and self.parse_services == True:
            da_element = ET.SubElement(root, ET.QName(ns_map['mmd'], 'data_access'))
            type_sub_element = ET.SubElement(da_element, ET.QName(ns_map['mmd'], 'type'))
            description_sub_element = ET.SubElement(da_element, ET.QName(ns_map['mmd'], 'description'))
            resource_sub_element = ET.SubElement(da_element, ET.QName(ns_map['mmd'], 'resource'))
            type_sub_element.text = "OPeNDAP"
            description_sub_element.text = "Open-source Project for a Network Data Access Protocol"
            resource_sub_element.text = self.netcdf_product

            _desc = ['Open-source Project for a Network Data Access Protocol.',
                     'OGC Web Mapping Service, URI to GetCapabilities Document.']
            _res = [self.netcdf_product.replace('dodsC', 'fileServer'),
                    self.netcdf_product.replace('dodsC', 'wms')]
            access_list = []
            _desc = []
            _res = []
            add_wms_data_access = True
            if add_wms_data_access:
                access_list.append('OGC WMS')
                _desc.append('OGC Web Mapping Service, URI to GetCapabilities Document.')
                _res.append(self.netcdf_product.replace('dodsC', 'wms'))
            add_http_data_access = True
            if add_http_data_access:
                access_list.append('HTTP')
                _desc.append('Direct download of file')
                _res.append(self.netcdf_product.replace('dodsC', 'fileServer'))
            for prot_type, desc, res in zip(access_list, _desc, _res):
                dacc = ET.SubElement(root, ET.QName(ns_map['mmd'], 'data_access'))
                dacc_type = ET.SubElement(dacc, ET.QName(ns_map['mmd'], 'type'))
                dacc_type.text = prot_type
                dacc_desc = ET.SubElement(dacc, ET.QName(ns_map['mmd'], 'description'))
                dacc_desc.text = str(desc)
                dacc_res = ET.SubElement(dacc, ET.QName(ns_map['mmd'], 'resource'))
                if 'OGC WMS' in prot_type:
                    if self.parse_wmslayers:
                        wms_layers = ET.SubElement(dacc, ET.QName(ns_map['mmd'], 'wms_layers'))
                        # Don't add variables containing these names to the wms layers
                        skip_layers = ['latitude', 'longitude', 'angle']
                        for w_layer in all_netcdf_variables:
                            if any(skip_layer in w_layer for skip_layer in skip_layers):
                                continue
                            wms_layer = ET.SubElement(wms_layers, ET.QName(ns_map['mmd'], 'wms_layer'))
                            wms_layer.text = w_layer
                    # Need to add get capabilities to the wms resource
                    res += '?service=WMS&version=1.3.0&request=GetCapabilities'
                dacc_res.text = res

        # Add OGC WMS data_access as comment
        """ removed by Øystein Godøy, METNO/FOU, 2020-10-06 taken from
        THREDDS directly
        root.append(ET.Comment(str('<mmd:data_access>\n\t<mmd:type>OGC WMS</mmd:type>\n\t<mmd:description>OGC Web '
                                   'Mapping Service, URI to GetCapabilities Document.</mmd:description>\n\t'
                                   '<mmd:resource></mmd:resource>\n\t<mmd:wms_layers>\n\t\t<mmd:wms_layer>'
                                   '</mmd:wms_layer>\n\t</mmd:wms_layers>\n</mmd:data_access>')))
        """

        #print(ET.tostring(root,pretty_print=True).decode("utf-8"))
        #sys.exit()

        if not self.output_name.endswith('.xml'):
            output_file = str(self.output_path + self.output_name) + '.xml'
        else:
            output_file = str(self.output_path + self.output_name)

        et = ET.ElementTree(root)
        #et = ET.ElementTree(ET.fromstring(ET.tostring(root, pretty_print=True).decode("utf-8")))

        # Printing to file is optional
        if self.print_file:
            et.write(output_file, pretty_print=True)
        else:
            return(et)

    def required_mmd_elements(self):
        """ Create dict with required MMD elements"""

        mmd_required_elements = {
                'metadata_identifier': None,
                'metadata_status': None,
                'collection': None,
                'title': None,
                'abstract': None,
                'last_metadata_update': None,
                'dataset_production_status': None,
                'operational_status': None,
                'iso_topic_category': None,
                'keywords': '\n\t\t<mmd:keyword></mmd:keyword>\n\t',
                'temporal_extent': '\n\t\t<mmd:start_date></mmd:start_date>\n\t',
                'geographic_extent': str('\n\t\t<mmd:rectangle srsName=""> \n\t\t\t<mmd:north></mmd:north> \n\t\t\t'
                                         '<mmd:south></mmd:south> \n\t\t\t<mmd:east></mmd:east> \n\t\t\t<mmd:west>'
                                         '</mmd:west> \n\t\t</mmd:rectangle>\n\t')
            }
        return mmd_required_elements

    def generate_cf_mmd_lut_missing_acdd(self):
        """ Translation dict between ACDD and MMD (dict={ACDD: MDD})

        Create lookup table for mandatory MMD elements missing in the ACDD
        but that still is present as global attributes in the netCDF file"""

        cf_mmd = {'metadata_status': 'metadata_status',
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

        return cf_mmd

    def generate_cf_acdd_mmd_lut(self):
        """ Create the Look Up Table for CF/ACDD and MMD on the form:
        {CF/ACDD-element: MMD-element} """

        # This is not used everywhere as some of the elements are nested
        # and cannot be represented by a structure like this. Should make
        # this a list of lists.
        # Øystein Godøy, METNO/FOU, 2020-10-22 

        cf_acdd_mmd_lut = {
                'title': 'title',
                'summary': 'abstract',
                'keywords': 'keywords,keyword',
                'keywords_vocabulary': 'attrib_vocabulary',
                'Conventions': None,
                'id': 'metadata_identifier',
                'naming_authority': 'reference',
                'history': None,
                'source': None,
                'activity_type': 'activity_type',
                'processing_level': 'operational_status',
                'comment': None,
                'acknowledgement': 'reference',
                'license': 'use_constraint',
                'standard_name_vocabulary': None,
                'date_created': None,
                'creator_name': 'personnel,name',
                'creator_email': 'personnel,email',
                'creator_url': None,
                'project': 'project',
                'publisher_name': 'personnel,name',
                'publisher_email': 'personnel,email',
                'publisher_url': 'data_center,data_center_url',
                'geospatial_bounds': None,
                'geospatial_bounds_crs': 'attrib_srsName',
                'geospatial_bounds_vertical_crs': None,
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
        return cf_acdd_mmd_lut


def main(input_file=None, output_path='./',parse_services=False,parse_wmslayers=False, print_file=False):
    """Run the the mdd creation from netcdf"""

    if input_file:
        # This will extract the stem of the netcdf product filename
        output_name = '{}'.format(Path(input_file).stem)
    else:
        output_name = 'multisensor_sic.xml'
        input_file = ('https://thredds.met.no/thredds/dodsC/sea_ice/'
                      'SIW-METNO-ARC-SEAICE_HR-OBS/ice_conc_svalbard_aggregated')
    md = Nc_to_mmd(output_path, output_name, input_file, parse_services, parse_wmslayers, print_file)
    md.to_mmd()
