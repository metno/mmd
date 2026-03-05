<?xml version="1.0" encoding="UTF-8"?>
<!--
Draft implementation of dcat to mmd mapping
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mmd="http://www.met.no/schema/mmd"
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcat="http://www.w3.org/ns/dcat#"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:org="http://www.w3.org/ns/org#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
    xmlns:schema="http://schema.org/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:locn="http://www.w3.org/ns/locn#"
    xmlns:adms="http://www.w3.org/ns/adms#"
    xmlns:dif="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/"
    version="1.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:variable name="isoLUD" select="document('../thesauri/mmd-vocabulary.xml')"/>
    <xsl:key name="usec" match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/Use_Constraint']/skos:member/skos:Concept" use="skos:prefLabel"/>
    <xsl:key name="useca" match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/Use_Constraint']/skos:member/skos:Concept" use="skos:altLabel"/>
    <xsl:key name="usecexact" match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/Use_Constraint']/skos:member/skos:Concept/skos:exactMatch" use="substring-after(@rdf:resource, '://')"/>
    <xsl:template match="/rdf:RDF">
        <xsl:element name="mmd:mmd">
            <xsl:apply-templates select="dcat:Dataset"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="dcat:Dataset">
        <xsl:apply-templates select="dct:identifier"/>
        <xsl:apply-templates select="dct:title"/>
        <xsl:apply-templates select="dct:description"/>
        <xsl:element name="mmd:metadata_status">
            <xsl:text>Active</xsl:text>
        </xsl:element>
        <xsl:element name="mmd:dataset_production_status">
            <xsl:text>Not available</xsl:text>
        </xsl:element>
        <xsl:element name="mmd:collection">
            <xsl:text>ADC</xsl:text>
        </xsl:element>
        <xsl:element name="mmd:last_metadata_update">
            <xsl:if test="dct:issued">
                <xsl:element name="mmd:update">
                    <xsl:element name="mmd:datetime">
                        <xsl:value-of select="dct:issued"/>
                    </xsl:element>
                    <xsl:element name="mmd:type">
                        <xsl:text>Created</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            <xsl:if test="dct:modified">
                <xsl:element name="mmd:update">
                    <xsl:element name="mmd:datetime">
                        <xsl:value-of select="dct:modified"/>
                    </xsl:element>
                    <xsl:element name="mmd:type">
                        <xsl:text>Major modification</xsl:text>
                    </xsl:element>
                    <xsl:element name="mmd:note">
                        <xsl:text>Information caputured from DCAT record</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:element>
        <xsl:apply-templates select="dct:temporal"/>
        <xsl:element name="mmd:iso_topic_category">
            <xsl:text>Not available</xsl:text>
        </xsl:element>
        <xsl:element name="mmd:keywords">
            <xsl:attribute name="vocabulary">None</xsl:attribute>
            <xsl:for-each select="dcat:keyword">
                <xsl:element name="mmd:keyword">
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:for-each>
            <xsl:for-each select="schema:variableMeasured">
                <xsl:element name="mmd:keyword">
                    <xsl:value-of select="schema:PropertyValue/schema:name"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
        <xsl:apply-templates select="dcat:contactPoint"/>
        <!--create also investigator, unique in dcat-->
        <xsl:if test="dct:creator/foaf:Agent">
            <xsl:element name="mmd:personnel">
                <xsl:element name="mmd:role">
                    <xsl:text>Investigator</xsl:text>
                </xsl:element>
                <xsl:element name="mmd:name">
                    <xsl:value-of select="dct:creator/foaf:Agent/foaf:name"/>
                </xsl:element>
                <xsl:element name="mmd:email">
                    <xsl:value-of select="dct:creator/foaf:Agent/foaf:mbox"/>
                </xsl:element>
                <xsl:element name="mmd:organization">
                    <xsl:value-of select="dct:creator/foaf:Agent/org:memberOf/foaf:Organization/foaf:name"/>
                </xsl:element>
            </xsl:element>
        </xsl:if>
        <xsl:for-each select="dcat:distribution">
            <xsl:apply-templates select="dcat:Distribution"/>
        </xsl:for-each>
        <!--in dcat license apply to distribution not dataset. We can't get the use_constraint in mmd -->
        <!--xsl:element name="mmd:dataset_citation">
            <xsl:element name="mmd:author">
                <xsl:apply-templates select="dct:creator" />
            </xsl:element>
            <xsl:element name="mmd:publisher">
		    <xsl:apply-templates select="dct:publisher" />
            </xsl:element>
        </xsl:element-->
        <xsl:apply-templates select="dct:spatial"/>
        <!--Optional for Dataset-->
        <!--xsl:apply-templates select="dct:accessRights" /-->
        <xsl:apply-templates select="schema:license"/>
        <xsl:apply-templates select="dcat:landingPage"/>
        <xsl:apply-templates select="foaf:page"/>
        <xsl:element name="mmd:metadata_source">
            <xsl:text>External-Harvest</xsl:text>
        </xsl:element>
    </xsl:template>
    <xsl:template match="dct:title">
        <xsl:element name="mmd:title">
            <xsl:attribute name="xml:lang">en</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="dct:description">
        <xsl:element name="mmd:abstract">
            <xsl:attribute name="xml:lang">en</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="dcat:contactPoint">
        <xsl:if test="vcard:Organization">
            <xsl:if test="not(contains(vcard:Organization/vcard:fn, 'author'))">
                <xsl:element name="mmd:personnel">
                    <xsl:element name="mmd:role">
                        <xsl:text>Technical contact</xsl:text>
                    </xsl:element>
                    <xsl:element name="mmd:name">
                        <xsl:value-of select="vcard:Organization/vcard:fn"/>
                    </xsl:element>
                    <xsl:element name="mmd:email">
                        <xsl:choose>
                            <xsl:when test="vcard:Organization/vcard:hasEmail/@rdf:resource">
                                <xsl:value-of select="substring-after(vcard:Organization/vcard:hasEmail/@rdf:resource, 'mailto:')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="vcard:Organization/vcard:hasEmail"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dcat:Distribution">
        <xsl:if test="dcat:downloadURL">
            <xsl:element name="mmd:data_access">
                <xsl:element name="mmd:type">
                    <xsl:text>HTTP</xsl:text>
                </xsl:element>
                <!--xsl:element name="mmd:name">
                    <xsl:value-of select="." />
                </xsl:element-->
                <!--this is probably the description of the distribution, not really matching the description of the data access as in mmd-->
                <xsl:element name="mmd:description">
                    <xsl:value-of select="dct:description"/>
                </xsl:element>
                <xsl:element name="mmd:resource">
                    <xsl:value-of select="@rdf:resource"/>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <xsl:template match="dct:creator">
        <!--This can be in different format, as resource for example-->
        <xsl:if test="foaf:Organization">
            <xsl:value-of select="foaf:Organization/foaf:name"/>
        </xsl:if>
        <xsl:if test="foaf:Agent">
            <xsl:value-of select="foaf:Agent/foaf:name"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="dct:publisher">
        <!--This can be in different format, as resource for example-->
        <xsl:if test="foaf:Organization">
            <xsl:value-of select="foaf:Organization/foaf:name"/>
        </xsl:if>
        <xsl:if test="foaf:Agent">
            <xsl:value-of select="foaf:Agent/foaf:name"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="dct:spatial">
        <xsl:element name="mmd:geographic_extent">
            <xsl:apply-templates select="dct:Location"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="dct:Location">
        <!--It could be directly dcat:bbox-->
        <xsl:if test="dcat:bbox and contains(dcat:bbox/@rdf:datatype,'wkt') and contains(dcat:bbox,'POLYGON')">
            <xsl:variable name="wkt">
                <!--expect POLYGON((-31.285 70.075,34.099 70.075,34.099 27.642,-31.285 27.642,-31.285 70.075))-->
                <xsl:value-of select="substring-before(substring-after(dcat:bbox, '(('), '))')"/>
            </xsl:variable>
            <xsl:element name="mmd:rectangle">
                <xsl:attribute name="srsName">
                    <xsl:text>EPSG:4326</xsl:text>
                </xsl:attribute>
                <xsl:call-template name="wktseparation">
                    <xsl:with-param name="boxcoordinates" select="$wkt"/>
                </xsl:call-template>
            </xsl:element>
        </xsl:if>
        <!--It could also be POLYGON with 4 corners-->
        <xsl:if test="locn:geometry and contains(locn:geometry/@rdf:datatype,'wkt') and contains(locn:geometry,'POLYGON')">
            <xsl:variable name="wkt">
                <xsl:value-of select="substring-before(substring-after(locn:geometry, '(('), '))')"/>
            </xsl:variable>
            <xsl:variable name="commaCount" select="string-length($wkt) - string-length(translate($wkt, ',', ''))"/>
            <xsl:if test="$commaCount = 4">
                <xsl:element name="mmd:rectangle">
                    <xsl:attribute name="srsName">
                        <xsl:text>EPSG:4326</xsl:text>
                    </xsl:attribute>
                    <xsl:call-template name="wktseparation">
                        <xsl:with-param name="boxcoordinates" select="$wkt"/>
                    </xsl:call-template>
                </xsl:element>
            </xsl:if>
        </xsl:if>
        <xsl:if test="locn:geometry and contains(locn:geometry/@rdf:datatype,'wkt') and contains(locn:geometry,'POINT')">
            <!-->POINT (126.4595 72.3680) is E(W)/N(S)-->
            <xsl:variable name="pointvalues">
                <xsl:value-of select="substring-after(substring-before(., ')'), '(')"/>
            </xsl:variable>
            <xsl:element name="mmd:rectangle">
                <xsl:attribute name="srsName">
                    <xsl:text>EPSG:4326</xsl:text>
                </xsl:attribute>
                <xsl:element name="mmd:north">
                    <xsl:value-of select="substring-after($pointvalues,' ')"/>
                </xsl:element>
                <xsl:element name="mmd:south">
                    <xsl:value-of select="substring-after($pointvalues,' ')"/>
                </xsl:element>
                <xsl:element name="mmd:east">
                    <xsl:value-of select="substring-before($pointvalues,' ')"/>
                </xsl:element>
                <xsl:element name="mmd:west">
                    <xsl:value-of select="substring-before($pointvalues,' ')"/>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <xsl:template name="wktseparation">
        <xsl:param name="boxcoordinates"/>
        <xsl:variable name="long1">
            <xsl:value-of select="number(substring-before(substring-before($boxcoordinates, ','), ' '))"/>
        </xsl:variable>
        <xsl:variable name="left1">
            <xsl:value-of select="substring-after($boxcoordinates, ',')"/>
        </xsl:variable>
        <xsl:variable name="long2">
            <xsl:value-of select="number(substring-before(substring-before(normalize-space($left1), ','), ' '))"/>
        </xsl:variable>
        <xsl:variable name="left2">
            <xsl:value-of select="substring-after($left1, ',')"/>
        </xsl:variable>
        <xsl:variable name="long3">
            <xsl:value-of select="number(substring-before(substring-before(normalize-space($left2), ','), ' '))"/>
        </xsl:variable>
        <xsl:variable name="left3">
            <xsl:value-of select="substring-after($left2, ',')"/>
        </xsl:variable>
        <xsl:variable name="long4">
            <xsl:value-of select="number(substring-before(substring-before(normalize-space($left3), ','), ' '))"/>
        </xsl:variable>
        <xsl:variable name="maxlong12">
            <xsl:choose>
                <xsl:when test="$long1 &gt; $long2">
                    <xsl:value-of select="$long1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$long2"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="maxlong34">
            <xsl:choose>
                <xsl:when test="$long3 &gt; $long4">
                    <xsl:value-of select="$long3"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$long4"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="maxlong">
            <xsl:choose>
                <xsl:when test="$maxlong12 &gt; $maxlong34">
                    <xsl:value-of select="$maxlong12"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$maxlong34"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="minlong12">
            <xsl:choose>
                <xsl:when test="$long1 &gt; $long2">
                    <xsl:value-of select="$long2"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$long1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="minlong34">
            <xsl:choose>
                <xsl:when test="$long3 &gt; $long4">
                    <xsl:value-of select="$long4"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$long3"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="minlong">
            <xsl:choose>
                <xsl:when test="$minlong12 &gt; $minlong34">
                    <xsl:value-of select="$maxlong34"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$minlong12"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!---20.7968 74.3606, -20.7968 74.4075, -20.8987 74.4075, -20.8987 74.3606, -20.7968 74.3606-->
        <xsl:variable name="lat1">
            <xsl:value-of select="number(substring-after(substring-before($boxcoordinates, ','), ' '))"/>
        </xsl:variable>
        <xsl:variable name="left1a">
            <xsl:value-of select="substring-after($boxcoordinates, ',')"/>
        </xsl:variable>
        <xsl:variable name="lat2">
            <xsl:value-of select="number(substring-after(substring-before(normalize-space($left1a), ','), ' '))"/>
        </xsl:variable>
        <xsl:variable name="left2a">
            <xsl:value-of select="substring-after($left1a, ', ')"/>
        </xsl:variable>
        <xsl:variable name="lat3">
            <xsl:value-of select="number(substring-after(substring-before(normalize-space($left2a), ','), ' '))"/>
        </xsl:variable>
        <xsl:variable name="left3a">
            <xsl:value-of select="substring-after($left2a, ', ')"/>
        </xsl:variable>
        <xsl:variable name="lat4">
            <xsl:value-of select="number(substring-after(substring-before(normalize-space($left3a), ','), ' '))"/>
        </xsl:variable>
        <xsl:variable name="maxlat12">
            <xsl:choose>
                <xsl:when test="$lat1 &gt; $lat2">
                    <xsl:value-of select="$lat1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$lat2"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="maxlat34">
            <xsl:choose>
                <xsl:when test="$lat3 &gt; $lat4">
                    <xsl:value-of select="$lat3"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$lat4"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="maxlat">
            <xsl:choose>
                <xsl:when test="$maxlat12 &gt; $maxlat34">
                    <xsl:value-of select="$maxlat12"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$maxlat34"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="minlat12">
            <xsl:choose>
                <xsl:when test="$lat1 &gt; $lat2">
                    <xsl:value-of select="$lat2"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$lat1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="minlat34">
            <xsl:choose>
                <xsl:when test="$lat3 &gt; $lat4">
                    <xsl:value-of select="$lat4"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$lat3"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="minlat">
            <xsl:choose>
                <xsl:when test="$minlat12 &gt; $minlat34">
                    <xsl:value-of select="$maxlat34"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$minlat12"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="mmd:north">
            <xsl:value-of select="$maxlat"/>
        </xsl:element>
        <xsl:element name="mmd:south">
            <xsl:value-of select="$minlat"/>
        </xsl:element>
        <xsl:element name="mmd:east">
            <xsl:value-of select="$maxlong"/>
        </xsl:element>
        <xsl:element name="mmd:west">
            <xsl:value-of select="$minlong"/>
        </xsl:element>
    </xsl:template>
    <!--to be fixed-->
    <xsl:template name="polygonseparation">
    </xsl:template>
    <xsl:template match="dct:temporal">
        <xsl:element name="mmd:temporal_extent">
            <xsl:element name="mmd:start_date">
                <xsl:choose>
                    <xsl:when test="contains(dct:PeriodOfTime/dcat:startDate, 'T')">
                        <xsl:value-of select="dct:PeriodOfTime/dcat:startDate"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(dct:PeriodOfTime/dcat:startDate,'T12:00:00Z')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
                <xsl:if test="dct:PeriodOfTime/dcat:endDate !='' and dct:PeriodOfTime/dcat:endDate !='ongoing'">
                    <xsl:element name="mmd:end_date">
                        <xsl:choose>
                            <xsl:when test="contains(dct:PeriodOfTime/dcat:endDate, 'T')">
                                <xsl:value-of select="dct:PeriodOfTime/dcat:endDate"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat(dct:PeriodOfTime/dcat:endDate,'T12:00:00Z')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <xsl:template match="dct:identifier">
        <xsl:element name="mmd:metadata_identifier">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="schema:license">
        <xsl:variable name="dcatuse">
            <xsl:value-of select="."/>
        </xsl:variable>
        <xsl:if test="not(normalize-space($dcatuse)='')">
            <xsl:for-each select="$isoLUD">
                <xsl:choose>
                    <xsl:when test="key('usec', $dcatuse)">
                        <xsl:variable name="prefuseid" select="key('usec', $dcatuse)/skos:prefLabel"/>
                        <xsl:variable name="prefuseref" select="key('usec', $dcatuse)/skos:exactMatch/@rdf:resource[contains(.,'spdx')]"/>
                        <xsl:element name="mmd:use_constraint">
                            <xsl:element name="mmd:identifier">
                                <xsl:value-of select="$prefuseid"/>
                            </xsl:element>
                            <xsl:element name="mmd:resource">
                                <xsl:value-of select="$prefuseref"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="key('useca', $dcatuse)">
                        <xsl:variable name="prefuseid" select="key('useca', $dcatuse)/skos:prefLabel"/>
                        <xsl:variable name="prefuseref" select="key('useca', $dcatuse)/skos:exactMatch/@rdf:resource[contains(.,'spdx')]"/>
                        <xsl:element name="mmd:use_constraint">
                            <xsl:element name="mmd:identifier">
                                <xsl:value-of select="$prefuseid"/>
                            </xsl:element>
                            <xsl:element name="mmd:resource">
                                <xsl:value-of select="$prefuseref"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="key('usecexact', substring-after($dcatuse, '://'))">
                        <xsl:variable name="prefuseid" select="key('usecexact', substring-after($dcatuse, '://'))/../skos:prefLabel"/>
                        <xsl:variable name="prefuseref" select="key('usecexact', substring-after($dcatuse, '://'))/../skos:exactMatch/@rdf:resource[contains(.,'spdx')]"/>
                        <xsl:element name="mmd:use_constraint">
                            <xsl:element name="mmd:identifier">
                                <xsl:value-of select="$prefuseid"/>
                            </xsl:element>
                            <xsl:element name="mmd:resource">
                                <xsl:value-of select="$prefuseref"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="mmd:use_constraint">
                            <xsl:element name="mmd:license_text">
                                <xsl:value-of select="$dcatuse"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <xsl:template match="dct:accessRights">
        <!--This is most likely a resource URL/controlled vocabulary which should be mapped public, restricted, non-public-->
        <xsl:element name="mmd:access_constraint">
            <xsl:choose>
                <xsl:when test="dct:RightsStatement">
                    <xsl:value-of select="dct:RightsStatement"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    <xsl:template match="dcat:landingPage">
        <xsl:element name="mmd:related_information">
            <!--This can probably have a different representation-->
            <xsl:element name="mmd:type">Dataset landing page</xsl:element>
            <xsl:choose>
                <xsl:when test="foaf:Document">
                    <xsl:element name="mmd:resource">
                        <xsl:value-of select="foaf:Document/@rdf:about"/>
                    </xsl:element>
                    <xsl:element name="mmd:description">
                        <xsl:value-of select="foaf:Document/dct:description"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="mmd:resource">
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    <xsl:template match="foaf:page">
        <!--This  property  refers  to  a  page  or document about this Dataset. We can't discriminate the type-->
        <xsl:element name="mmd:related_information">
            <xsl:element name="mmd:type">Other documentation</xsl:element>
            <xsl:choose>
                <xsl:when test="foaf:Document">
                    <xsl:element name="mmd:resource">
                        <xsl:value-of select="foaf:Document/@rdf:about"/>
                    </xsl:element>
                    <xsl:element name="mmd:description">
                        <xsl:value-of select="foaf:Document/dct:description"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="mmd:resource">
                        <xsl:value-of select="@rdf:resource"/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    <xsl:template match="dct:language">
        <!--In dcat this element is NOT unique as in mmd-->
        <xsl:element name="mmd:dataset_language">
            <!--probably dct:LinguisticSystem is used instead. It should be a resource type.-->
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
