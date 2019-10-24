<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <xsl:for-each select="Metadata_collection/submitted_metadata">
            <xsl:result-document href="file{position()}.xml">
                <metadata>
                    <xsl:copy-of select="current()"/>
                </metadata>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
