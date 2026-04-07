#!/usr/bin/env python
# coding: utf-8

import json
import lxml.etree as ET
import datetime as dt
from bs4 import BeautifulSoup
import requests
import sys
import os
import argparse

def parse_arguments():
    parser = argparse.ArgumentParser(
    formatter_class=argparse.RawDescriptionHelpFormatter,
            description='Creates MMD records from metadata-collection-form in json.\n' +
            'runing: extract_md_webform.py submission.json')
    parser.add_argument("input",  nargs='*', help='The input file to extract metadata from')

    try:
        args = parser.parse_args()
    except:
        sys.exit()
    return args

license_mapping = {
"CC0-1.0":"http://spdx.org/licenses/CC0-1.0",
"CC-BY-4.0":"http://spdx.org/licenses/CC-BY-4.0",
"CC-BY-SA-4.0":"http://spdx.org/licenses/CC-BY-SA-4.0",
"CC-BY-NC-4.0":"http://spdx.org/licenses/CC-BY-NC-4.0",
"CC-BY-NC-SA-4.0":"http://spdx.org/licenses/CC-BY-NC-SA-4.0",
"CC-BY-ND-4.0":"http://spdx.org/licenses/CC-BY-ND-4.0",
"CC-BY-NC-ND-4.0":"http://spdx.org/licenses/CC-BY-NC-ND-4.0"
}

quality_mapping = {'not_qc':'No quality control',
                  'preliminary_qc':'Basic quality control',
                  'extensive_qc':'Extended quality control',
                  'comprehensive_qc':'Comprehensive quality control'}

collection_mapping = {'SESS_2018': 'SESS2018',
                      'SESS_2019': 'SESS2019',
                      'SESS_2020': 'SESS2020',
                      'SESS_2022': 'SESS2022',
                      'SESS_2023': 'SESS2023',
                      'SESS_2024': 'SESS2024',
                      'SESS_2025': 'SESS2025',
                      'SIOS_Core_Data': 'SIOSCD',
                      'Contributed_dataset': 'SIOS',
                      'SIOS_access_programme': 'SIOSAP',
                      'AeN': 'AeN'}

access_mapping = {'Open': 'Open',
                  'automated_approval': 'Registered users only (automated approval)',
                  'manual_approval': 'Registered users only (manual approval required)',
                  'Restricted_to_a_community': 'Restricted to a community',
                  'Restricted_to_metadata': 'Restricted access to metadata'
}

role_mapping = {'in': 'Investigator',
                'tc': 'Technical contact',
                'ma': 'Metadata author',
                'dcc': 'Data center contact'}


institute_mapping = { 'Akvaplan-NIVA': ' Akvaplan-NIVA',
      'Alfred_Wegener_Institute': 'Alfred Wegener Institute',
      'Andøya_Space_Center': 'Andøya Space Center',
      'Arctic_Centre_University_Groningen': 'Arctic Centre, University of Groningen',
      'French_Polar_Institute_Paul-Emile_Victor': 'French Polar Institute Paul-Emile Victor',
      'Geological_Survey_Norway': 'Geological Survey of Norway',
      'Institute_Atmospheric_and_Earth_System_Research_University_Helsinki': 'Institute for Atmospheric and Earth System Research of the University of Helsinki',
      'Institute_Geophysics_Polish_Academy_Sciences': 'Institute of Geophysics, Polish Academy of Sciences',
      'Institute_Marine_Research': 'Institute Marine Research',
      'Marine_Biological_Association': 'Marine Biological Association',
      'Nansen_Environmental_Remote_Sensing_Center': 'Nansen Environmental and Remote Sensing Center',
      'National_Institute_Oceanography_Applied Geophysics': 'National Institute of Oceanography and Applied Geophysics',
      'National_Institute_Polar_Research': 'National Institute for Polar Research',
      'National_Research_Council_Italy': 'National Research Council of Italy',
      'Natural_Environment_Research_Council-Arctic_office': 'Natural Environment Research Council - Arctic office',
      'Norut_Northern_Research_Institute': 'Norut Northern Research Institute',
      'Norwegian_Institute _Air_Research': 'Norwegian Institute for Air Research',
      'Norwegian_Institute_Nature_Research': 'Norwegian Institute for Nature Research',
      'Norwegian_Institute_Water_Research': 'Norwegian Institute for Water Research',
      'Norwegian_Meteorological_Institute': 'Norwegian Meteorological Institute',
      'Norwegian_Polar_Institute': 'Norwegian Polar Institute',
      'Norwegian_Water_Resources_Energy_Directorate': 'Norwegian Water Resources and Energy Directorate',
      'Scottish_Association_Marine_Science': 'Scottish Association for Marine Science',
      'Swedish_Polar_Research_Secretariat': 'Swedish Polar Research Secretariat',
      'Institute_Atmospheric_Sciences_Climate_CNR': 'The Institute of Atmospheric Sciences and Climate, CNR',
      'University_Centre_Svalbard': 'The University Centre in Svalbard',
      'UiT_Arctic_University_Norway': 'UiT The Arctic University of Norway',
      'University_Bergen': 'University of Bergen',
      'University_Northumbria_Newcastle': 'University of Northumbria at Newcastle',
      'University_Oslo': 'University of Oslo',
      'University_Silesia': 'University of Silesia in Katowice'}

def extract_kw(kwid):
    taxonomy_kw = 'https://sios-svalbard.org/taxonomy/term/'+kwid
    html_text = requests.get(taxonomy_kw).text
    soup = BeautifulSoup(html_text, 'html.parser')
    kw = soup.title.text
    gcmdk = 'EARTH SCIENCE > ' + kw.split('|')[0].strip().replace('>',' > ')
    return(gcmdk)


def create_mmd_mdform(json_load,f, output_file):
    ns_map = {'mmd': "http://www.met.no/schema/mmd", "xml": "http://www.w3.org/XML/1998/namespace"}

    root = ET.Element(ET.QName(ns_map['mmd'], 'mmd'), nsmap=ns_map)
    et = ET.ElementTree(root)

    ET.SubElement(root,ET.QName(ns_map['mmd'],'metadata_identifier'))
    title = ET.SubElement(root,ET.QName(ns_map['mmd'],'title'))
    title.text = json_load['data']['title']
    title.set(ET.QName(ns_map['xml'],'lang'),'en')
    abstract = ET.SubElement(root,ET.QName(ns_map['mmd'],'abstract'))
    abstract.text = json_load['data']['abstract'].replace('\r\n','')
    abstract.set(ET.QName(ns_map['xml'],'lang'),'en')
    ET.SubElement(root,ET.QName(ns_map['mmd'],'metadata_status')).text = 'Active'
    ET.SubElement(root,ET.QName(ns_map['mmd'],'dataset_production_status')).text = json_load['data']['dataset_production_status'].replace('_',' ')
    ET.SubElement(root,ET.QName(ns_map['mmd'],'collection')).text = 'ADC'
    ET.SubElement(root,ET.QName(ns_map['mmd'],'collection')).text = 'SIOS'
    if 'sios_program' in json_load['data']:
        for i in json_load['data']['sios_program']:
            if i != 'Contributed_dataset':
                ET.SubElement(root,ET.QName(ns_map['mmd'],'collection')).text = collection_mapping[i]
    md_update = ET.SubElement(root,ET.QName(ns_map['mmd'],'last_metadata_update'))
    md_update2 = ET.SubElement(md_update,ET.QName(ns_map['mmd'],'update'))
    ET.SubElement(md_update2,ET.QName(ns_map['mmd'],'datetime')).text = dt.datetime.now().strftime('%Y-%m-%dT%H:%M:%SZ')
    ET.SubElement(md_update2,ET.QName(ns_map['mmd'],'type')).text = 'Created'
    ET.SubElement(md_update2,ET.QName(ns_map['mmd'],'note')).text = 'Created from SIOS metadata form'
    text = ET.SubElement(root,ET.QName(ns_map['mmd'],'temporal_extent'))
    if json_load['data']['time_start_11']:
        start = json_load['data']['date_start_11']+'T'+json_load['data']['time_start_11']+'Z'
    else:
        start = json_load['data']['date_start_11']+'T00:00:00Z'
    if json_load['data']['date_end_14']:
        if json_load['data']['time_end_14']:
            end = json_load['data']['date_end_14']+'T'+json_load['data']['time_end_14']+'Z'
        else:
            end = json_load['data']['date_end_14']+'T00:00:00Z'
    else:
        end = ''
    ET.SubElement(text,ET.QName(ns_map['mmd'],'start_date')).text = start
    ET.SubElement(text,ET.QName(ns_map['mmd'],'end_date')).text = end

    for i in json_load['data']['iso_topic_category']:
        ET.SubElement(root,ET.QName(ns_map['mmd'],'iso_topic_category')).text = i.strip()

    kwds = ET.SubElement(root,ET.QName(ns_map['mmd'],'keywords'))
    kwds.set('vocabulary','GCMDSK')
    for gcmd in json_load['data']['gcmd_science_keywords']:
        ET.SubElement(kwds,ET.QName(ns_map['mmd'],'keyword')).text = extract_kw(gcmd)

    ET.SubElement(root,ET.QName(ns_map['mmd'],'operational_status')).text = 'Not available'

    gext = ET.SubElement(root,ET.QName(ns_map['mmd'],'geographic_extent'))
    rect = ET.SubElement(gext,ET.QName(ns_map['mmd'],'rectangle'))
    rect.set('srsName', "EPSG:4326")
    ET.SubElement(rect,ET.QName(ns_map['mmd'],'north')).text = json_load['data']['dataset_northernmost_latitude_21']
    ET.SubElement(rect,ET.QName(ns_map['mmd'],'south')).text = json_load['data']['dataset_southernmost_latitude_21']
    ET.SubElement(rect,ET.QName(ns_map['mmd'],'east')).text = json_load['data']['dataset_easternmost_longitude_21']
    ET.SubElement(rect,ET.QName(ns_map['mmd'],'west')).text = json_load['data']['dataset_westernmost_longitude_21']
    ET.SubElement(root,ET.QName(ns_map['mmd'],'access_constraint')).text = access_mapping[json_load['data']['access_constraint']]
    if json_load['data']['license'] in license_mapping.keys():
        usc = ET.SubElement(root,ET.QName(ns_map['mmd'],'use_constraint'))
        ET.SubElement(usc,ET.QName(ns_map['mmd'],'identifier')).text = json_load['data']['license']
        ET.SubElement(usc,ET.QName(ns_map['mmd'],'resource')).text = license_mapping[json_load['data']['license']]
    proj = ET.SubElement(root,ET.QName(ns_map['mmd'],'project'))
    ET.SubElement(proj,ET.QName(ns_map['mmd'],'short_name')).text = json_load['data']['short_name_38']
    ET.SubElement(proj,ET.QName(ns_map['mmd'],'long_name')).text = json_load['data']['long_name_38']
    ET.SubElement(root,ET.QName(ns_map['mmd'],'activity_type')).text = json_load['data']['activity_type'].replace('_',' ')

    rilp = ET.SubElement(root,ET.QName(ns_map['mmd'],'related_information'))
    ET.SubElement(rilp,ET.QName(ns_map['mmd'],'type')).text = 'Dataset landing page'
    ET.SubElement(rilp,ET.QName(ns_map['mmd'],'description')).text = 'Dataset landing page'
    ET.SubElement(rilp,ET.QName(ns_map['mmd'],'resource')).text = json_load['data']['dataset_landing_page_27']

    riph = ET.SubElement(root,ET.QName(ns_map['mmd'],'related_information'))
    ET.SubElement(riph,ET.QName(ns_map['mmd'],'type')).text = 'Project home page'
    ET.SubElement(riph,ET.QName(ns_map['mmd'],'description')).text = 'Project home page'
    ET.SubElement(riph,ET.QName(ns_map['mmd'],'resource')).text = json_load['data']['project_home_page_27']

    if json_load['data']['extended_metadata_27'] != '':
        riem =ET.SubElement(root,ET.QName(ns_map['mmd'],'related_information'))
        ET.SubElement(riem,ET.QName(ns_map['mmd'],'type')).text = 'Extended metadata'
        ET.SubElement(riem,ET.QName(ns_map['mmd'],'description')).text = 'Extended metadata'
        ET.SubElement(riem,ET.QName(ns_map['mmd'],'resource')).text = json_load['data']['extended_metadata_27']

    if json_load['data']['http_28'] != '':
        httpaccess = ET.SubElement(root,ET.QName(ns_map['mmd'],'data_access'))
        ET.SubElement(httpaccess,ET.QName(ns_map['mmd'],'type')).text = 'HTTP'
        ET.SubElement(httpaccess,ET.QName(ns_map['mmd'],'description')).text = 'Direct download of data file'
        ET.SubElement(httpaccess,ET.QName(ns_map['mmd'],'resource')).text = json_load['data']['http_28']

    inv = ET.SubElement(root,ET.QName(ns_map['mmd'],'personnel'))
    ET.SubElement(inv, ET.QName(ns_map['mmd'],'role')).text = 'Investigator'
    ET.SubElement(inv,ET.QName(ns_map['mmd'],'name')).text = json_load['data']['principal_investigator_pi']
    #PI contact -> 8
    if json_load['data']['pi_institution_8'] in institute_mapping.keys():
        ET.SubElement(inv,ET.QName(ns_map['mmd'],'organisation')).text = institute_mapping[json_load['data']['pi_institution_8']]
    else:
        ET.SubElement(inv,ET.QName(ns_map['mmd'],'organisation')).text = json_load['data']['pi_institution_8']
    ET.SubElement(inv,ET.QName(ns_map['mmd'],'email')).text = json_load['data']['pi_email_8']
    add = ET.SubElement(inv,ET.QName(ns_map['mmd'],'contact_address'))
    ET.SubElement(add,ET.QName(ns_map['mmd'],'address')).text = json_load['data']['pi_address_8']
    ET.SubElement(add,ET.QName(ns_map['mmd'],'city')).text = json_load['data']['pi_city_8']
    ET.SubElement(add,ET.QName(ns_map['mmd'],'postal_code')).text = json_load['data']['postal_code_8']
    ET.SubElement(add,ET.QName(ns_map['mmd'],'country')).text = json_load['data']['country_8']

    #Metadata contact -> 74
    if json_load['data'].get('mda_name_74') and json_load['data'].get('mda_email_74'):
        mda = ET.SubElement(root,ET.QName(ns_map['mmd'],'personnel'))
        ET.SubElement(mda,ET.QName(ns_map['mmd'],'role')).text = 'Metadata author'
        ET.SubElement(mda,ET.QName(ns_map['mmd'],'name')).text = json_load['data']['mda_name_74']
        ET.SubElement(mda,ET.QName(ns_map['mmd'],'organisation')).text = ''
        ET.SubElement(mda,ET.QName(ns_map['mmd'],'email')).text = json_load['data']['mda_email_74']

    #technical contact -> 71
    if json_load['data'].get('tc_name_71') and json_load['data'].get('tc_email_71'):
        tc = ET.SubElement(root,ET.QName(ns_map['mmd'],'personnel'))
        ET.SubElement(tc,ET.QName(ns_map['mmd'],'role')).text = 'Technical contact'
        ET.SubElement(tc,ET.QName(ns_map['mmd'],'name')).text = json_load['data']['tc_name_71']
        ET.SubElement(tc,ET.QName(ns_map['mmd'],'organisation')).text = ''
        ET.SubElement(tc,ET.QName(ns_map['mmd'],'email')).text = json_load['data']['tc_email_71']

    #data center contact -> 81
    if json_load['data'].get('dc_name_81') and json_load['data'].get('dc_email_81'):
        dcc = ET.SubElement(root,ET.QName(ns_map['mmd'],'personnel'))
        ET.SubElement(dcc,ET.QName(ns_map['mmd'],'role')).text = 'Data center contact'
        ET.SubElement(dcc,ET.QName(ns_map['mmd'],'name')).text = json_load['data']['dc_name_81']
        ET.SubElement(dcc,ET.QName(ns_map['mmd'],'organisation')).text = ''
        ET.SubElement(dcc,ET.QName(ns_map['mmd'],'email')).text = json_load['data']['dc_email_81']

    # additiona personel composite
    if 'additional_personnel' in json_load['data']:
        adps = json_load['data']['additional_personnel']
        for adp in adps:
            p = ET.SubElement(root,ET.QName(ns_map['mmd'],'personnel'))
            ET.SubElement(p,ET.QName(ns_map['mmd'],'role')).text = role_mapping[adp['role']]
            ET.SubElement(p,ET.QName(ns_map['mmd'],'name')).text = adp['pname']
            ET.SubElement(p,ET.QName(ns_map['mmd'],'organisation')).text = adp['institution']
            ET.SubElement(p,ET.QName(ns_map['mmd'],'email')).text = adp['email']


    citation = ET.SubElement(root,ET.QName(ns_map['mmd'],'dataset_citation'))
    ET.SubElement(citation,ET.QName(ns_map['mmd'],'author')).text = json_load['data']['author_77'].strip()
    ET.SubElement(citation,ET.QName(ns_map['mmd'],'title')).text = json_load['data']['dc_title_77']
    ET.SubElement(citation,ET.QName(ns_map['mmd'],'publisher')).text = json_load['data']['publisher_77'].strip()
    ET.SubElement(citation,ET.QName(ns_map['mmd'],'publication_date')).text = json_load['data']['publication_date_77']
    if 'citation_url' in json_load['data']:
        ET.SubElement(citation,ET.QName(ns_map['mmd'],'doi')).text = json_load['data']['citation_url']['url']

    if json_load['data']['quality_statement'] != '':
        ET.SubElement(root,ET.QName(ns_map['mmd'],'quality_control')).text = quality_mapping[json_load['data']['quality_statement']]

    datacenter = ET.SubElement(root,ET.QName(ns_map['mmd'],'data_center'))
    datacentern = ET.SubElement(datacenter,ET.QName(ns_map['mmd'],'data_center_name'))
    ET.SubElement(datacentern,ET.QName(ns_map['mmd'],'short_name')).text = json_load['data']['datacenter_name_53']
    ET.SubElement(datacentern,ET.QName(ns_map['mmd'],'long_name')).text = json_load['data']['datacenter_name_53']
    if 'datacenter_url_53' in json_load['data']:
        ET.SubElement(datacenter,ET.QName(ns_map['mmd'],'data_center_url')).text = json_load['data']['datacenter_url_53']

    et.write(output_file, pretty_print=True, encoding='UTF-8',xml_declaration=True)

if __name__ == '__main__':
    # Parse command line arguments
    try:
        args = parse_arguments()
        print('file(s) to be parsed', args.input)

        for f in args.input:
            if not f.endswith('.json'):
                print('Input file must be a json: ', f)
                continue

            with open(f, 'r') as json_file:
                print('Parsing: ', f)
                json_load = json.load(json_file)
                output_file = f.replace('.json','.xml')
                create_mmd_mdform(json_load, f, output_file)
            json_file.close

    except Exception as e:
        print(e)
        sys.exit()


