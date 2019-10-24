<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:mmd="http://www.met.no/schema/mmd">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <xsl:template match=
    "*[not(@*|*|comment()|processing-instruction()) 
     and normalize-space()=''
      ]"/>
    <xsl:template match="submitted_metadata">
        <xsl:element name="mmd:mmd">
            <!-- Missing metadata_identifier -->
            <xsl:apply-templates select="Modified"/>
            <xsl:element name="mmd:metadata_status">Active</xsl:element>
            <xsl:apply-templates select="Collection"/>
            <xsl:apply-templates select="Title"/>
            <xsl:apply-templates select="Abstract"/>
            <xsl:apply-templates select="ISO-Topic-category"/>
            <xsl:apply-templates select="Dataset-Production-status"/>
            <xsl:element name="mmd:temporal_extent">
                <xsl:element name="mmd:start_date">
                    <xsl:call-template name="format-Date">
                        <xsl:with-param name="mydate">
                            <xsl:choose>
                                <xsl:when test="Time-Start = ''">
                                    <xsl:value-of select="concat(Date-Start, ' - ', Time-Start)" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat(Date-Start, ' - 12:00')" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:element>
                <xsl:element name="mmd:end_date">
                    <xsl:call-template name="format-Date">
                        <xsl:with-param name="mydate">
                            <xsl:choose>
                                <xsl:when test="Time-End = ''">
                                    <xsl:value-of select="concat(Date-End, ' - ', Time-Start)" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat(Date-End, ' - 12:00')" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:element>
            </xsl:element>
            <xsl:element name="mmd:geographic_extent">
                <xsl:element name="mmd:rectangle">
                    <xsl:attribute name="srsName">EPSG:4326</xsl:attribute>
                    <xsl:apply-templates select="Dataset-northernmost-latitude"/>
                    <xsl:apply-templates select="Dataset-southernmost-latitude"/>
                    <xsl:apply-templates select="Dataset-easternmost-longitude"/>
                    <xsl:apply-templates select="Dataset-westernmost-longitude"/>
                </xsl:element>
            </xsl:element>
            <xsl:element name="mmd:keywords">
                <xsl:attribute name="vocabulary">GCMD</xsl:attribute>
                <xsl:apply-templates select="GCMD-Science-Keywords"/>
            </xsl:element>
            <xsl:element name="mmd:data_access">
                <xsl:apply-templates select="Data-Access-type"/>
                <xsl:apply-templates select="Data-Access-resource"/>
            </xsl:element>
            <xsl:element name="mmd:related_information">
                <xsl:apply-templates select="Related-information-type"/>
                <xsl:apply-templates select="Related-information-resource"/>
            </xsl:element>
            <xsl:apply-templates select="Access-Constraint"/>
            <xsl:element name="mmd:project">
                <xsl:apply-templates select="Project-long-name"/>
                <xsl:apply-templates select="Project-short-name"/>
            </xsl:element>
            <xsl:element name="mmd:personnel">
                <xsl:element name="mmd:role">Investigator</xsl:element>
                <xsl:element name="mmd:name"><xsl:value-of select="Principal-investigator--PI-"/></xsl:element>
                <xsl:element name="mmd:organisation"><xsl:value-of select="PI-institution"/></xsl:element>
                <xsl:element name="mmd:email"><xsl:value-of select="PI-email"/></xsl:element>
                <xsl:element name="contact_address">
                    <xsl:element name="mmd:address"><xsl:value-of select="Address"/></xsl:element>
                    <xsl:element name="mmd:city"><xsl:value-of select="City"/></xsl:element>
                    <xsl:element name="mmd:postal_code"><xsl:value-of select="Postal-code"/></xsl:element>
                    <xsl:element name="mmd:country"><xsl:value-of select="Country"/></xsl:element>
                </xsl:element>
            </xsl:element>
            <!-- Mapping of quality is missing -->
            <!-- Mapping of Dataset-citation is missing -->
            <!-- Mapping of platform is missing -->
            <xsl:apply-templates select="Activity-type" />
        </xsl:element>
    </xsl:template>

    <xsl:template match="Modified">
        <xsl:param name="myupdate" select="." />
        <xsl:param name="yyyy1" select="substring($myupdate, 1, 4)"/>
        <xsl:param name="mm1" select="substring($myupdate, 6, 2)"/>
        <xsl:param name="dd1" select="substring($myupdate, 9, 2)"/>
        <xsl:param name="HH1" select="substring($myupdate, 14, 5)"/>
        <xsl:element name="mmd:last_metadata_update">
            <xsl:value-of select="concat($yyyy1,'-',$mm1,'-',$dd1,'T',$HH1,':00Z')"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Collection">
        <xsl:param name="mycoll" select="."/>
        <xsl:element name="mmd:collection"><xsl:value-of select="."/></xsl:element>
        <xsl:choose>
            <xsl:when test="contains($mycoll, 'SESS')">
                <xsl:element name="mmd:collection">SIOS</xsl:element>
            </xsl:when>
            <xsl:when test="contains($mycoll, 'SIOS')">
                <xsl:element name="mmd:collection">SIOS</xsl:element>
            </xsl:when>
        </xsl:choose>
        <xsl:element name="mmd:collection">ADC</xsl:element>
    </xsl:template>

    <xsl:template match="Title">
        <xsl:element name="mmd:title">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Abstract">
        <xsl:element name="mmd:abstract">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="ISO-Topic-category">
        <xsl:element name="mmd:iso_topic_category">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Dataset-Production-status">
        <xsl:element name="mmd:dataset_production_status">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Dataset-northernmost-latitude">
        <xsl:element name="mmd:north">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Dataset-southernmost-latitude">
        <xsl:element name="mmd:south">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Dataset-westernmost-longitude">
        <xsl:element name="mmd:west">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Dataset-easternmost-longitude">
        <xsl:element name="mmd:east">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="GCMD-Science-Keywords">
        <xsl:element name="mmd:keyword">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Data-Access-type">
        <xsl:element name="mmd:type">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Data-Access-resource">
        <xsl:element name="mmd:resource">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Related-information-type">
        <xsl:element name="mmd:type">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Related-information-resource">
        <xsl:element name="mmd:resource">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Access-Constraint">
        <xsl:element name="mmd:access_constraint">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Project-long-name">
        <xsl:element name="mmd:long_name">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Project-short-name">
        <xsl:element name="mmd:short_name">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Activity-type">
        <xsl:element name="mmd:activity_type">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template name="format-Date">
        <xsl:param name="mydate"/>

        <xsl:param name="yyyy" select="substring($mydate, 1, 4)"/>
        <xsl:param name="mm" select="substring($mydate, 6, 2)"/>
        <xsl:param name="dd" select="substring($mydate, 9, 2)"/>
        <xsl:param name="HH" select="substring($mydate, 14, 5)"/>
        <xsl:param name="MM" select="substring($mydate, 21, 2)"/>

        <xsl:value-of select="concat($yyyy,'-',$mm,'-',$dd,'T',$HH,':00Z')"/>
    </xsl:template>

</xsl:stylesheet>
