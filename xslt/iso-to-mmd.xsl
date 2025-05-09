<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
    xmlns="http://www.met.no/schema/mmd"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:gmi="http://www.isotc211.org/2005/gmi"
    xmlns:gml32="http://www.opengis.net/gml/3.2"
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:mmd="http://www.met.no/schema/mmd"
    xmlns:mapping="http://www.met.no/schema/mmd/iso2mmd">

    <xsl:output method="xml" encoding="UTF-8" indent="yes" />
    <xsl:variable name="vocdoc" select="document('../thesauri/mmd-vocabulary.xml')"/>

    <xsl:key name="usec"
    match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/Use_Constraint']/skos:member/skos:Concept"
    use="skos:prefLabel"/>
    <xsl:key name="usecalt"
    match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/Use_Constraint']/skos:member/skos:Concept"
    use="skos:altLabel"/>
    <xsl:key name="usechidden"
    match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/Use_Constraint']/skos:member/skos:Concept"
    use="skos:hiddenLabel"/>
    <xsl:key name="usecexact"
    match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/Use_Constraint']/skos:member/skos:Concept/skos:exactMatch"
    use="@rdf:resource"/>

    <xsl:key name="accessc"
    match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/Access_Constraint']/skos:member/skos:Concept"
    use="skos:prefLabel"/>
    <xsl:key name="accessalt"
    match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/Access_Constraint']/skos:member/skos:Concept"
    use="skos:altLabel"/>
    <xsl:key name="accesshidden"
    match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/Access_Constraint']/skos:member/skos:Concept"
    use="skos:hiddenLabel"/>
    <!--
    <xsl:template match="/[name() = 'gmd:MD_Metadata' or name() = 'gmi:MI_Metadata']">
    -->
    <xsl:template match="gmd:MD_Metadata | gmi:MI_Metadata">
        <xsl:element name="mmd:mmd">
            <xsl:apply-templates select="gmd:fileIdentifier/gco:CharacterString" />
            <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation" />
            <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract" />
            <xsl:element name="mmd:metadata_status">Active</xsl:element>
            <xsl:element name="mmd:dataset_production_status">
                <xsl:choose>
                    <xsl:when test="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:status">
                        <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:status"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Not available</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
	        </xsl:element>
            <xsl:element name="mmd:collection">ADC</xsl:element>
            <xsl:apply-templates select="gmd:dateStamp" />
            <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent" />
		    <xsl:choose>
                <xsl:when test="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory/gmd:MD_TopicCategoryCode !=''">
                    <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory/gmd:MD_TopicCategoryCode" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="mmd:iso_topic_category">
                        <xsl:text>Not available</xsl:text>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:element name="mmd:keywords">
                <xsl:attribute name="vocabulary">GCMDSK</xsl:attribute>
                <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString[contains(.,'EARTH SCIENCE &gt;')]" />
            </xsl:element>
            <xsl:element name="mmd:keywords">
                <xsl:attribute name="vocabulary">None</xsl:attribute>
                <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString[not(contains(.,'EARTH SCIENCE &gt;'))]" />
            </xsl:element>
            <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords[./gmd:type/gmd:MD_KeywordTypeCode[@codeListValue= 'project']]" />
            <!--
            <mmd:metadata_version>1</mmd:metadata_version>
            -->
            <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:language" />

            <xsl:apply-templates select="gmd:contact/gmd:CI_ResponsibleParty" />
            <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty" />

            <xsl:element name="mmd:geographic_extent">
                <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox" />
                <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_BoundingPolygon/gmd:polygon" />
            </xsl:element>

            <xsl:apply-templates select="gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor" />
            <!--- FIXME merged with next during testing...
            <xsl:apply-templates select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine" />
            -->
            <xsl:apply-templates select="gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:connectPoint" />

            <xsl:apply-templates select="gmd:dataSetURI/gco:CharacterString" />
            <xsl:apply-templates select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource" />

            <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:accessConstraints" />
            <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation | gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_Constraints/gmd:useLimitation | gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useConstraints" />

        </xsl:element>
    </xsl:template>

    <xsl:template match="gmd:fileIdentifier/gco:CharacterString">
        <xsl:element name="mmd:metadata_identifier">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <xsl:template match="gmd:citation">
        <xsl:element name="mmd:title">
            <xsl:attribute name="xml:lang">en</xsl:attribute>
            <xsl:value-of select="gmd:CI_Citation/gmd:title/gco:CharacterString" />
        </xsl:element>
    </xsl:template>

    <xsl:template match="gmd:abstract">
        <xsl:element name="mmd:abstract">
            <xsl:attribute name="xml:lang">en</xsl:attribute>
            <xsl:value-of select="gco:CharacterString" />
        </xsl:element>
    </xsl:template>

    <xsl:template match="gmd:dateStamp">
        <xsl:element name="mmd:last_metadata_update">
            <xsl:element name="mmd:update">
                <xsl:element name="mmd:datetime">
                    <xsl:choose>
                        <xsl:when test="gco:DateTime">
                            <xsl:value-of select="gco:DateTime" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="gco:Date" />
                            <xsl:text>T00:00:00.001Z</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <xsl:element name="mmd:type">
                    <xsl:text>Minor modification</xsl:text>
                </xsl:element>
                <xsl:element name="mmd:note">
                    <xsl:text>Created automatically from harvested information.</xsl:text>
                </xsl:element>
            </xsl:element>
        </xsl:element>

        <!--
        <xsl:element name="mmd:last_metadata_update"><xsl:value-of select="gco:Date" /> </xsl:element>
    -->
    </xsl:template>

    <xsl:template match="gmd:language">
        <xsl:element name="mmd:dataset_language">
            <xsl:choose>
                <xsl:when test="gmd:LanguageCode">
                    <xsl:value-of select="gmd:LanguageCode" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="gco:CharacterString" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="gmd:status">
        <xsl:variable name="iso_status" select="normalize-space(gmd:MD_ProgressCode/@codeListValue)" />
        <xsl:variable name="iso_status_mapping" select="document('')/*/mapping:dataset_status[@iso=$iso_status]" />
        <xsl:value-of select="$iso_status_mapping" />
        <xsl:choose>
            <xsl:when test="$iso_status_mapping/@mmd != ''">
                <xsl:value-of select="$iso_status_mapping/@mmd"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Not available</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- mapping between iso and mmd dataset statuses -->
    <mapping:dataset_status iso="completed" mmd="Complete" />
    <mapping:dataset_status iso="historicalArchive" mmd="Complete" />
    <mapping:dataset_status iso="obsolete" mmd="Obsolete" />
    <mapping:dataset_status iso="onGoing" mmd="In Work" />
    <mapping:dataset_status iso="planned" mmd="Planned" />
    <mapping:dataset_status iso="required" mmd="Planned" />
    <mapping:dataset_status iso="underDevelopment" mmd="Planned" />

    <xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory/gmd:MD_TopicCategoryCode">
        <xsl:element name="mmd:iso_topic_category">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent">
        <xsl:element name="mmd:temporal_extent">
            <xsl:element name="mmd:start_date">
                <xsl:variable name="startdate">
                    <xsl:choose>
                        <xsl:when test="contains(gml:TimePeriod/gml:beginPosition, 'T') or contains(gml32:TimePeriod/gml32:beginPosition, 'T')">
                            <xsl:value-of select="gml:TimePeriod/gml:beginPosition | gml32:TimePeriod/gml32:beginPosition" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(gml:TimePeriod/gml:beginPosition | gml32:TimePeriod/gml32:beginPosition, 'T12:00:00Z')" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <!--Make sure the start date is a valid datetime element-->
                <xsl:if test="not(contains($startdate, 'None')) and not(contains($startdate, 'unknown')) and not(contains($startdate, '--')) and (string-length(normalize-space(substring-before($startdate, 'T'))) = 10)">
                    <xsl:value-of select="$startdate" />
                </xsl:if>
            </xsl:element>
            <xsl:variable name="enddate">
                <xsl:choose>
                    <xsl:when test="contains(gml:TimePeriod/gml:endPosition, 'T') or contains(gml32:TimePeriod/gml32:endPosition, 'T')">
                        <xsl:value-of select="gml:TimePeriod/gml:endPosition | gml32:TimePeriod/gml32:endPosition" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(gml:TimePeriod/gml:endPosition | gml32:TimePeriod/gml32:endPosition, 'T12:00:00Z')" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="not(contains($enddate, 'None')) and not(contains($enddate, 'unknown')) and not(contains($enddate, '--')) and (string-length(normalize-space(substring-before($enddate, 'T'))) = 10)">
                <xsl:element name="mmd:end_date">
                    <xsl:value-of select="$enddate" />
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
        <xsl:element name="mmd:rectangle">
            <xsl:attribute name="srsName">
                <xsl:value-of select="'EPSG:4326'" />
            </xsl:attribute>
            <xsl:element name="mmd:north">
                <xsl:value-of select="gmd:northBoundLatitude/gco:Decimal" />
            </xsl:element>
            <xsl:element name="mmd:south">
                <xsl:value-of select="gmd:southBoundLatitude/gco:Decimal" />
            </xsl:element>
            <xsl:element name="mmd:west">
                <xsl:value-of select="gmd:westBoundLongitude/gco:Decimal" />
            </xsl:element>
            <xsl:element name="mmd:east">
                <xsl:value-of select="gmd:eastBoundLongitude/gco:Decimal" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_BoundingPolygon/gmd:polygon">
        <xsl:element name="mmd:polygon">
            <xsl:copy-of select="gml:Polygon | gml32:Polygon" />
        </xsl:element>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:accessConstraints">
        <xsl:variable name="isoaccess">
            <xsl:if test="gmd:MD_RestrictionCode[@codeListValue='otherRestrictions']">
                <xsl:value-of select="../gmd:otherConstraints/gco:CharacterString | ../gmd:otherConstraints/gmx:Anchor" />
            </xsl:if>
        </xsl:variable>
        <xsl:if test="$isoaccess !=''">
            <xsl:for-each select="$vocdoc" >
                <xsl:if test="key('accessc', $isoaccess)">
                    <xsl:element name="mmd:access_constraint">
                        <xsl:value-of select="key('accessc', $isoaccess)/skos:prefLabel" />
                    </xsl:element>
                </xsl:if>
                <xsl:if test="key('accessalt', $isoaccess)">
                    <xsl:element name="mmd:access_constraint">
                        <xsl:value-of select="key('accessalt', $isoaccess)/skos:prefLabel" />
                    </xsl:element>
                </xsl:if>
                <xsl:if test="key('accesshidden', $isoaccess)">
                    <xsl:element name="mmd:access_constraint">
                        <xsl:value-of select="key('accesshidden', $isoaccess)/skos:prefLabel" />
                    </xsl:element>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useLimitation |
                         gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_Constraints/gmd:useLimitation |
                         gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useConstraints">
        <!--extract text in isouse-->
        <xsl:variable name="isouse" select="gco:CharacterString[not(starts-with(., 'http://')) and not(starts-with(., 'https://'))] |
        ../gmd:otherConstraints/gco:CharacterString[not(starts-with(., 'http://')) and not(starts-with(., 'https://'))] | gmx:Anchor | ../gmd:otherConstraints/gmx:Anchor"/>

        <!--extract urls (both for Anchor and strings) in isouseref-->
        <xsl:variable name="unparsedisoref" select="gmx:Anchor/@xlink:href |
        ../gmd:otherConstraints/gmx:Anchor/@xlink:href | gco:CharacterString[starts-with(., 'http://') or starts-with(.,
        'https://')] | ../gmd:otherConstraints/gco:CharacterString[starts-with(., 'http://') or starts-with(., 'https://') ]"/>
        <xsl:variable name="isouseref">
            <xsl:choose>
                <xsl:when test="contains($unparsedisoref, '.html')">
                    <xsl:value-of select="substring-before($unparsedisoref, '.html')" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$unparsedisoref" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="httpref" select="concat('http://',substring-after($isouseref,'://'))"/>
        <xsl:variable name="httpsref" select="concat('https://',substring-after($isouseref,'://'))"/>

        <!--lookup license as string-->
        <xsl:if test="not(normalize-space($isouse)='') or not(normalize-space($isouseref)='')">
            <xsl:for-each select="$vocdoc" >
                <xsl:choose>
                    <!--Check that value matches the prefLabel CC-BY-NC-ND-4.0-->
                    <xsl:when test="key('usec', $isouse)">
                        <xsl:variable name="prefuseid" select="key('usec', $isouse)/skos:prefLabel"/>
                        <xsl:variable name="prefuseref" select="key('usec', $isouse)/skos:exactMatch/@rdf:resource[contains(.,'spdx')]"/>
                        <xsl:element name="mmd:use_constraint">
                            <xsl:element name="mmd:identifier">
                                <xsl:value-of select="$prefuseid" />
                            </xsl:element>
                            <xsl:element name="mmd:resource">
                                <xsl:value-of select="$prefuseref" />
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <!--Check that value matches the altLabel e.g. CC BY-NC-SA 4.0 -->
                    <xsl:when test="key('usecalt', $isouse)">
                        <xsl:variable name="prefuseid" select="key('usecalt', $isouse)/skos:prefLabel"/>
                        <xsl:variable name="prefuseref" select="key('usecalt', $isouse)/skos:exactMatch/@rdf:resource[contains(.,'spdx')]"/>
                        <xsl:element name="mmd:use_constraint">
                            <xsl:element name="mmd:identifier">
                                <xsl:value-of select="$prefuseid" />
                            </xsl:element>
                            <xsl:element name="mmd:resource">
                                <xsl:value-of select="$prefuseref" />
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="key('usechidden', $isouse)">
                        <xsl:variable name="prefuseid" select="key('usechidden', $isouse)/skos:prefLabel"/>
                        <xsl:variable name="prefuseref" select="key('usechidden', $isouse)/skos:exactMatch/@rdf:resource[contains(.,'spdx')]"/>
                        <xsl:element name="mmd:use_constraint">
                            <xsl:element name="mmd:identifier">
                                <xsl:value-of select="$prefuseid" />
                            </xsl:element>
                            <xsl:element name="mmd:resource">
                                <xsl:value-of select="$prefuseref" />
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <!--Check that value matches the urls: <gmx:Anchor xlink:href="https://creativecommons.org/licenses/by-nc-sa/4.0/">Creative-Commons CC BY-NC-SA 4.0</gmx:Anchor> -->
                    <xsl:when test="key('usecexact', $httpref)">
                        <xsl:variable name="prefuseid" select="key('usecexact', $httpref)/../skos:prefLabel"/>
                        <xsl:variable name="prefuseref" select="key('usecexact', $httpref)/../skos:exactMatch/@rdf:resource[contains(.,'spdx')]"/>
                        <xsl:element name="mmd:use_constraint">
                            <xsl:element name="mmd:identifier">
                                <xsl:value-of select="$prefuseid" />
                            </xsl:element>
                            <xsl:element name="mmd:resource">
                                <xsl:value-of select="$prefuseref" />
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="key('usecexact', $httpsref)">
                        <xsl:variable name="prefuseid" select="key('usecexact', $httpsref)/../skos:prefLabel"/>
                        <xsl:variable name="prefuseref" select="key('usecexact', $httpsref)/../skos:exactMatch/@rdf:resource[contains(.,'spdx')]"/>
                        <xsl:element name="mmd:use_constraint">
                            <xsl:element name="mmd:identifier">
                                <xsl:value-of select="$prefuseid" />
                            </xsl:element>
                            <xsl:element name="mmd:resource">
                                <xsl:value-of select="$prefuseref" />
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="mmd:use_constraint">
                            <xsl:element name="mmd:license_text">
                                <xsl:choose>
                                    <xsl:when test="$isouseref != '' and $isouse != ''">
                                        <xsl:value-of select="concat($isouseref,' (',$isouse,')')" />
                                    </xsl:when>
                                    <xsl:when test="$isouseref != '' and $isouse = ''">
                                        <xsl:value-of select="$isouseref" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$isouse" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gmd:contact/gmd:CI_ResponsibleParty">
        <xsl:element name="mmd:personnel">
            <xsl:element name="mmd:role">
                <xsl:choose>
                    <xsl:when test="gmd:role/gmd:CI_RoleCode[@codeListValue='principalInvestigator']">
                        <xsl:text>Investigator</xsl:text>
                    </xsl:when>
                    <xsl:when test="gmd:role/gmd:CI_RoleCode[@codeListValue='pointOfContact']">
                        <xsl:text>Technical contact</xsl:text>
                    </xsl:when>
                    <xsl:when test="gmd:role/gmd:CI_RoleCode[@codeListValue='author']">
                        <xsl:text>Metadata author</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Technical contact</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>

            <xsl:element name="mmd:name">
                <xsl:value-of select="gmd:individualName/gco:CharacterString" />
            </xsl:element>

            <xsl:element name="mmd:organisation">
                <xsl:value-of select="gmd:organisationName/gco:CharacterString" />
            </xsl:element>

            <xsl:element name="mmd:email">
                <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString" />
            </xsl:element>

            <xsl:element name="mmd:phone">
                <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gco:CharacterString" />
            </xsl:element>

            <xsl:element name="mmd:fax">
                <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:facsimile/gco:CharacterString" />
            </xsl:element>

            <xsl:element name="mmd:contact_address">
                <xsl:element name="mmd:address">
                    <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gco:CharacterString" />
                </xsl:element>
                <xsl:element name="mmd:city">
                    <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city/gco:CharacterString" />
                </xsl:element>
                <xsl:element name="mmd:province_or_state">
                    <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea/gco:CharacterString" />
                </xsl:element>
                <xsl:element name="mmd:postal_code">
                    <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode/gco:CharacterString" />
                </xsl:element>
                <xsl:element name="mmd:country">
                    <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country/gco:CharacterString" />
                </xsl:element>
            </xsl:element>

        </xsl:element>
    </xsl:template>

    <!-- handling CNR data from GeoNetwork -->
    <xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty">
        <xsl:element name="mmd:personnel">
            <xsl:element name="mmd:role">
                <xsl:text>Investigator</xsl:text>
            </xsl:element>
            <xsl:element name="mmd:name">
                <xsl:value-of select="gmd:individualName/gco:CharacterString" />
            </xsl:element>
            <xsl:element name="mmd:organisation">
                <xsl:value-of select="gmd:organisationName/gco:CharacterString" />
            </xsl:element>
            <xsl:element name="mmd:email">
                <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString" />
            </xsl:element>
            <xsl:element name="mmd:phone">
                <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gco:CharacterString" />
            </xsl:element>
            <xsl:element name="mmd:fax">
                <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:facsimile/gco:CharacterString" />
            </xsl:element>
            <xsl:element name="mmd:contact_address">
                <xsl:element name="mmd:address">
                    <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gco:CharacterString" />
                </xsl:element>
                <xsl:element name="mmd:city">
                    <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city/gco:CharacterString" />
                </xsl:element>
                <xsl:element name="mmd:province_or_state">
                    <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea/gco:CharacterString" />
                </xsl:element>
                <xsl:element name="mmd:postal_code">
                    <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode/gco:CharacterString" />
                </xsl:element>
                <xsl:element name="mmd:country">
                    <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country/gco:CharacterString" />
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- get data access from NILU -->
    <xsl:template match="gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:connectPoint">
        <xsl:element name="mmd:data_access">
            <xsl:element name="mmd:type">
                <xsl:variable name="external_name" select="normalize-space(gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString)" />
                <xsl:variable name="protocol_mapping" select="document('')/*/mapping:protocol_names[@external=$external_name]" />
                <xsl:value-of select="$protocol_mapping" />
                <xsl:value-of select="$protocol_mapping/@mmd"></xsl:value-of>
            </xsl:element>
            <xsl:element name="mmd:resource">
                <xsl:value-of select="gmd:CI_OnlineResource/gmd:linkage/gmd:URL" />
            </xsl:element>
        </xsl:element>
    </xsl:template>


    <!-- Extract information on host data center -->
    <xsl:template match="gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor">
        <xsl:element name="mmd:data_center">
            <xsl:element name="mmd:data_center_name">
                <xsl:element name="mmd:short_name">
                    <!--xsl:value-of select=""/-->
                </xsl:element>
                <xsl:element name="mmd:long_name">
                    <xsl:value-of select="gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString"/>
                </xsl:element>
            </xsl:element>
            <xsl:element name="mmd:data_center_url">
                <xsl:value-of select="gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Extract information on online resources -->
    <!-- mapping between protocol names -->
    <mapping:protocol_names external="OPeNDAP:OPeNDAP" mmd="OPeNDAP" />
    <mapping:protocol_names external="WWW:OPENDAP" mmd="OPeNDAP" />
    <mapping:protocol_names external="WWW:LINK-1.0-http--opendap" mmd="OPeNDAP" />
    <mapping:protocol_names external="file" mmd="HTTP" />
    <mapping:protocol_names external="WWW:FTP" mmd="HTTP" />
    <mapping:protocol_names external="OGC:WMS:getCapabilities" mmd="OGC WMS" />
    <mapping:protocol_names external="OGC:WFS" mmd="OGC WFS" />
    <mapping:protocol_names external="OGC:GML" mmd="OGC GML" />
    <mapping:protocol_names external="WWW:DOWNLOAD-1.0-http--download" mmd="HTTP" />
    <mapping:protocol_names external="csv" mmd="HTTP" />
    <mapping:protocol_names external="graph" mmd="HTTP" />

    <xsl:template match="gmd:dataSetURI/gco:CharacterString">
        <xsl:element name="mmd:related_information">
            <xsl:element name="mmd:type">Dataset landing page</xsl:element>
            <xsl:element name="mmd:description">NA</xsl:element>
            <xsl:element name="mmd:resource">
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource">
        <!-- to extract landing pages from GeoNetwork -->
        <!--
        <xsl:if test="gmd:protocol/gco:CharacterString and gmd:linkage/gmd:URL">
        <xsl:if test="gmd:function/gmd:CI_OnLineFunctionCode">
            <xsl:element name="mmd:related_information">
                <xsl:text>Min test</xsl:text>
            </xsl:element>
        </xsl:if>
        -->
        <!-- mapping vocabulary for URLs -->

        <xsl:choose>
            <!-- Decode landing pages for those data centres putting it here -->
            <xsl:when test="gmd:function/gmd:CI_OnLineFunctionCode/@codeListValue='information' and gmd:description/gco:CharacterString='Extended human readable information about the dataset'">
                <xsl:element name="mmd:related_information">
                    <xsl:element name="mmd:type">Dataset landing page</xsl:element>
                    <xsl:element name="mmd:description">
                        <xsl:value-of select="gmd:description/gco:CharacterString"/>
                    </xsl:element>
                    <xsl:element name="mmd:resource">
                        <xsl:value-of select="gmd:linkage/gmd:URL"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <!-- For handling of data from GeoNetwork, e.g. from CNR -->
            <xsl:when test="gmd:name/gco:CharacterString='Landing page'">
                <xsl:element name="mmd:related_information">
                    <xsl:element name="mmd:type">Dataset landing page</xsl:element>
                    <xsl:element name="mmd:description">
                        <xsl:value-of select="gmd:description/gco:CharacterString"/>
                    </xsl:element>
                    <xsl:element name="mmd:resource">
                        <xsl:value-of select="gmd:linkage/gmd:URL"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:when test="gmd:name/gco:CharacterString='Project on RiS'">
                <xsl:element name="mmd:related_information">
                    <xsl:element name="mmd:type">Other documentation</xsl:element>
                    <xsl:element name="mmd:description">
                        <xsl:value-of select="gmd:description/gco:CharacterString"/>
                    </xsl:element>
                    <xsl:element name="mmd:resource">
                        <xsl:value-of select="gmd:linkage/gmd:URL"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <!-- For handling of WGMS data they mix this and have no good keyword, the project home page is identified using a string -->
            <xsl:when test="gmd:name/gco:CharacterString='Homepage'">
                <xsl:element name="mmd:related_information">
                    <xsl:element name="mmd:type">Project home page</xsl:element>
                    <xsl:element name="mmd:description">
                        <xsl:value-of select="gmd:description/gco:CharacterString"/>
                    </xsl:element>
                    <xsl:element name="mmd:resource">
                        <xsl:value-of select="gmd:linkage/gmd:URL"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>

            <!-- Decode data_access for those data centres putting it here (most) the download function from gmxCodelists.xml (ISO19139) can't be used as direct download... -->
            <xsl:when test="gmd:protocol/gco:CharacterString and gmd:linkage/gmd:URL">
                <xsl:variable name="external_name" select="normalize-space(gmd:protocol/gco:CharacterString)" />
                <xsl:variable name="protocol_mapping" select="document('')/*/mapping:protocol_names[@external=$external_name]" />
                <xsl:if test="$protocol_mapping/@mmd != ''">
                    <xsl:element name="mmd:data_access">
                        <xsl:element name="mmd:type">
                            <xsl:value-of select="$protocol_mapping" />
                            <xsl:value-of select="$protocol_mapping/@mmd" />
                        </xsl:element>
                        <xsl:element name="mmd:description">
                            <xsl:value-of select="gmd:description/gco:CharacterString"/>
                        </xsl:element>
                        <xsl:element name="mmd:resource">
                            <xsl:value-of select="gmd:linkage/gmd:URL"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
            </xsl:when>
            <xsl:when test="gmd:function/gmd:CI_OnLineFunctionCode and gmd:linkage/gmd:URL">
                <xsl:if test="not(gmd:function/gmd:CI_OnLineFunctionCode/@codeListValue='download') and not(gmd:function/gmd:CI_OnLineFunctionCode/@codeListValue='information')">
                    <xsl:variable name="external_name" select="normalize-space(gmd:function/gmd:CI_OnLineFunctionCode)" />
                    <xsl:variable name="protocol_mapping" select="document('')/*/mapping:protocol_names[@external=$external_name]" />
                    <xsl:element name="mmd:data_access">
                        <xsl:element name="mmd:type">
                            <xsl:value-of select="$protocol_mapping" />
                            <xsl:value-of select="$protocol_mapping/@mmd" />
                        </xsl:element>
                        <xsl:element name="mmd:description">
                            <xsl:value-of select="gmd:description/gco:CharacterString"/>
                        </xsl:element>
                        <xsl:element name="mmd:resource">
                            <xsl:value-of select="gmd:linkage/gmd:URL"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString[contains(.,'EARTH SCIENCE &gt;')]">
        <xsl:element name="mmd:keyword">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString[not(contains(.,'EARTH SCIENCE &gt;'))]">
        <xsl:element name="mmd:keyword">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <!--
    <xsl:template match="gmd:keyword">
        <xsl:element name="mmd:keyword">
            <xsl:value-of select="gco:CharacterString" />
        </xsl:element>
    </xsl:template>
    -->

    <xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords[./gmd:type/gmd:MD_KeywordTypeCode[@codeListValue = 'project']]">
        <xsl:for-each select="gmd:keyword/gco:CharacterString">
            <xsl:element name="mmd:project">
                <xsl:element name="mmd:short_name">
                    <xsl:value-of select="." />
                </xsl:element>
                <xsl:element name="mmd:long_name">
                    <xsl:value-of select="." />
                </xsl:element>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
