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
            <xsl:apply-templates select="mmd:instrument"/>
            <xsl:apply-templates select="mmd:platform"/>
            <xsl:apply-templates select="mmd:related_information"/>
            <xsl:apply-templates select="mmd:personnel"/>
            <xsl:apply-templates select="mmd:dataset_citation"/>
            <xsl:apply-templates select="mmd:data_access"/>
            <xsl:apply-templates select="mmd:reference"/>
            <xsl:apply-templates select="mmd:system_specific_product_category"/>
            <xsl:apply-templates select="mmd:system_specific_product_relevance"/>
            <xsl:apply-templates select="mmd:related_dataset"/>
            <xsl:apply-templates select="mmd:cloud_cover"/>
            <xsl:apply-templates select="mmd:scene_cover"/>

        </xsl:element>
    </xsl:template>

     <!-- TEMPLATES: -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
