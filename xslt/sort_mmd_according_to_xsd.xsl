<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.met.no/schema/mmd"
    xmlns:dif="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:mmd="http://www.met.no/schema/mmd"
    xmlns:mapping_instruments="http://www.met.no/schema/mmd/instruments"
    >

    <!-- MMD elements must follow a certain order in order to be verified by the xsd -->
    <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes"/>

    <xsl:template match="mmd:mmd">

        <xsl:element name="mmd:mmd">
            <!-- 3.1 - metadata_identifier-->
            <xsl:apply-templates select="mmd:metadata_identifier"/>
            <xsl:apply-templates select="mmd:alternate_identifier"/>
            <xsl:apply-templates select="mmd:title"/>
            <xsl:apply-templates select="mmd:abstract"/>
            <xsl:apply-templates select="mmd:metadata_status"/>
            <xsl:apply-templates select="mmd:dataset_production_status"/>
            <xsl:apply-templates select="mmd:collection"/>
            <xsl:apply-templates select="mmd:last_metadata_update"/>
            <xsl:apply-templates select="mmd:temporal_extent"/>
            <xsl:apply-templates select="mmd:iso_topic_category"/>
            <xsl:apply-templates select="mmd:keywords"/>
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
            <xsl:apply-templates select="mmd:storage_information"/>

        </xsl:element>
    </xsl:template>

     <!-- TEMPLATES: -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="mmd:project">
       <xsl:element name="mmd:project">
          <xsl:element name="mmd:short_name">
             <xsl:value-of select="mmd:short_name"/>
          </xsl:element>
          <xsl:element name="mmd:long_name">
             <xsl:value-of select="mmd:long_name"/>
          </xsl:element>
       </xsl:element>
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

    <xsl:template match="mmd:use_constraint">
       <xsl:element name="mmd:use_constraint">
	  <xsl:choose>
	     <xsl:when test="mmd:license_text">
                 <xsl:element name="mmd:license_text">
                     <xsl:value-of select="mmd:license_text"/>
                 </xsl:element>
	     </xsl:when>
	     <xsl:otherwise>
                 <xsl:element name="mmd:identifier">
                    <xsl:value-of select="mmd:identifier"/>
                 </xsl:element>
                 <xsl:element name="mmd:resource">
                    <xsl:value-of select="mmd:resource"/>
                 </xsl:element>
	     </xsl:otherwise>
	  </xsl:choose>
       </xsl:element>
    </xsl:template>

    <xsl:template match="mmd:related_information">
       <xsl:element name="mmd:related_information">
          <xsl:element name="mmd:type">
             <xsl:value-of select="mmd:type"/>
          </xsl:element>
          <xsl:element name="mmd:description">
             <xsl:value-of select="mmd:description"/>
          </xsl:element>
          <xsl:element name="mmd:resource">
             <xsl:value-of select="mmd:resource"/>
          </xsl:element>
       </xsl:element>
    </xsl:template>

    <xsl:template match="mmd:data_access">
       <xsl:element name="mmd:data_access">
          <xsl:element name="mmd:name">
             <xsl:value-of select="mmd:name"/>
          </xsl:element>
          <xsl:element name="mmd:type">
             <xsl:value-of select="mmd:type"/>
          </xsl:element>
          <xsl:element name="mmd:description">
             <xsl:value-of select="mmd:description"/>
          </xsl:element>
          <xsl:element name="mmd:resource">
             <xsl:value-of select="mmd:resource"/>
          </xsl:element>
	      <xsl:if test="mmd:wms_layers">
             <xsl:apply-templates select="mmd:wms_layers"/>
	      </xsl:if>
       </xsl:element>
    </xsl:template>
</xsl:stylesheet>
