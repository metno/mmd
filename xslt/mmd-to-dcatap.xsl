<?xml version="1.0" encoding="UTF-8"?>

<!--
This is a draft implementation for MMD to DCAT-AP conversion limited to the description of Dataset.
DCAT 3 supersedes DCAT 2 [VOCAB-DCAT-2], but it does not make it obsolete. DCAT 3 maintains the DCAT namespace as its terms preserve backward compatibility with DCAT 2
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcat="http://www.w3.org/ns/dcat#"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
    xmlns:odrs="http://schema.theodi.org/odrs#"
    xmlns:schema="http://schema.org/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mmd="http://www.met.no/schema/mmd"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:adms="http://www.w3.org/ns/adms#"
    xmlns:prov="http://www.w3.org/ns/prov"
    xmlns:mapping="http://www.met.no/schema/mmd/adms2mmd"
    version="1.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes" />
    <xsl:template match="/mmd:mmd">
        <xsl:element name="rdf:RDF">
            <xsl:copy-of select="document('')/xsl:stylesheet/namespace::*[name()!='xsl' and name()!='mapping' and name()!='mmd']"/>
            <xsl:copy-of select="document('')/*/@xsi:schemaLocation"/>
            <xsl:element name="dcat:Dataset">
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="mmd:related_information[mmd:type = 'Dataset landing page']/mmd:resource" />
                </xsl:attribute>

                <!--Mandatory for Dataset-->
                <xsl:apply-templates select="mmd:title" />
                <xsl:apply-templates select="mmd:abstract" />

                <!--Recommended for Dataset-->
                <!--TO DO: add contact point-->
                <xsl:apply-templates select="mmd:personnel[mmd:role='Metadata author']" />

                <!--distribution-->
                <xsl:for-each select="mmd:data_access">
                    <xsl:element name="dcat:distribution">
                        <xsl:element name="dcat:Distribution">
                            <xsl:apply-templates select="." />
                            <xsl:apply-templates select="../mmd:storage_information" />
                            <xsl:apply-templates select="../mmd:use_constraint" />
                            <xsl:apply-templates select="../mmd:access_constraint" />
                            <xsl:apply-templates select="../mmd:dataset_production_status[. != 'Planned' and . != 'Not available']" />
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
                <!--publisher-->
                <xsl:element name="dct:publisher">
                    <xsl:element name="foaf:Agent">
                        <xsl:element name="foaf:name">
                            <xsl:value-of select="mmd:dataset_citation/mmd:publisher"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>

                <xsl:apply-templates select="mmd:geographic_extent/mmd:rectangle" />
                <xsl:apply-templates select="mmd:temporal_extent" />
                <xsl:apply-templates select="mmd:iso_topic_category" />
                <xsl:apply-templates select="mmd:keywords" />

                <!--Optional for Dataset-->
                <!-- access rights -->
                <xsl:apply-templates select="mmd:access_constraint" />
                <!-- creator -->
                <xsl:apply-templates select="mmd:personnel[mmd:role='Investigator']" />
                <!-- documentation -->
                <xsl:apply-templates select="mmd:related_information[mmd:type != 'Dataset landing page']" />
                <!-- identifier -->
                <xsl:element name="dct:identifier">
                    <xsl:value-of select="mmd:metadata_identifier"/>
                </xsl:element>
                <!-- landing page -->
                <xsl:apply-templates select="mmd:related_information[mmd:type='Dataset landing page']" />
                <!-- language -->
                <xsl:apply-templates select="mmd:dataset_language" />
                <!-- issued -->
                <xsl:apply-templates select="mmd:dataset_citation/mmd:publication_date" />
                <!-- modified -->
                <xsl:apply-templates select="mmd:last_metadata_update" />
                <!-- project -->
                <xsl:apply-templates select="mmd:project" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!--Mandatory Properties for Dataset -->
    <xsl:template match="mmd:title">
        <xsl:element name="dct:title">
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="@xml:lang" />
            </xsl:attribute>
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <!--Mandatory Properties for Dataset -->
    <xsl:template match="mmd:abstract">
        <xsl:element name="dct:description">
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="@xml:lang" />
            </xsl:attribute>
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <!--Optional Properties for Dataset -->
    <xsl:template match="mmd:last_metadata_update">
        <xsl:element name="dct:modified">
            <xsl:attribute name="rdf:datatype">
                <xsl:text>https://www.w3.org/TR/xmlschema11-2/#dateTime</xsl:text>
            </xsl:attribute>
            <xsl:variable name="latest">
                <xsl:for-each select="mmd:update/mmd:datetime">
                    <xsl:sort select="." order="descending" />
                    <xsl:if test="position() = 1">
                        <xsl:value-of select="."/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="$latest"/>
        </xsl:element>
    </xsl:template>

    <!--Recommended Properties for Dataset -->
    <xsl:template match="mmd:keywords">
        <xsl:choose>
            <xsl:when test="@vocabulary = 'CFSTDN'">
                <xsl:for-each select="mmd:keyword">
                    <xsl:element name="dcat:theme">
                        <xsl:element name="skos:Concept">
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of select="concat('https://vocab.nerc.ac.uk/standard_name/', . )" />
                            </xsl:attribute>
                            <xsl:element name="skos:prefLabel">
                                <xsl:value-of select="." />
                            </xsl:element>
                            <xsl:element name="skos:inScheme">
                            <xsl:attribute name="rdf:resource">
                                <xsl:text>https://vocab.nerc.ac.uk/standard_name/</xsl:text>
                             </xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="mmd:keyword">
                    <xsl:element name="dcat:keyword">
                        <xsl:value-of select="." />
                    </xsl:element>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--Recommended Properties for Dataset -->
    <xsl:template match="mmd:temporal_extent">
        <xsl:element name="dct:temporal">
            <xsl:element name="dct:PeriodOfTime">
                <xsl:element name="dcat:startDate">
                          <xsl:attribute name="rdf:datatype">
                        <xsl:text>https://www.w3.org/TR/xmlschema11-2/#dateTime</xsl:text>
                          </xsl:attribute>
                    <xsl:value-of select="mmd:start_date" />
                </xsl:element>
                <!--if end_date is not present skip this element-->
                <xsl:if test="mmd:end_date !=''">
                    <xsl:element name="dcat:endDate">
                        <xsl:attribute name="rdf:datatype">
                            <xsl:text>https://www.w3.org/TR/xmlschema11-2/#dateTime</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="mmd:end_date" />
                    </xsl:element>
                </xsl:if>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mmd:iso_topic_category">
        <xsl:element name="dct:subject">
            <xsl:attribute name="rdf:resource">
                <xsl:value-of select="concat('http://inspire.ec.europa.eu/metadata-codelist/TopicCategory/', .)" />
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <!--Recommended Properties for Dataset -->
    <xsl:template match="mmd:geographic_extent/mmd:rectangle">

        <xsl:param name="north" select="mmd:north"/>
        <xsl:param name="east"  select="mmd:east"/>
        <xsl:param name="south" select="mmd:south"/>
        <xsl:param name="west"  select="mmd:west"/>

        <xsl:param name="WKTLiteral">
        POLYGON((<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>,<xsl:value-of select="$east"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>,<xsl:value-of select="$east"/><xsl:text> </xsl:text><xsl:value-of select="$south"/>,<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$south"/>,<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>))
        </xsl:param>

        <xsl:element name="dct:spatial">
            <xsl:element name="dct:Location">
                <xsl:element name="dcat:bbox">
                    <xsl:attribute name="rdf:datatype">
                        <xsl:text>http://www.opengis.net/ont/geosparql#wktLiteral</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="$WKTLiteral"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!--Optional Properties for Dataset -->
    <xsl:template match="mmd:access_constraint">
        <xsl:element name="dct:accessRights">
            <xsl:element name="dct:RightsStatement">
                <xsl:element name="rdfs:label">
                    <xsl:value-of select="." />
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mmd:related_information[mmd:type='Dataset landing page']">
        <xsl:element name="dcat:landingPage">
            <xsl:element name="foaf:Document">
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="mmd:resource" />
                </xsl:attribute>
                <xsl:element name="dct:description">
                    <xsl:value-of select="mmd:type" />
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mmd:related_information[mmd:type != 'Dataset landing page']">
        <xsl:element name="foaf:page">
            <xsl:element name="foaf:Document">
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="mmd:resource" />
                </xsl:attribute>
                <xsl:element name="dct:description">
                    <xsl:value-of select="mmd:type" />
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mmd:dataset_language">
        <xsl:element name="dct:language">
            <xsl:element name="dct:LinguisticSystem">
                <xsl:attribute name="rdf:about">
                    <xsl:choose>
                        <xsl:when test=". = 'en'">
                            <xsl:text>http://publications.europa.eu/resource/authority/language/ENG</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('https://id.loc.gov/vocabulary/iso639-1/',.,'.html')" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:element>
        </xsl:element>
    </xsl:template>


    <!--Mandatory element for Distribution accessURL-->
    <xsl:template match="mmd:data_access">
        <xsl:attribute name="rdf:about">
            <xsl:value-of select="mmd:resource" />
        </xsl:attribute>
        <xsl:element name="dct:description">
            <xsl:value-of select="mmd:description" />
        </xsl:element>
        <xsl:if test="mmd:type = 'OPeNDAP'">
            <xsl:element name="dcat:accessURL">
                <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="concat(mmd:resource, '.html')" />
                </xsl:attribute>
            </xsl:element>
        </xsl:if>

        <xsl:if test="mmd:type = 'HTTP'">
            <xsl:element name="dcat:accessURL">
                <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="mmd:resource" />
                </xsl:attribute>
            </xsl:element>
            <xsl:element name="dcat:downloadURL">
                <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="mmd:resource" />
                </xsl:attribute>
            </xsl:element>
        </xsl:if>

        <xsl:if test="mmd:type = 'OGC WMS'">
            <xsl:element name="dcat:accessURL">
                <xsl:attribute name="rdf:resource">
                    <xsl:choose>
                        <xsl:when test="contains(mmd:resource, '?')">
                            <xsl:value-of select="substring-before(mmd:resource, '?')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="mmd:resource"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:element>
            <xsl:element name="dcat:accessService">
                <xsl:element name="dcat:DataService">
                    <xsl:element name="dcat:endpointURL">
                        <xsl:attribute name="rdf:resource">
                            <xsl:choose>
                                <xsl:when test="contains(mmd:resource, '?')">
                                    <xsl:value-of select="substring-before(mmd:resource, '?')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="mmd:resource"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:element>
                    <xsl:element name="dcat:endpointDescription">
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="mmd:resource"/>
                        </xsl:attribute>
                    </xsl:element>
                    <xsl:element name="dct:title">
                        <xsl:value-of select="mmd:description" />
                    </xsl:element>
                    <xsl:element name="dct:conformsTo">
                        <xsl:element name="dct:Standard">
                            <xsl:attribute name="rdf:about">
                                <xsl:text>http://www.opengeospatial.org/standards/wms</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!--Recommended element for Distribution -->
    <xsl:template match="mmd:storage_information">
        <xsl:element name="dct:format">
            <xsl:element name="dct:MediaTypeOrExtent">
                <xsl:choose>
                    <xsl:when test="mmd:file_format = 'NetCDF-CF'">
                        <xsl:attribute name="rdf:about">
                            <xsl:text>http://publications.europa.eu/resource/authority/file-type/NETCDF</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="rdfs:label">
                            <xsl:value-of select="mmd:file_format" />
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!--Recommended element for Distribution -->
    <xsl:template match="mmd:use_constraint">
        <xsl:element name="dct:license">
            <xsl:element name="dct:LicenseDocument">
                <xsl:choose>
                    <xsl:when test="mmd:license_text != ''">
                        <rdfs:label xml:lang="en"><xsl:value-of select="mmd:license_text"/></rdfs:label>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="mmd:resource" />
                        </xsl:attribute>
                        <xsl:element name="foaf:name">
                            <xsl:value-of select="mmd:identifier" />
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:template>


    <!--The main researchers involved in producing the data-->
    <xsl:template match="mmd:personnel[mmd:role='Investigator']">
        <xsl:element name="dct:creator">
            <xsl:element name="foaf:Agent">
                <xsl:element name="foaf:name">
                    <xsl:value-of select="mmd:name" />
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!--This property contains contact information that  can  be  used  for  sending  comments about the Dataset. -->
    <xsl:template match="mmd:personnel[mmd:role='Metadata author']">
        <xsl:element name="dcat:contactPoint">
            <xsl:element name="vcard:Kind">
                <xsl:element name="vcard:fn">
                    <xsl:attribute name="xml:lang">
                        <xsl:text>en</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="mmd:organisation" />
                </xsl:element>
                <xsl:element name="vcard:hasEmail">
                    <xsl:attribute name="rdf:resource">
                       <xsl:value-of select="concat('mailto:',mmd:email)" />
                    </xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>


    <!--Optional Properties for Distribution -->
    <xsl:template match="mmd:dataset_production_status">
        <xsl:variable name="mmd_status" select="normalize-space(.)" />
        <xsl:variable name="mmd_status_mapping" select="document('')/*/mapping:dataset_status[@mmd=$mmd_status]/@adms" />
        <xsl:element name="adms:status">
            <xsl:element name="skos:Concept">
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="concat('http://purl.org/adms/status/',$mmd_status_mapping)" />
                </xsl:attribute>
                <xsl:element name="skos:prefLabel">
                    <xsl:value-of select="$mmd_status_mapping" />
                </xsl:element>
                <xsl:element name="skos:inScheme">
                    <xsl:attribute name="rdf:resource">
                        <xsl:text>http://purl.org/adms/status</xsl:text>
                    </xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>


    <!--Optional Properties for Dataset -->
    <xsl:template match="mmd:dataset_citation/mmd:publication_date">
        <xsl:element name="dct:issued">
            <xsl:attribute name="rdf:datatype">
                <xsl:text>https://www.w3.org/TR/xmlschema11-2/#date</xsl:text>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mmd:project">
        <xsl:element name="prov:wasGeneratedBy">
            <xsl:element name="prov:Activity">
                <xsl:element name="rdfs:label">
                    <xsl:choose>
                        <xsl:when test="mmd:short_name != ''">
                            <xsl:value-of select="concat(mmd:long_name,' (',mmd:short_name,')')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="mmd:long_name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template name="tokenize">
        <xsl:param name="author"/>
        <xsl:choose>
            <xsl:when test="contains($author, ',')">
                <xsl:element name="creator">
                    <xsl:element name="creatorName">
                        <!--xsl:attribute name="nameType">Personal</xsl:attribute-->
                        <xsl:value-of select="normalize-space(substring-before($author, ','))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:call-template name="tokenize">
                    <xsl:with-param name="author" select="normalize-space(substring-after($author, ','))"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="creator">
                    <xsl:element name="creatorName">
                    <!--xsl:attribute name="nameType">Personal</xsl:attribute-->
                        <xsl:value-of select="normalize-space($author)"/>
                    </xsl:element>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
     </xsl:template>

    <!-- Mappings for dataset_production_status -->
    <mapping:dataset_status adms="Completed" mmd="Complete" />
    <mapping:dataset_status adms="Deprecated" mmd="Obsolete" />
    <mapping:dataset_status adms="UnderDevelopment" mmd="In Work" />
</xsl:stylesheet>
