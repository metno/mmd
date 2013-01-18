<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
                xmlns="http://www.met.no/schema/mm3"
                xmlns:dif="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd">

  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/gmd:MD_Metadata">
    <xsl:element name="MM3">
        <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation" />
        <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract" />
        <!-- ... -->
    </xsl:element>
  </xsl:template>

  <xsl:template match="gmd:citation">
    <xsl:element name="title">
      <xsl:attribute name="xml:lang">en_GB</xsl:attribute>
      <xsl:value-of select="gmd:CI_Citation/gmd:title/gco:CharacterString" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="gmd:abstract">
    <xsl:element name="abstract">
      <xsl:attribute name="xml:lang">en_GB</xsl:attribute>
      <xsl:value-of select="gco:CharacterString" />
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
