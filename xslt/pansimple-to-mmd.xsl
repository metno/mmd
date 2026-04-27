<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:pansimple="urn:pangaea.de:dataportals"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:mmd="http://www.met.no/schema/mmd"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    version="1.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:variable name="vocab" select="document('../thesauri/mmd-vocabulary.xml')"/>
    <xsl:key name="usec" match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/Use_Constraint']/skos:member/skos:Concept" use="skos:prefLabel"/>

    <xsl:template match="pansimple:dataset">
        <xsl:element name="mmd:mmd">
            <xsl:element name="mmd:metadata_identifier">
                <xsl:value-of select="dc:identifier" />
            </xsl:element>
            <xsl:element name="mmd:title">
                <xsl:attribute name="xml:lang">en</xsl:attribute>
                <xsl:value-of select="dc:title" />
            </xsl:element>
            <xsl:element name="mmd:abstract">
                <xsl:attribute name="xml:lang">en</xsl:attribute>
                <xsl:value-of select="dc:description" />
            </xsl:element>
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
                <!--dc:date is generally used as publication date.-->
                <xsl:if test="dc:date">
                    <xsl:element name="mmd:update">
                        <xsl:element name="mmd:datetime">
                            <!--xsl:value-of select="dct:issued"/-->
                            <xsl:call-template name="datetime">
                                <xsl:with-param name="datetime" select="dc:date" />
                            </xsl:call-template>
                        </xsl:element>
                        <xsl:element name="mmd:type">
                            <xsl:text>Created</xsl:text>
                        </xsl:element>
                        <xsl:element name="mmd:note">
                            <xsl:text>Information caputured from PANSIMPLE record</xsl:text>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="dc:modified">
                    <xsl:element name="mmd:update">
                        <xsl:element name="mmd:datetime">
                            <xsl:call-template name="datetime">
                                <xsl:with-param name="datetime" select="dc:modified" />
                            </xsl:call-template>
                        </xsl:element>
                        <xsl:element name="mmd:type">
                            <xsl:text>Major modification</xsl:text>
                        </xsl:element>
                        <xsl:element name="mmd:note">
                            <xsl:text>Information caputured from PANSIMPLE record</xsl:text>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="not(dc:modified) and not(dc:date)">
                    <xsl:element name="mmd:update">
                        <xsl:element name="mmd:datetime">
                            <xsl:value-of select="concat(substring(date:date-time(),1,19),'Z')"/>
                        </xsl:element>
                        <xsl:element name="mmd:type">
                            <xsl:text>Major modification</xsl:text>
                        </xsl:element>
                        <xsl:element name="mmd:note">
                            <xsl:text>Translated form PANSIMPLE record</xsl:text>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
            </xsl:element>
            <xsl:if test="dc:coverage/pansimple:startDate">
                <xsl:element name="mmd:temporal_extent">
                    <xsl:element name="mmd:start_date">
                        <xsl:choose>
                            <xsl:when test="contains(dc:coverage/pansimple:startDate, 'T')">
                                <xsl:value-of select="dc:coverage/pansimple:startDate"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="string-length(dc:coverage/pansimple:startDate) = 4">
                                        <xsl:value-of select="concat(dc:coverage/pansimple:startDate, '-01-01T12:00:00Z')"/>
                                    </xsl:when>
                                    <xsl:when test="string-length(dc:coverage/pansimple:startDate) = 7">
                                        <xsl:value-of select="concat(dc:coverage/pansimple:startDate, '-01T12:00:00Z')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat(dc:coverage/pansimple:startDate,'T12:00:00Z')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <xsl:if test ="dc:coverage/pansimple:endDate">
                        <xsl:element name="mmd:end_date">
                        <xsl:choose>
                            <xsl:when test="contains(dc:coverage/pansimple:endDate, 'T')">
                                <xsl:value-of select="dc:coverage/pansimple:endDate"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="string-length(dc:coverage/pansimple:endDate) = 4">
                                        <xsl:value-of select="concat(dc:coverage/pansimple:endDate, '-01-01T12:00:00Z')"/>
                                    </xsl:when>
                                    <xsl:when test="string-length(dc:coverage/pansimple:endDate) = 7">
                                        <xsl:value-of select="concat(dc:coverage/pansimple:endDate, '-01T12:00:00Z')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat(dc:coverage/pansimple:endDate,'T12:00:00Z')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                        </xsl:element>
                    </xsl:if>
                </xsl:element>
            </xsl:if>
            <xsl:element name="mmd:iso_topic_category">
                <xsl:text>Not available</xsl:text>
            </xsl:element>
            <xsl:element name="mmd:keywords">
                <xsl:attribute name="vocabulary">None</xsl:attribute>
                <xsl:for-each select="dc:subject[@type='keyword']">
                    <xsl:element name="mmd:keyword">
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
            <xsl:if test="dc:language">
                <xsl:element name="mmd:dataset_language">
                    <xsl:value-of select="dc:language"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="dc:coverage/pansimple:northBoundLatitude">
                <xsl:element name="mmd:geographic_extent">
                    <xsl:element name="mmd:rectangle">
                        <xsl:attribute name="srsName">
                            <xsl:value-of select="'EPSG:4326'"/>
                        </xsl:attribute>
                        <xsl:element name="mmd:south">
                            <xsl:value-of select="dc:coverage/pansimple:southBoundLatitude"/>
                        </xsl:element>
                        <xsl:element name="mmd:north">
                            <xsl:value-of select="dc:coverage/pansimple:northBoundLatitude"/>
                        </xsl:element>
                        <xsl:element name="mmd:west">
                            <xsl:value-of select="dc:coverage/pansimple:westBoundLongitude"/>
                        </xsl:element>
                        <xsl:element name="mmd:east">
                            <xsl:value-of select="dc:coverage/pansimple:eastBoundLongitude"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            <xsl:if test="dc:rights">
                <xsl:apply-templates select="dc:rights"/>
            </xsl:if>
            <xsl:if test="dc:subject/@type='project'">
                <xsl:element name="mmd:project">
                    <xsl:element name="mmd:short_name">
                        <xsl:value-of select="dc:subject"/>
                    </xsl:element>
                    <xsl:element name="mmd:long_name">
                        <xsl:value-of select="dc:subject"/>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            <xsl:if test="dc:creator">
                <xsl:apply-templates select="dc:creator"/>
            </xsl:if>
            <xsl:if test="pansimple:linkage/@type='data'">
                <xsl:apply-templates select="pansimple:linkage[@type='data']"/>
            </xsl:if>
            <xsl:if test="pansimple:linkage/@type='metadata'">
                <xsl:apply-templates select="pansimple:linkage[@type='metadata']"/>
            </xsl:if>
            <!--the type of relation is not expressed-->
            <xsl:if test="dc:relation">
                <xsl:apply-templates select="dc:relation"/>
            </xsl:if>
            <!--this can be repeated if more data links are present. MMD does not cover this-->
            <!--xsl:if test="dc:format">
                <xsl:element name="mmd:storage_information">
                    <xsl:element name="mmd:file_format">
                        <xsl:value-of select="dc:format"/>
                    </xsl:element>
                </xsl:element>
            </xsl:if-->
            <xsl:if test="dc:publisher|pansimple:dataCenter">
                <xsl:element name="mmd:data_center">
                    <xsl:element name="mmd:data_center_name">
                        <xsl:element name="mmd:short_name">
                            <xsl:value-of select="dc:publisher|pansimple:dataCenter"/>
                        </xsl:element>
                        <xsl:element name="mmd:long_name">
                            <xsl:value-of select="dc:publisher|pansimple:dataCenter"/>
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="mmd:data_center_url"/>
                </xsl:element>
            </xsl:if>
            <xsl:element name="mmd:dataset_citation">
                <xsl:if test="contains(pansimple:linkage[@type='metadata'], 'doi.org')">
                    <xsl:element name="mmd:doi">
                        <xsl:value-of select="pansimple:linkage[@type='metadata']"/>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="dc:date">
                    <xsl:element name="mmd:publication_date">
                        <xsl:value-of select="substring(dc:date, 1, 4)" />
                    </xsl:element>
                </xsl:if>
                <xsl:if test="dc:publisher">
                    <xsl:element name="mmd:publisher">
                        <xsl:value-of select="dc:publisher" />
                    </xsl:element>
                </xsl:if>
            </xsl:element>

        </xsl:element>
    </xsl:template>

    <xsl:template match="dc:rights">
        <xsl:variable name="dcatuse">
            <xsl:if test="contains(.,'CC0')">
                <xsl:value-of select="concat(., '-1.0')"/>
            </xsl:if>
            <xsl:if test="not(contains(.,'CC0'))">
                <xsl:value-of select="concat(., '-4.0')"/>
            </xsl:if>
        </xsl:variable>
        <xsl:if test="not(normalize-space($dcatuse)='')">
            <xsl:for-each select="$vocab">
                <xsl:if test="key('usec', $dcatuse)">
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
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dc:creator">
        <xsl:element name="mmd:personnel">
            <xsl:element name="mmd:role">
                <xsl:text>Investigator</xsl:text>
            </xsl:element>
            <xsl:element name="mmd:name">
                <xsl:value-of select="substring-after(.,', ')" />
                <xsl:text> </xsl:text>
                <xsl:value-of select="substring-before(.,', ')" />
            </xsl:element>
            <xsl:element name="mmd:organisation"/>
            <xsl:element name="mmd:email"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="pansimple:linkage[@type = 'data']">
        <xsl:element name="mmd:data_access">
            <xsl:element name="mmd:type">
                <xsl:text>HTTP</xsl:text>
            </xsl:element>
            <xsl:element name="mmd:description">
                <xsl:text>linkage type="data"</xsl:text>
            </xsl:element>
            <xsl:element name="mmd:resource">
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="pansimple:linkage[@type = 'metadata']">
        <xsl:element name="mmd:related_information">
            <xsl:element name="mmd:type">
                <xsl:text>Dataset landing page</xsl:text>
            </xsl:element>
            <xsl:element name="mmd:description">
                <xsl:text>linkage type="metadadata"</xsl:text>
            </xsl:element>
            <xsl:element name="mmd:resource">
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dc:relation">
        <xsl:element name="mmd:related_information">
            <xsl:element name="mmd:type">
                <xsl:text>Other documentation</xsl:text>
            </xsl:element>
            <xsl:element name="mmd:description">
                <xsl:text>relation link</xsl:text>
            </xsl:element>
            <xsl:element name="mmd:resource">
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template name="datetime">
        <xsl:param name="datetime"/>
        <xsl:choose>
            <xsl:when test="contains($datetime, 'T')">
                <xsl:choose>
                    <xsl:when test="contains($datetime, 'Z')">
                        <xsl:value-of select="$datetime"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($datetime,'Z')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <!-- If the input is in the format YYYY -->
                    <xsl:when test="string-length($datetime) = 4">
                        <xsl:value-of select="concat($datetime, '-01-01T12:00:00Z')" />
                    </xsl:when>
                    <!-- If the input is in the format YYYY-MM -->
                    <xsl:when test="string-length($datetime) = 7 and substring($datetime, 5, 1) = '-'">
                        <xsl:value-of select="concat($datetime, '-01T12:00:00Z')" />
                    </xsl:when>
                    <!-- If the input does not match any expected format, put now -->
                    <xsl:otherwise>
                        <xsl:value-of select="concat(substring(date:date-time(),1,19),'Z')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
