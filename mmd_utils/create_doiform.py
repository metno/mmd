#!/usr/bin/python3
import sys
import os
import argparse
from datetime import datetime
import lxml.etree as ET
from rdflib import Graph, URIRef
from rdflib.namespace import SKOS, RDF

def parse_arguments():
    parser = argparse.ArgumentParser(
    formatter_class=argparse.RawDescriptionHelpFormatter,
            description='Creates a ready to upload XML for datacite. Inputs are: \n'+
            'input: the file to generate the record for\n')
    parser.add_argument("input", help='The input file to extract metadata from')
    parser.add_argument("output", help='The output file to dump metadata to')
    parser.add_argument("-n", "--parsenames", help='Parse First/Last Name instead of generic type. This is if the Last name is the last split of the string', action='store_true')
    parser.add_argument("-c", "--collection", help='Specify if the DOI should be minted for a resourceType Collection. If not provided the default is Dataset', action='store_true')

    try:
        args = parser.parse_args()
    except:
        sys.exit()
    return args

def get_organisations(organisation):
    script_dir = os.path.dirname(__file__)
    relative_path_to_file = os.path.join('../thesauri', 'mmd-vocabulary.xml')
    thesauri_file_path = os.path.join(script_dir, relative_path_to_file)
    g = Graph()
    g.parse(thesauri_file_path, format="xml")

    query = '''
    SELECT distinct ?label ?exactMatch
    WHERE {
        ?collection skos:prefLabel "Organisation"@en .
        ?collection skos:member ?member .
        {?member skos:prefLabel \'''' + organisation + '''\'@en . }
        UNION
        {?member skos:prefLabel \'''' + organisation + '''\'@nb . }
        UNION
        {?member skos:altLabel \'''' + organisation + '''\'@en . }
        UNION
        {?member skos:altLabel \'''' + organisation + '''\'@nb . }
        UNION
        {?member skos:hiddenLabel \'''' + organisation + '''\'@en . }
        UNION
        {?member skos:hiddenLabel \'''' + organisation + '''\'@nb . }
        ?member skos:exactMatch ?exactMatch .
        ?member skos:prefLabel ?label .
        FILTER (LANG(?label) = "en") .
        }
    '''

    results = g.query(query)
    if len(results) > 2:
        print('More the one result for organisation. Something is wrong. Check!')
        return None
    elif len(results) == 0:
        print('No match found for org')
        return None
    else:
        org = {}
        for row in results:
            print('ROR ', row.exactMatch, ' found for organisation', organisation)
            org = {'prefLabel' : row.label.value, 'ror': row.exactMatch}
        return org

def check_prefLabel(ror):

    script_dir = os.path.dirname(__file__)
    relative_path_to_file = os.path.join('../thesauri', 'mmd-vocabulary.xml')
    thesauri_file_path = os.path.join(script_dir, relative_path_to_file)
    g = Graph()
    g.parse(thesauri_file_path, format="xml")

    uri = URIRef(ror)

    query = '''
    SELECT distinct ?label
    WHERE {
        ?collection skos:prefLabel "Organisation"@en .
        ?collection skos:member ?member .
        ?member skos:exactMatch <'''+str(uri)+'''>  .
        ?member skos:prefLabel ?label .
        FILTER (LANG(?label) = "en") .
        }
    '''

    results = g.query(query)

    if len(results) > 1:
        print('More the one result for ror found. Something is wrong. Check!')
        return None
    elif len(results) == 0:
        print('No match found')
        return None
    else:
        org = {}
        for row in results:
            print('prefLabel ', row.label.value, 'found for ROR', ror)
            org = {'prefLabel' : row.label.value, 'ror' : ror }
        return org

def create_dataciteXML(inputfile, outputfile, parsenames, collection):

    attr_qname = ET.QName("http://www.w3.org/2001/XMLSchema-instance", "schemaLocation")

    nsmap = {None: "http://datacite.org/schema/kernel-4",
             "xsi": "http://www.w3.org/2001/XMLSchema-instance",
             "mmd": "http://www.met.no/schema/mmd"}

    root = ET.Element("resource",
                     {attr_qname: "http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4.6/metadata.xsd"},
                     nsmap=nsmap)

    mmd = ET.parse(inputfile)
    mmdroot = mmd.getroot()

    #check identifier and GET URI to add in the form
    print("================== metadata_id and URL =================")
    metadata_id =  mmdroot.find("mmd:metadata_identifier", mmdroot.nsmap)
    if metadata_id is not None and ('no.met' in metadata_id.text or 'no.met.adc' in metadata_id.text):
        print("metadata identifier", metadata_id.text)
        commentid = ET.Comment("metadata_identifier: "+metadata_id.text)
        root.append(commentid)
    else:
        print("metadata identifier not provided. Check if this is ready to be published.")

    url =  mmdroot.find("mmd:related_information/[mmd:type ='Dataset landing page']/mmd:resource", mmdroot.nsmap)
    urlprovided = False
    if url is not None and ('data.met.no' in url.text or 'adc.met.no' in url.text):
        print("URL to add", url.text)
        commenturl = ET.Comment("URL: "+url.text)
        root.append(commenturl)
        urlprovided = True
    else:
        print("URL not provided.")
    print("========================================================")


    identifier = ET.SubElement(root, 'identifier')
    identifier.set('identifierType', 'DOI')
    creators = ET.SubElement(root,'creators')
    #personnel
    investigators =  mmdroot.findall("mmd:personnel/[mmd:role ='Investigator']", mmdroot.nsmap)
    print("Parsing Investigators. Found ", len(investigators))
    if len(investigators) < 1:
        print("No creators. Exiting.")
        sys.exit()
    #get elements
    for investigator in investigators:
        #type
        nametype = investigator.find("mmd:type", mmdroot.nsmap)
        if nametype is not None:
            nametype = nametype.text
        #name, uri, fist/last
        nameet = investigator.find("mmd:name", mmdroot.nsmap)
        name = nameet.text
        name_uri = nameet.get("uri")
        first_name = name.rsplit(" ",1)[0]
        family_name = name.rsplit(" ",1)[-1]
        #organisation, uri
        organisationet = investigator.find("mmd:organisation", mmdroot.nsmap)
        organisation = organisationet.text
        organisation_uri = organisationet.get("uri")
        info = {'type': nametype, 'name' : name, 'name_uri' : name_uri, 'first_name' : first_name, 'family_name' : family_name, 'organisation' : organisation, 'organisation_uri' : organisation_uri}
        print('===========')
        print('Parsing: ', info)

        creator = ET.SubElement(creators,'creator')
        if name is not None:
            creatorn = ET.SubElement(creator,'creatorName')
            #work with type or uri if given
            if nametype is None:
                if name_uri is not None:
                    if 'orcid.org' in name_uri:
                        creatorn.text = family_name + ', '+ first_name
                        creatorn.set("nameType","Personal")
                        given = ET.SubElement(creator,'givenName')
                        given.text = first_name
                        family = ET.SubElement(creator,'familyName')
                        family.text = family_name
                        nameIdentifier = ET.SubElement(creator, 'nameIdentifier')
                        nameIdentifier.set('schemeURI',"http://orcid.org/")
                        nameIdentifier.set('nameIdentifierScheme',"ORCID")
                        nameIdentifier.text = name_uri.split("://orcid.org/")[1]
                    elif 'ror.org' in name_uri:
                        creatorn.text = name
                        creatorn.set("nameType","Organizational")
                        nameIdentifier = ET.SubElement(creator, 'nameIdentifier')
                        nameIdentifier.set('schemeURI',"http://ror.org/")
                        nameIdentifier.set('nameIdentifierScheme',"ROR")
                        nameIdentifier.text = name_uri.split("://ror.org/")[1]
                    else:
                        print("Could not parse uri. Check input.")
                        sys.exit()
                else:
                    if parsenames == True:
                        creatorn.text = family_name + ', '+ first_name
                        creatorn.set("nameType","Personal")
                        given = ET.SubElement(creator,'givenName')
                        given.text = first_name
                        family = ET.SubElement(creator,'familyName')
                        family.text = family_name
                    else:
                        print('Parsing name is not requested. First/Last name are not used. Run with -n for splitting names')
                        creatorn.text = name
            else:
                if nametype == 'Organisation':
                    creatorn.text = name
                    creatorn.set("nameType","Organizational")
                    if name_uri is not None:
                        if 'ror.org' in name_uri:
                            nameIdentifier = ET.SubElement(creator, 'nameIdentifier')
                            nameIdentifier.set('schemeURI',"http://ror.org/")
                            nameIdentifier.set('nameIdentifierScheme',"ROR")
                            nameIdentifier.text = name_uri.split("://ror.org/")[1]
                        else:
                            print("Type Organisation and uri are inconsistent. Check input")
                            sys.exit()
                else:
                    creatorn.text = family_name + ', '+ first_name
                    creatorn.set("nameType","Personal")
                    given = ET.SubElement(creator,'givenName')
                    given.text = first_name
                    family = ET.SubElement(creator,'familyName')
                    family.text = family_name
                    if name_uri is not None:
                        if 'orcid.org' in name_uri:
                            nameIdentifier = ET.SubElement(creator, 'nameIdentifier')
                            nameIdentifier.set('schemeURI',"http://orcid.org/")
                            nameIdentifier.set('nameIdentifierScheme',"ORCID")
                            nameIdentifier.text = name_uri.split("://orcid.org/")[1]
                        else:
                            print("Type Person and uri are inconsistent. Check input")
                            sys.exit()
        else:
            print('No creator name found')
            sys.exit()

        if organisation is not None:
            #try ror
            if organisation_uri is not None and 'ror.org' in organisation_uri:
                #check preferred label from vocab
                ror = check_prefLabel(organisation_uri)
                #keep original values
                if ror is None:
                   ror  = {'prefLabel' : organisation, 'ror' : organisation_uri }
            else:
                ror = get_organisations(organisation)
            if ror is not None and 'ror.org' in ror['ror']:
                print("Adding ROR ", ror['ror'], " to affiliation")
                affiliation = ET.SubElement(creator,'affiliation')
                affiliation.text = ror['prefLabel']
                affiliation.set('affiliationIdentifier', ror['ror'])
                affiliation.set('affiliationIdentifierScheme', 'ROR')
                affiliation.set("schemeURI", "https://ror.org")
            else:
                ET.SubElement(creator,'affiliation').text = organisation
        else:
            print('No organisation found')

    titles = ET.SubElement(root, 'titles')
    titleen =  mmdroot.find("mmd:title[@{http://www.w3.org/XML/1998/namespace}lang = 'en']", namespaces = nsmap)
    if titleen is not None and titleen.text is not None:
        print("===================")
        print("Setting title to: ", titleen.text)
        ET.SubElement(titles, 'title').text = titleen.text
    else:
        print('Title not found. Exiting')
        sys.exit()

    publisher = ET.SubElement(root, 'publisher')
    publisher.text = "Norwegian Meteorological Institute"
    publisher.set("publisherIdentifier", "https://ror.org/001n36p86")
    publisher.set("publisherIdentifierScheme", "ROR")
    publisher.set("schemeURI", "https://ror.org")

    current_year = datetime.now().year
    ET.SubElement(root, 'publicationYear').text = str(current_year)

    resourcetype = ET.SubElement(root, 'resourceType')
    print("===================")
    if collection == True:
        print("Setting resourceType to Collection")
        resourcetype.text = "Collection"
        resourcetype.set("resourceTypeGeneral", "Collection")
    else:
        print("Setting resourceType to Dataset")
        resourcetype.text = "Dataset"
        resourcetype.set("resourceTypeGeneral", "Dataset")
    print("===================")

    licenseid =  mmdroot.find("mmd:use_constraint/mmd:identifier", mmdroot.nsmap)
    licenseres =  mmdroot.find("mmd:use_constraint/mmd:resource", mmdroot.nsmap)
    if licenseid is not None:
        rightslist = ET.SubElement(root, 'rightsList')
        rights = ET.SubElement(rightslist, 'rights')
        rights.set('rightsURI', "https://spdx.org/licenses/")
        rights.set('rightsIdentifierScheme', "SPDX")
        rights.set('rightsIdentifier', licenseid.text)
        rights.set('rightsURI', licenseres.text)


    et = ET.ElementTree(root)
    #input path and no output
    try:
        et.write(outputfile, pretty_print=True)
        if urlprovided is False:
            print("This record cannot be registered without a URL. A landing page for the record was not provided.")
    except:
        print('Could not write doiupload file')

    return

if __name__ == '__main__':
    # Parse command line arguments
    try:
        args = parse_arguments()
        print(args)
        if args.input is None:
            print("No input specified")
            sys.exit()
        if args.output is None:
            print("No output specified")
            sys.exit()
        if args.parsenames == True:
            parsenames = True
        else:
            parsenames = False
        if args.collection == True:
            collection = True
        else:
            collection = False
    except Exception as e:
        print(e)
        sys.exit()

    # Process file
    try:
        create_dataciteXML(args.input, args.output, parsenames, collection)
        print("================== NOTE =================")
        print("== Check before sumbitting to datacite ==")
    except Exception as e:
        print(e)
        sys.exit()

