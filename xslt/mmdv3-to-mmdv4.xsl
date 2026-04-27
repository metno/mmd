<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:mmd="http://www.met.no/schema/mmd"
    xmlns="http://www.met.no/schema/mmd"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    version="1.0">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*"/>
    <xsl:variable name="vocab" select="document('../thesauri/mmd-vocabulary.xml')"/>
    <xsl:key name="orgeng" match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/Organisation']/skos:member/skos:Concept" use="skos:prefLabel[@xml:lang='en']"/>
    <xsl:key name="orgengalt" match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/Organisation']/skos:member/skos:Concept" use="skos:altLabel[@xml:lang='en']"/>
    <xsl:key name="orgengh" match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/Organisation']/skos:member/skos:Concept" use="skos:hiddenLabel[@xml:lang='en']"/>

    <xsl:template match="/mmd:mmd">
        <xsl:element name="mmd:mmd">
            <xsl:copy-of select="document('')/xsl:stylesheet/namespace::*[name() ='mmd' and name()='gml']"/>
            <xsl:copy-of select="document('')/xsl:stylesheet/namespace::*[name()='gml']"/>
            <xsl:apply-templates select="mmd:metadata_identifier"/>
            <xsl:apply-templates select="mmd:alternate_identifier"/>
            <xsl:apply-templates select="mmd:title"/>
            <xsl:apply-templates select="mmd:abstract"/>
            <xsl:apply-templates select="mmd:metadata_status"/>
            <xsl:apply-templates select="mmd:dataset_production_status"/>
            <xsl:if test="not(mmd:dataset_production_status)">
                <xsl:element name="mmd:dataset_production_status">
                    <xsl:text>Not available</xsl:text>
                </xsl:element>
            </xsl:if>
            <xsl:apply-templates select="mmd:collection"/>
            <xsl:apply-templates select="mmd:last_metadata_update"/>
            <xsl:apply-templates select="mmd:temporal_extent"/>
            <xsl:apply-templates select="mmd:iso_topic_category"/>
            <xsl:apply-templates select="mmd:keywords[normalize-space(.) != '']"/>
            <xsl:apply-templates select="mmd:operational_status"/>
            <xsl:apply-templates select="mmd:dataset_language"/>
            <xsl:apply-templates select="mmd:geographic_extent"/>
            <xsl:apply-templates select="mmd:access_constraint"/>
            <xsl:apply-templates select="mmd:use_constraint"/>
            <xsl:apply-templates select="mmd:project"/>
            <xsl:apply-templates select="mmd:activity_type"/>
            <xsl:apply-templates select="mmd:platform"/>
            <xsl:apply-templates select="mmd:spatial_representation" />
            <xsl:apply-templates select="mmd:related_information"/>
            <xsl:apply-templates select="mmd:personnel"/>
            <xsl:apply-templates select="mmd:dataset_citation"/>
            <xsl:apply-templates select="mmd:quality_control" />
            <xsl:apply-templates select="mmd:data_access"/>
            <xsl:apply-templates select="mmd:data_center"/>
            <xsl:apply-templates select="mmd:related_dataset"/>
            <xsl:choose>
                <xsl:when test="mmd:storage_information[normalize-space(.) != '']">
                    <xsl:apply-templates select="mmd:storage_information"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="data">
                        <xsl:choose>
                            <xsl:when test="mmd:data_access[mmd:type = 'OPeNDAP']/mmd:resource !=''">
                                <xsl:value-of select="mmd:data_access[mmd:type = 'OPeNDAP']/mmd:resource"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="mmd:data_access[mmd:type = 'HTTP']/mmd:resource"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:if test="substring($data, string-length($data) - 2) = '.nc'">
                        <xsl:element name="mmd:storage_information">
                            <xsl:element name="mmd:file_format">
                                <xsl:text>NetCDF-CF</xsl:text>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="substring($data, string-length($data) - 2) = '.ncml'">
                        <xsl:element name="mmd:storage_information">
                            <xsl:element name="mmd:file_format">
                                <xsl:text>NcML</xsl:text>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:if test="contains(mmd:metadata_identifier, 'no.met.adc') or mmd:collection = 'NBS'">
                <xsl:element name="mmd:metadata_source">
                    <xsl:text>Internal</xsl:text>
                </xsl:element>
            </xsl:if>
            <xsl:apply-templates select="comment()"/>
        </xsl:element>
    </xsl:template>

     <!-- TEMPLATES: -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="comment()">
        <xsl:comment>
          <xsl:value-of select="."/>
        </xsl:comment>
    </xsl:template>

    <xsl:template match="mmd:use_constraint">
        <xsl:if test= "normalize-space(.) != ''">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

    <xsl:template match="mmd:use_constraint/mmd:resource[contains(., '.html')]">
        <xsl:copy>
            <xsl:value-of select="substring-before(., '.html')"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="mmd:keywords[@vocabulary = 'GCMDSK' and normalize-space(.) != '']/mmd:keyword">
        <xsl:copy>
            <xsl:value-of select="translate(., 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="mmd:keywords[@vocabulary = 'GCMDLOC' and normalize-space(.) != '']/mmd:keyword">
        <xsl:copy>
            <xsl:value-of select="translate(., 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="mmd:keywords[@vocabulary = 'CFSTDN' and normalize-space(.) != '']/mmd:resource[contains(., 'standard-names.html')]">
        <xsl:copy>
            <xsl:text>https://vocab.nerc.ac.uk/standard_name/</xsl:text>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="mmd:storage_information">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="not(mmd:file_format)">
                <xsl:variable name="data">
                    <xsl:choose>
                        <xsl:when test="../mmd:data_access[mmd:type = 'OPeNDAP']/mmd:resource !=''">
                            <xsl:value-of select="../mmd:data_access[mmd:type = 'OPeNDAP']/mmd:resource"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="../mmd:data_access[mmd:type = 'HTTP']/mmd:resource"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="substring($data, string-length($data) - 2) = '.nc'">
                    <xsl:element name="mmd:file_format">
                        <xsl:text>NetCDF-CF</xsl:text>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="substring($data, string-length($data) - 2) = '.ncml'">
                    <xsl:element name="mmd:file_format">
                        <xsl:text>NcML</xsl:text>
                    </xsl:element>
                </xsl:if>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="mmd:last_metadata_update">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:element name="mmd:update">
                <xsl:element name="mmd:datetime">
                    <xsl:value-of select="concat(substring(date:date-time(),1,19),'Z')"/>
                </xsl:element>
                <xsl:element name="mmd:type">
                    <xsl:text>Minor modification</xsl:text>
                </xsl:element>
                <xsl:element name="mmd:note">
                    <xsl:text>Changed version of metadata standard to MMD v4</xsl:text>
                </xsl:element>
            </xsl:element>
		</xsl:copy>
    </xsl:template>

    <xsl:template match="mmd:data_center">
        <xsl:element name="mmd:data_center">
            <xsl:element name="mmd:data_center_name">
                <xsl:element name="mmd:short_name">
                    <xsl:value-of select="mmd:data_center_name/mmd:short_name"/>
                </xsl:element>
                <xsl:element name="mmd:long_name">
                    <xsl:value-of select="mmd:data_center_name/mmd:long_name"/>
                </xsl:element>
            </xsl:element>
            <xsl:element name="mmd:data_center_url">
                <xsl:value-of select="mmd:data_center_url"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mmd:personnel">
        <xsl:element name="mmd:personnel">
            <xsl:element name="mmd:role">
                <xsl:value-of select="mmd:role"/>
            </xsl:element>
            <xsl:if test="mmd:type !=''">
                <xsl:element name="mmd:type">
                    <xsl:value-of select="mmd:type"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="not(mmd:type) and ../mmd:collection = 'NBS'">
                <xsl:element name="mmd:type">
                    <xsl:text>Organisation</xsl:text>
                </xsl:element>
            </xsl:if>
            <xsl:copy-of select="mmd:name"/>
            <xsl:element name="mmd:email">
                <xsl:value-of select="mmd:email"/>
            </xsl:element>
            <xsl:choose>
                <xsl:when test="mmd:oranisation/@uri">
                    <xsl:copy-of select="mmd:organisation"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="organisation">
                        <xsl:with-param name="myorg" select="mmd:organisation" />
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="mmd:phone !=''">
                <xsl:element name="mmd:phone">
                    <xsl:value-of select="mmd:phone"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="mmd:contact_address !=''">
                <xsl:copy-of select="mmd:contact_address"/>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <!--Organisation ROR mapping-->
    <xsl:template name="organisation">
    <xsl:param name="myorg"/>
        <xsl:for-each select="$vocab" >
            <xsl:choose>
                <xsl:when test="key('orgeng', $myorg)">
                    <xsl:variable name="orguri" select="key('orgeng', $myorg)/skos:exactMatch/@rdf:resource"/>
                    <xsl:choose>
                        <xsl:when test="$orguri != ''">
                            <xsl:element name="mmd:organisation">
                                <xsl:variable name="orgpref" select="key('orgeng', $myorg)/skos:prefLabel"/>
                                <xsl:attribute name="uri">
                                    <xsl:value-of select="$orguri"/>
                                </xsl:attribute>
                                <xsl:value-of select="$orgpref"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:element name="mmd:organisation">
                                <xsl:value-of select="$myorg"/>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="key('orgengalt', $myorg)">
                    <xsl:element name="mmd:organisation">
                        <xsl:variable name="orgpref" select="key('orgengalt', $myorg)/skos:prefLabel"/>
                        <xsl:variable name="orguri" select="key('orgengalt', $myorg)/skos:exactMatch/@rdf:resource"/>
                        <xsl:attribute name="uri">
                            <xsl:value-of select="$orguri"/>
                        </xsl:attribute>
                        <xsl:value-of select="$orgpref"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="key('orgengh', $myorg)">
                    <xsl:element name="mmd:organisation">
                        <xsl:variable name="orgpref" select="key('orgengh', $myorg)/skos:prefLabel"/>
                        <xsl:variable name="orguri" select="key('orgengh', $myorg)/skos:exactMatch/@rdf:resource"/>
                        <xsl:attribute name="uri">
                            <xsl:value-of select="$orguri"/>
                        </xsl:attribute>
                        <xsl:value-of select="$orgpref"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="mmd:organisation">
                        <xsl:value-of select="$myorg"/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
