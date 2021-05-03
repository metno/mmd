<?xml version="1.0" encoding="UTF-8"?>

<!--
     Stylesheet for transformation of EML into MMD
-->

<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:eml="https://eml.ecoinformatics.org/eml-2.2.0" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:stmml="http://www.xml-cml.org/schema/stmml-1.2"
    xmlns:mmd="http://www.met.no/schema/mmd"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    version="1.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:key name="isoc" match="skos:Concept" use="skos:altLabel"/>
    <xsl:variable name="isoLUD" select="document('../thesauri/mmd_isotopiccategory.xml')"/>
    <!--
    <xsl:key name="isoc" match="Concept" use="altLabel"/>
-->

    <xsl:template match="/eml:eml/dataset">
        <xsl:element name="mmd:mmd">
            <!-- NSF ADC has multiple identifiers not possible to separate, but identical. -->
            <xsl:apply-templates select="alternateIdentifier[1]" />
            <xsl:apply-templates select="title" />
            <xsl:apply-templates select="abstract" />
            <xsl:apply-templates select="coverage/geographicCoverage/boundingCoordinates" />
            <xsl:apply-templates select="creator" /> 
            <xsl:apply-templates select="contact" /> 
            <xsl:element name="mmd:metadata_status">Active</xsl:element>
            <xsl:element name="mmd:collection">ADC</xsl:element>
            <xsl:element name="mmd:iso_topic_category">Not available</xsl:element>
            <xsl:element name="mmd:operational_status">Not available</xsl:element>
            <xsl:element name="mmd:metadata_status">Active</xsl:element>
            <xsl:apply-templates select="intellectualRights" />
            <xsl:apply-templates select="publisher" />
            <xsl:apply-templates select="project" />
            <!--
            <xsl:element name="mmd:keywords">
                <xsl:attribute name="vocabulary">GCMD</xsl:attribute>
                <xsl:apply-templates select="keywordSet" />
            </xsl:element>
            <xsl:element name="mmd:keywords">
                <xsl:attribute name="vocabulary">None</xsl:attribute>
                <xsl:apply-templates select="keywordSet" />
            </xsl:element>
            -->
            <xsl:apply-templates select="keywordSet" />
            <xsl:apply-templates select="distribution/online/url" />
            <!-- ... -->
        </xsl:element>
    </xsl:template>


    <xsl:template match="alternateIdentifier">
        <xsl:element name="mmd:metadata_identifier">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <xsl:template match="title">
        <xsl:element name="mmd:title">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <xsl:template match="abstract">
        <xsl:element name="mmd:abstract">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <xsl:template match="coverage/geographicCoverage/boundingCoordinates">
        <xsl:element name="mmd:geographic_extent">
            <xsl:element name="mmd:north">
                <xsl:value-of select="northBoundingCoordinate" />
            </xsl:element>
            <xsl:element name="mmd:south">
                <xsl:value-of select="southBoundingCoordinate" />
            </xsl:element>
            <xsl:element name="mmd:east">
                <xsl:value-of select="eastBoundingCoordinate" />
            </xsl:element>
            <xsl:element name="mmd:west">
                <xsl:value-of select="westBoundingCoordinate" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="creator">
        <xsl:element name="mmd:personnel">
            <xsl:element name="mmd:role">
                <xsl:text>Metadata author</xsl:text>
            </xsl:element>
            <xsl:element name="mmd:name">
                <xsl:value-of select="individualName/givenName" />
                <xsl:text> </xsl:text>
                <xsl:value-of select="individualName/surName" />
            </xsl:element>
            <xsl:element name="mmd:organisation">
                <xsl:value-of select="organizationName" />
            </xsl:element>
            <xsl:element name="mmd:email">
                <xsl:value-of select="electronicMailAddress" />
            </xsl:element>
            <xsl:element name="mmd:phone">
                <xsl:value-of select="phone" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="contact">
        <xsl:element name="mmd:personnel">
            <xsl:element name="mmd:role">
                <xsl:text>Technical contact</xsl:text>
            </xsl:element>
            <xsl:element name="mmd:name">
                <xsl:value-of select="individualName/givenName" />
                <xsl:text> </xsl:text>
                <xsl:value-of select="individualName/surName" />
            </xsl:element>
            <xsl:element name="mmd:organisation">
                <xsl:value-of select="organizationName" />
            </xsl:element>
            <xsl:element name="mmd:email">
                <xsl:value-of select="electronicMailAddress" />
            </xsl:element>
            <xsl:element name="mmd:phone">
                <xsl:value-of select="phone" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="intellectualRights">
        <xsl:element name="mmd:use_constraint">
            <xsl:element name="mmd:license_text">
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="publisher">
        <xsl:element name="mmd:data_center">
            <xsl:element name="mmd:data_center_name">
                <xsl:element name="mmd:short_name">
                    <xsl:text>NA</xsl:text>
                </xsl:element>
                <xsl:element name="mmd:long_name">
                    <xsl:value-of select="organizationName"/>
                </xsl:element>
            </xsl:element>
            <xsl:element name="data_center_url">
                <xsl:value-of select="onlineURL"/>
            </xsl:element>
        </xsl:element>

        <xsl:element name="mmd:personnel">
            <xsl:element name="mmd:role">
                <xsl:text>Data center contact contact</xsl:text>
            </xsl:element>
            <xsl:element name="mmd:name">
                <xsl:text>NA</xsl:text>
            </xsl:element>
            <xsl:element name="mmd:organisation">
                <xsl:value-of select="organizationName" />
            </xsl:element>
            <xsl:element name="mmd:email">
                <xsl:value-of select="electronicMailAddress" />
            </xsl:element>
            <xsl:element name="mmd:phone">
                <xsl:text>NA</xsl:text>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="project">
        <xsl:element name="mmd:project">
            <xsl:element name="mmd:short_name">
                <xsl:text>NA</xsl:text>
            </xsl:element>
            <xsl:element name="mmd:long_name">
                <xsl:value-of select="title"/>
            </xsl:element>
        </xsl:element>
        <xsl:apply-templates select="personnel"/>
    </xsl:template>

    <xsl:template match="personnel">
        <xsl:element name="mmd:personnel">
            <xsl:element name="mmd:role">
                <xsl:text>Investigator</xsl:text>
            </xsl:element>
            <xsl:element name="mmd:name">
                <xsl:value-of select="individualName/givenName" />
                <xsl:text> </xsl:text>
                <xsl:value-of select="individualName/surName" />
            </xsl:element>
            <xsl:element name="mmd:organisation">
                <xsl:text>NA</xsl:text>
            </xsl:element>
            <xsl:element name="mmd:email">
                <xsl:text>NA</xsl:text>
            </xsl:element>
            <xsl:element name="mmd:phone">
                <xsl:text>NA</xsl:text>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="distribution/online/url">
        <xsl:element name="mmd:related_information">
            <xsl:element name="mmd:type">
                <xsl:text>Dataset landing page</xsl:text>
            </xsl:element>
            <xsl:element name="mmd:resource">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="keywordSet">
        <xsl:element name="mmd:keywords">
            <xsl:attribute name="vocabulary">GCMD</xsl:attribute>
            <xsl:for-each select="keyword">
                <xsl:if test="contains(.,'EARTH SCIENCE &gt;')">
                    <xsl:element name="mmd:keyword">
                        <xsl:value-of select="." />
                    </xsl:element>
                </xsl:if>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

  <!--
  <xsl:template match="dif:Last_DIF_Revision_Date">
      <xsl:choose>
          <xsl:when test="current()=''">
              <xsl:element name="mmd:last_metadata_update">
                  <xsl:value-of select="../dif:DIF_Creation_Date" />
                  <xsl:text>T00:00:00.001Z</xsl:text>
              </xsl:element>
          </xsl:when>
          <xsl:otherwise>
              <xsl:element name="mmd:last_metadata_update">
-->
                  <!-- <xsl:value-of select="." /> -->
                  <!--
                  <xsl:call-template name="formatdate">-->
                      <!--xsl:value-of select="dif:Start_Date" /-->
                      <!--
                      <xsl:with-param name="datestr" select="." />

                  </xsl:call-template>
                  <xsl:text>T00:00:00.001Z</xsl:text>
              </xsl:element>
          </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
-->

  <xsl:template name="formatdate">
      <xsl:param name="datestr" />
      <!-- input format YYYY-MM-DD or YYYY-MM-DDTHH:MM:SSZ -->
      <!-- output format YYYY-MM-DDTHH:MM:SSZ -->

      <xsl:choose>
          <xsl:when test="translate($datestr,'123456789','000000000') = '0000-00-00T00:00:00Z'">
              <xsl:variable name="HH">
                  <xsl:value-of select="substring($datestr,12,2)" />
              </xsl:variable>
              <xsl:variable name="MM">
                  <xsl:value-of select="substring($datestr,15,2)" />
              </xsl:variable>
              <xsl:variable name="SS">
                  <xsl:value-of select="substring($datestr,18,2)" />
              </xsl:variable>
              <xsl:variable name="yyyy">
                  <xsl:value-of select="substring($datestr,1,4)" />
              </xsl:variable>
              <xsl:variable name="mm">
                  <xsl:value-of select="substring($datestr,6,2)" />
              </xsl:variable>
              <xsl:variable name="dd">
                  <xsl:value-of select="substring($datestr,9,2)" />
              </xsl:variable>
              <xsl:value-of select="$yyyy" />
              <xsl:value-of select="'-'" />
              <xsl:value-of select="$mm" />
              <xsl:value-of select="'-'" />
              <xsl:value-of select="$dd" />
              <xsl:value-of select="'T'" />
              <xsl:value-of select="$HH" />
              <xsl:value-of select="':'" />
              <xsl:value-of select="$MM" />
              <xsl:value-of select="':'" />
              <xsl:value-of select="$SS" />
              <xsl:value-of select="'Z'" />
          </xsl:when>
          <xsl:otherwise>
              <xsl:variable name="yyyy">
                  <xsl:value-of select="substring($datestr,1,4)" />
              </xsl:variable>
              <xsl:variable name="mm">
                  <xsl:value-of select="substring($datestr,6,2)" />
              </xsl:variable>
              <xsl:variable name="dd">
                  <xsl:value-of select="substring($datestr,9,2)" />
              </xsl:variable>
              <xsl:variable name="HH">
                  <xsl:value-of select="12" />
              </xsl:variable>
              <xsl:variable name="MM">
                  <xsl:value-of select="'00'" />
              </xsl:variable>
              <xsl:variable name="SS">
                  <xsl:value-of select="'00'" />
              </xsl:variable>
              <xsl:value-of select="$yyyy" />
              <xsl:value-of select="'-'" />
              <xsl:value-of select="$mm" />
              <xsl:value-of select="'-'" />
              <xsl:value-of select="$dd" />
              <xsl:value-of select="'T'" />
              <xsl:value-of select="$HH" />
              <xsl:value-of select="':'" />
              <xsl:value-of select="$MM" />
              <xsl:value-of select="':'" />
              <xsl:value-of select="$SS" />
              <xsl:value-of select="'Z'" />
          </xsl:otherwise>

      </xsl:choose>
  </xsl:template>

<!--
    ALTERNATIVE SEARCH & REPLACE
    string:     The text to be evaluated
    replace:    The character or string to look for in the above string
    with:       What to replace it with
    Slightly more long winded approach if that's how you prefer to roll.
--> 

<xsl:template name="string-replace">
    <xsl:param name="string" />
    <xsl:param name="replace" />
    <xsl:param name="with" />

    <xsl:choose>
        <xsl:when test="contains($string, $replace)">
            <xsl:value-of select="substring-before($string, $replace)" />
            <xsl:value-of select="$with" />
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="substring-after($string,$replace)" />
                <xsl:with-param name="replace" select="$replace" />
                <xsl:with-param name="with" select="$with" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$string" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
