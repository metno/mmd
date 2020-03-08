<?xml version="1.0" encoding="UTF-8"?>
<!--
XSLT to update old MMD records to the new sequence based structure imposed
by XSD. Use this also as basis for adding additional collection keywords
if necessary.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:m="http://www.met.no/schema/metamod/MM2"
    xmlns:mmd="http://www.met.no/schema/mmd"
    xmlns="http://www.met.no/schema/mmd"
    xmlns:mapping="http://www.met.no/schema/metamod/mmd2mm2"
    xmlns:xmd="http://www.met.no/schema/metamod/dataset" version="1.0">

    <xsl:output method="xml" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*"/>

    <xsl:template match="/mmd:mmd">
        <xsl:element name="mmd:mmd">

            <xsl:copy-of select="mmd:metadata_identifier" />
            <xsl:copy-of select="mmd:title" />
            <xsl:copy-of select="mmd:abstract" />
            <xsl:copy-of select="mmd:metadata_status" />
            <xsl:copy-of select="mmd:dataset_production_status" />
            <xsl:copy-of select="mmd:collection" />
            <xsl:copy-of select="mmd:last_metadata_update" />
            <xsl:copy-of select="mmd:temporal_extent" />
            <xsl:copy-of select="mmd:iso_topic_category" />
            <xsl:copy-of select="mmd:keywords" />
            <xsl:copy-of select="mmd:operational_status" />
            <xsl:copy-of select="mmd:dataset_language" />
            <xsl:copy-of select="mmd:geographic_extent" />
            <xsl:copy-of select="mmd:access_constraint" />
            <xsl:copy-of select="mmd:use_constraint" />
            <xsl:copy-of select="mmd:project" />
            <xsl:copy-of select="mmd:activity_type" />
            <xsl:copy-of select="mmd:instrument" />
            <xsl:copy-of select="mmd:platform" />
            <xsl:copy-of select="mmd:related_information" />
            <xsl:copy-of select="mmd:personnel" />
            <xsl:copy-of select="mmd:dataset_citation" />
            <xsl:copy-of select="mmd:data_access" />
            <xsl:copy-of select="mmd:reference" />
            <xsl:copy-of select="mmd:data_center" />
            <xsl:copy-of select="mmd:related_dataset"/>
            <xsl:copy-of select="mmd:cloud_cover"/>
            <xsl:copy-of select="mmd:scene_cover"/>

        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
