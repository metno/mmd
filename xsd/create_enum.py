#!/usr/bin/env python
# coding: utf-8

from rdflib import Graph, Variable, URIRef
from rdflib.namespace import SKOS, RDF
import lxml.etree as ET

#Simple lists:
#'Keywords Vocabulary', -> keywords_vocabulary_enum
#'Spatial Representation', -> spatial_representation_enum
#'Dataset Production Status', -> mmd:dataset_production_status_enum
#'Metadata Source', -> mmd:metadata_source
#'Activity Type', -> activity_type_enum
#'ISO Topic Category', -> iso_topic_category_enum
#'Related Information Types', -> related_information_types_enum
#'Data Access Types', -> data_access_types_enum
#'Access Constraint', -> access_constraint_enum
#'Operational Status', -> operational_status_enum
#'Collection Keywords', -> mmd:collection_keywords_enum
#'Instrument Modes', -> instrument_modes_enum
#'Polarisation Modes', -> polarisaion_modes_enum
#'Product Types', -> product_types_enum
#'Contact Roles', -> contact_roles_enum
#'Contact Types', -> contact_types_enum
#'Quality Control' -> quality_control_enum

# indentifier and resource lists:
#'Use Constraint'

# skipping
# short_name, long_name and resource lists:
#'Platform',
#'Instrument',
#'Organisation',
#'Geographical Areas'


exclude = ["Organisation", "Platform", "Instrument", "Geographical Areas"]

#get all collection excluding some if necessary
def query_collections(g, exclude):

    filtercoll = ""
    for exc in exclude:
        filtercoll += "FILTER (STR(?prefLabel) != \"" + exc + "\") .\n"

    query = '''
        SELECT distinct ?prefLabel ?definition
        WHERE {
            ?collection rdf:type skos:Collection .
            ?collection skos:prefLabel ?prefLabel .
            OPTIONAL {?collection skos:definition ?definition} .
            FILTER (LANG(?prefLabel) = "en") .
            ''' + filtercoll +'''
        }
    '''

    results = g.query(query)
    #collections["prefLabel"] = "definition"
    collections = {}
    for row in results:
        if row.prefLabel is not None:
            label = row.prefLabel.value
        else:
            label = row.prefLabel
        if row.definition is not None:
            definition = row.definition.value
        else:
            definition = row.definition
        collections[label] = definition
    return(collections)

#get concepts per collection
def query_members(g, collection):

    query = '''
        SELECT distinct ?prefLabel ?definition
        WHERE {
            ?collection skos:prefLabel \'''' + collection +'''\'@en .
            ?collection skos:member ?member .
            ?member skos:prefLabel ?prefLabel .
            FILTER (LANG(?prefLabel) = "en")
            OPTIONAL {?member skos:definition ?definition} .
        }
    '''

    #members = [{preflabel: {'altLabel': [altlabels], 'definition':'definition'}]
    results = g.query(query)

    members = []
    for row in results:
        preflabel = row.prefLabel.value
        altlabels = query_altLabels(g, preflabel)
        if row.definition is not None:
            definition = row.definition.value
        else:
            definition = row.definition
        if collection == 'Use Constraint':
            spdx = query_spdxresource(g, preflabel)
            members.append({preflabel: {'altLabel' : altlabels, 'definition': definition, 'resource': spdx}})
        elif collection == 'Keywords Vocabulary':
            res_kvoc = query_kvocsource(g, preflabel)
            members.append({preflabel: {'altLabel' : altlabels, 'definition': definition, 'resource': res_kvoc}})
        elif collection == 'Platform' or collection == 'Instrument':
            wmo = query_wmoresource(g, preflabel)
            members.append({preflabel: {'altLabel' : altlabels, 'definition': definition, 'resource': wmo}})
        else:
            members.append({preflabel: {'altLabel' : altlabels, 'definition': definition}})
    return(members)

#get altLabel
def query_altLabels(g, prefLabel):

    query = '''
        SELECT distinct ?altLabel
        WHERE {
            ?concept skos:prefLabel \'''' + prefLabel +'''\'@en .
            ?concept skos:altLabel ?altLabel .
            FILTER (lang(?altLabel) = "en") .
        }
    '''

    results = g.query(query)
    altlabels = []
    for row in results:
        if row.altLabel is not None:
            altlabels.append(row.altLabel.value)
        else:
            altlabels.append(row.altLabel)
    return(altlabels)

#get spdx resource
def query_spdxresource(g, prefLabel):

    query = '''
        SELECT distinct ?resource
        WHERE {
            ?concept skos:prefLabel \'''' + prefLabel +'''\'@en .
            ?concept skos:exactMatch ?resource .
            FILTER (CONTAINS(STR(?resource), "spdx")) .

        }
    '''

    results = g.query(query)
    for row in results:
        if row.resource is not None:
            resource = str(row.resource)
        else:
            resource = row.resource
    return(resource)

#get vocabulary resource for keywords attribute vocabulary
def query_kvocsource(g, prefLabel):

    query = '''
        SELECT distinct ?resource
        WHERE {
            ?concept skos:prefLabel \'''' + prefLabel +'''\'@en .
            ?concept rdfs:seeAlso ?resource .

        }
    '''
    results = g.query(query)
    if len(results) != 0:
        for row in results:
            if row.resource is not None:
                resource = str(row.resource)
            else:
                resource = row.resource
    else:
        resource = '-'
    return(resource)

#get wmo platform and instrument resource
def query_wmoresource(g, prefLabel):

    query = '''
        SELECT distinct ?resource
        WHERE {
            ?concept skos:prefLabel \'''' + prefLabel +'''\'@en .
            ?concept rdfs:seeAlso ?resource .
            FILTER (CONTAINS(STR(?resource), "wmo")) .

        }
    '''

    results = g.query(query)
    for row in results:
        if row.resource is not None:
            resource = str(row.resource)
        else:
            resource = row.resource
    return(resource)

#create enumeration for all collections
def create_enumerations(full_voc, collections):
    mynsmap = {'xml': "http://www.w3.org/XML/1998/namespace",
            'xs' : "http://www.w3.org/2001/XMLSchema"}

    root = ET.Element(ET.QName(mynsmap['xs'], 'schema'), nsmap=mynsmap)
    root.set('elementFormDefault', "qualified")
    root.set('targetNamespace', "http://www.met.no/schema/mmd")
    root.set('xmlns', "http://www.met.no/schema/mmd")
    comment_text = ET.Comment("DO NOT EDIT THIS FILE. This is automcatically generated running the create_enum.py script in this folder.")
    root.append(comment_text)
    for k,v in full_voc.items():
        if k == 'Use Constraint':
            root = get_id_res_lists(k,v,collections, root, mynsmap)
        elif k == 'Platform' or k == 'Instrument':
            root = get_short_long_res(k, v, collections, root, mynsmap)
        else:
            root = get_simple_list(k, v, collections, root, mynsmap)

    schema = ET.ElementTree(root)
    schema.write("enum_mmd.xsd", pretty_print=True,xml_declaration=True, encoding='utf-8')

    return

#simple enumeration list
def get_simple_list(k, v, collections, root, mynsmap):
    st = ET.SubElement(root,ET.QName(mynsmap['xs'],'simpleType'))
    st.set('name',k.lower().replace(" ", "_")+"_enum")

    annotation = ET.SubElement(st,ET.QName(mynsmap['xs'],'annotation'))
    doc = ET.SubElement(annotation,ET.QName(mynsmap['xs'],'documentation'))
    doc.text = collections[k]
    restriction = ET.SubElement(st,ET.QName(mynsmap['xs'],'restriction'))
    restriction.set('base', "xs:string")
    for valid in v:
        for label in valid.keys():
            enumeration = ET.SubElement(restriction,ET.QName(mynsmap['xs'],'enumeration'))
            enumeration.set('value', label)
    return(root)


#identifier and resources lists
def get_id_res_lists(k,v,collections, root, mynsmap):
    st = ET.SubElement(root,ET.QName(mynsmap['xs'],'simpleType'))
    st.set('name',k.lower().replace(" ", "_") + '_identifier_enum')

    annotation = ET.SubElement(st,ET.QName(mynsmap['xs'],'annotation'))
    doc = ET.SubElement(annotation,ET.QName(mynsmap['xs'],'documentation'))
    doc.text = collections[k]
    restriction = ET.SubElement(st,ET.QName(mynsmap['xs'],'restriction'))
    restriction.set('base', "xs:string")
    for valid in v:
        for label in valid.keys():
            enumeration = ET.SubElement(restriction,ET.QName(mynsmap['xs'],'enumeration'))
            enumeration.set('value', label)
    #support http and https
    prot = ['http', 'https']
    membertypes = []
    for p in prot:
        st = ET.SubElement(root,ET.QName(mynsmap['xs'],'simpleType'))
        membertype = k.lower().replace(" ", "_") + '_resource_' + p
        st.set('name', membertype)
        annotation = ET.SubElement(st,ET.QName(mynsmap['xs'],'annotation'))
        doc = ET.SubElement(annotation,ET.QName(mynsmap['xs'],'documentation'))
        doc.text = collections[k] + " These are the resources (" + p +  ") related to the "+ k + " identifiers"
        restriction = ET.SubElement(st,ET.QName(mynsmap['xs'],'restriction'))
        restriction.set('base', "xs:string")
        for valid in v:
            for ref in valid.values():
                enumeration = ET.SubElement(restriction,ET.QName(mynsmap['xs'],'enumeration'))
                resource = p + '://' + ref['resource'].split('://')[1]
                enumeration.set('value', resource)
        membertypes.append(membertype)

    #create union
    st = ET.SubElement(root,ET.QName(mynsmap['xs'],'simpleType'))
    st.set('name',k.lower().replace(" ", "_") + '_resource_enum')
    union = ET.SubElement(st,ET.QName(mynsmap['xs'],'union'))
    union.set('memberTypes',' '.join(membertypes))


    return(root)

#short name, long name (altLabel) and resource
def get_short_long_res(k, v, collections, root, mynsmap):
    #short name
    st = ET.SubElement(root,ET.QName(mynsmap['xs'],'simpleType'))
    st.set('name',k.lower().replace(" ", "_") + '_short_name')

    annotation = ET.SubElement(st,ET.QName(mynsmap['xs'],'annotation'))
    doc = ET.SubElement(annotation,ET.QName(mynsmap['xs'],'documentation'))
    doc.text = collections[k]
    restriction = ET.SubElement(st,ET.QName(mynsmap['xs'],'restriction'))
    restriction.set('base', "xs:string")
    for valid in v:
        for label in valid.keys():
            enumeration = ET.SubElement(restriction,ET.QName(mynsmap['xs'],'enumeration'))
            enumeration.set('value', label)
    #long name
    st = ET.SubElement(root,ET.QName(mynsmap['xs'],'simpleType'))
    st.set('name',k.lower().replace(" ", "_") + '_long_name')
    annotation = ET.SubElement(st,ET.QName(mynsmap['xs'],'annotation'))
    doc = ET.SubElement(annotation,ET.QName(mynsmap['xs'],'documentation'))
    doc.text = collections[k] + " These are the long name valid values related to the " + collections[k] + " short_name"
    restriction = ET.SubElement(st,ET.QName(mynsmap['xs'],'restriction'))
    restriction.set('base', "xs:string")
    for valid in v:
        for ref in valid.values():
            enumeration = ET.SubElement(restriction,ET.QName(mynsmap['xs'],'enumeration'))
            enumeration.set('value', ref['altLabel'][0])

    #resource
    st = ET.SubElement(root,ET.QName(mynsmap['xs'],'simpleType'))
    st.set('name',k.lower().replace(" ", "_") + '_resource')
    annotation = ET.SubElement(st,ET.QName(mynsmap['xs'],'annotation'))
    doc = ET.SubElement(annotation,ET.QName(mynsmap['xs'],'documentation'))
    doc.text = collections[k] + " These are the resource valid values related to the " + collections[k] + " short_name"
    restriction = ET.SubElement(st,ET.QName(mynsmap['xs'],'restriction'))
    restriction.set('base', "xs:string")
    for valid in v:
        for ref in valid.values():
            enumeration = ET.SubElement(restriction,ET.QName(mynsmap['xs'],'enumeration'))
            enumeration.set('value', ref['resource'])


    return(root)

#prepare programmatic creation of adoc documentation
def create_ch04_adoc(full_voc, collections):
    adoc_table = "[[controlled-vocabularies]]\n== Controlled vocabularies\n\n"
    adoc_table += "//DO NOT EDIT THIS FILE. It is created automatically using ../xsd/create_enum.py\n\n"

    for k in full_voc.keys():
        if k == 'Use Constraint' or k == 'Keywords Vocabulary':
            if k == 'Use Constraint':
                column_tags = ["code identifier", "code resource", "definition"]
                size = "[cols=\"2,5,8\"]\n"
            if k == 'Keywords Vocabulary':
                column_tags = ["code", "resource", "definition"]
                size = "[cols=\"3,6,8\"]\n"
            link = "[["+k.lower().replace(" ", "-")+"]]\n"
            title = "=== " + k + "\n\n"
            definition = collections[k] + "\n\n"
            space = "|===\n"
            header = "| " + " | ".join(column_tags) + "\n\n"
            adoc_table += link + title + definition + size + space + header

            for members in full_voc[k]:
                rows = []
                for l,d in members.items():
                    #print(l)
                    rows.append(f"| {l}| {d['resource']} | {d['definition']}")

                    table_content = "\n".join(rows)+"\n"

                adoc_table += table_content + "\n"

        elif k == 'Platform' or k == 'Instrument':
            column_tags = ["code short_name", "code long_name", "code resource"]
            link = "[["+k.lower().replace(" ", "-")+"]]\n"
            title = "=== " + k + "\n\n"
            definition = collections[k] + "\n\n"
            size = "[cols=\"2,5,8\"]\n"
            space = "|===\n"
            header = "| " + " | ".join(column_tags) + "\n\n"
            adoc_table += link + title + defintion + size + space + header

            for members in full_voc[k]:
                rows = []
                for l,d in members.items():
                    #print(l)
                    rows.append(f"| {l}| {d['altLabel'][0]} | {d['resource']}")

                    table_content = "\n".join(rows)+"\n"

                adoc_table += table_content + "\n"

        else:
            column_tags = ["code", "definition"]
            link = "[["+k.lower().replace(" ", "-")+"]]\n"
            title = "=== " + k + "\n\n"
            definition = collections[k] + "\n\n"
            size = "[cols=\"2,8\"]\n"
            space = "|===\n"
            header = "| " + " | ".join(column_tags) + "\n\n"
            adoc_table += link + title + definition + size + space + header


            for members in full_voc[k]:
                rows = []
                for l,d in members.items():
                    #print(l)
                    rows.append(f"| {l}| {d['definition']}")

                    table_content = "\n".join(rows)+"\n"

                adoc_table += table_content + "\n"

        adoc_table += "|===\n\n"
        adoc_table += "<<"+k.lower().replace(" ", "_")+">>\n\n"

    try:
        with open("../doc/ch04-md-contrvocabs.adoc", 'w', encoding='utf-8') as f:
            f.write(adoc_table)
    except IOError as e:
        print(f"Error saving file: {e}")
    return

def main():
    try:
        #load vocabulary
        g = Graph()
        g.parse("../thesauri/mmd-vocabulary.ttl", format="ttl")
        #fetch all collections
        collections = query_collections(g, exclude)
        #fetch all members
        full_voc = {}
        for k in collections.keys():
            full_voc[k] = query_members(g, k)
        #create enumeration schema file
        create_enumerations(full_voc,collections)
        #create adoc documentation file.
        create_ch04_adoc(full_voc, collections)
    except:
        print("Something failed creating the controlled vocabulary schema and/or documentation")

if __name__ == '__main__':
    main()


