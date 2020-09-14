<?xml version="1.0" encoding="UTF-8"?>

<!--
First attempt for MMD to DataCite conversion...
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://datacite.org/schema/kernel-4"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4/metadata.xsd"
    xmlns:mmd="http://www.met.no/schema/mmd"
    version="1.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />

        <xsl:template match="/mmd:mmd">
            <xsl:element name="resource">
		<!--unique string that identifies a resource-->
		<xsl:element name="identifier">
		    <!--A controlled list value: DOI-->
		    <xsl:attribute name="identifierType">DOI</xsl:attribute>
		    <xsl:value-of select="substring-before(' ',' ')"/>
		</xsl:element>

                <xsl:element name="alternateIdentifiers">
                   <xsl:apply-templates select="mmd:metadata_identifier" />
                   <!--xsl:apply-templates select="mmd:alternate_identifier" /-->
                </xsl:element>
                <!--xsl:apply-templates select="mmd:personnel[mmd:role='Investigator']" /-->
                <!-- not implemented yet
-->
		        <xsl:element name="titles">
		            <xsl:apply-templates select="mmd:title" />
		        </xsl:element>
                        <!--xsl:apply-templates select="mmd:data_center" /-->
                        <!-- Should reflect PublicationYear, which is
                             missing now...
                        <xsl:apply-templates select="mmd:last_metadata_update" />
                                should also map to dates with attributes dateTypes Available, Updated and Created...
-->
                        <!-- maps to descriptions/description with
                             descriptionType=Abstract
                        -->
                        <xsl:apply-templates select="mmd:abstract" />
                        <!--xsl:apply-templates select="mmd:project" /-->
                        <xsl:apply-templates select="mmd:temporal_extent" />
                        <xsl:apply-templates select="mmd:geographic_extent/mmd:rectangle" />
                        <!--xsl:apply-templates select="mmd:data_access" /-->
                        <xsl:apply-templates select="mmd:dataset_citation" />
                        <!--xsl:apply-templates select="mmd:access_constraint" /-->
                        <xsl:apply-templates select="mmd:use_constraint" />
                        <!--xsl:apply-templates select="mmd:dataset_production_status" /-->
                        <xsl:apply-templates select="mmd:dataset_language" />


                    </xsl:element>
                </xsl:template>

        <!-- Need to define identifier type... -->
        <xsl:template match="mmd:metadata_identifier">
                <xsl:element name="alternateIdentifier">
                    <!--this is free text. METNO UUID is just a suggestion-->
                    <xsl:attribute name="alternateIdentifierType">METNO UUID</xsl:attribute>
                        <xsl:value-of select="." />
                </xsl:element>
        </xsl:template>

	<xsl:template match="mmd:alternate_identifier">
                <xsl:element name="alternateIdentifier">
                    <xsl:attribute name="alternateIdentifierType">
			    <xsl:value-of select="@type" />
		    </xsl:attribute>
		    <xsl:value-of select="." />
                </xsl:element>
        </xsl:template>

	<xsl:template match="mmd:title">
		<xsl:element name="title">
		    <xsl:if test="@xml:lang != 'en'">
                        <xsl:attribute name="titleType">TranslatedTitle</xsl:attribute>
		    </xsl:if>
		    <xsl:value-of select="." />
                </xsl:element>
	</xsl:template>

	<xsl:template match="mmd:abstract">
		<xsl:element name="descriptions">
			<xsl:element name="description">
                            <xsl:attribute name="descriptionType">Abstract</xsl:attribute>
                            <xsl:value-of select="." />
			</xsl:element>
		</xsl:element>
	</xsl:template>

        <!--The main researchers involved in producing the data-->
        <xsl:template match="mmd:personnel[mmd:role='Investigator']">
                <xsl:element name="creators">
                        <xsl:element name="creator">
                        <xsl:element name="creatorName">
                        <!--how to discriminate between personal/organizational-->
                         <xsl:attribute name="nameType">Personal</xsl:attribute>
                        <xsl:value-of select="mmd:name" />
                        </xsl:element>
                     </xsl:element>
                </xsl:element>
        </xsl:template>


	<!--xsl:template match="mmd:last_metadata_update">
		<xsl:element name="dif:Last_DIF_Revision_Date">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:keywords">
		<xsl:for-each select="mmd:keyword">
			<xsl:element name="dif:Keyword">
				<xsl:value-of select="." />
			</xsl:element>
		</xsl:for-each>
	</xsl:template-->

	<xsl:template match="mmd:temporal_extent">
            <!--If temporal_extent: end_date does not exist, define Collection otherwise Dataset for resourceTypeGeneral attribute-->
            <xsl:element name="resourceType">
                <xsl:choose>
                    <xsl:when test="mmd:end_date = ''">
                        <xsl:attribute name="resourceTypeGeneral"><xsl:text>Collection</xsl:text></xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="resourceTypeGeneral"><xsl:text>Dataset</xsl:text></xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>Dataset</xsl:text>
	    </xsl:element>
        </xsl:template>

        <xsl:template match="mmd:geographic_extent/mmd:rectangle">
            <xsl:element name="geoLocations">
                <xsl:element name="geoLocation">
                    <xsl:element name="geoLocationBox">
                        <xsl:element name="southBoundLatitude">
                            <xsl:value-of select="mmd:south" />
                        </xsl:element>
                        <xsl:element name="northBoundLatitude">
                            <xsl:value-of select="mmd:north" />
                        </xsl:element>
                        <xsl:element name="westBoundLongitude">
                            <xsl:value-of select="mmd:west" />
                        </xsl:element>
                        <xsl:element name="eastBoundLongitude">
                            <xsl:value-of select="mmd:east" />
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:template>

	<!--xsl:template match="mmd:data_access">
		<xsl:element name="dif:Related_URL">
			<xsl:element name="dif:URL_Content_Type">
				<xsl:element name="dif:Type">
					<xsl:value-of select="mmd:type" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="dif:URL">
				<xsl:value-of select="mmd:resource" />
			</xsl:element>
			<xsl:element name="dif:Description">
				<xsl:value-of select="mmd:description" />
			</xsl:element>
		</xsl:element>
	</xsl:template-->

	<!--xsl:template match="mmd:project">
		<xsl:element name="dif:Project">
			<xsl:element name="dif:Short_Name">
				<xsl:value-of select="mmd:short_name" />
			</xsl:element>
			<xsl:element name="dif:Long_Name">
				<xsl:value-of select="mmd:long_name" />
			</xsl:element>
		</xsl:element>
	</xsl:template-->


	<xsl:template match="mmd:use_constraint">
		<xsl:element name="rightsList">
                    <xsl:element name="rights">
                        <xsl:attribute name="rightsURI"><xsl:value-of select="mmd:resource" /></xsl:attribute>
                        <xsl:attribute name="rightsIdentifier"><xsl:value-of select="mmd:identifier" /></xsl:attribute>
                        <xsl:attribute name="schemeURI">https://spdx.org/licenses/</xsl:attribute>
                        <xsl:attribute name="rightsIdentifierScheme">SPDX</xsl:attribute>
			<xsl:value-of select="mmd:identifier" />
                    </xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:dataset_language">
		<xsl:element name="language">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<!--xsl:template match="mmd:data_center">
		<xsl:element name="publisher">
                    <xsl:element name="dif:Data_Center_Name">
                        <xsl:value-of select="mmd:data_center_name/mmd:long_name" />
                    </xsl:element>
		</xsl:element>
	</xsl:template-->


    <xsl:template match="mmd:dataset_citation">

        <!--The year when the data was or will be made publicly available.-->
        <xsl:element name="publicationYear">
            <!--extract YYYY from format YYYY-MM-DDTHH:MM:SSZ-->
            <xsl:value-of select = "substring-before(mmd:publication_date, '-')" />
        </xsl:element>
        <!--The name of the entitythat holds, archives, publishes prints, distributes,
	     releases, issues, or produces the resource.-->
        <xsl:element name="publisher">
            <xsl:value-of select="mmd:publisher" />
        </xsl:element>

        <xsl:element name="creators">
           <xsl:call-template name="tokenize">
              <xsl:with-param name="author" select="mmd:author"/>
           </xsl:call-template>
	</xsl:element>

        <!--xsl:element name="dif:Data_Set_Citation">
            <xsl:element name="dif:Dataset_Creator">
                <xsl:value-of select="mmd:dataset_creator" />
            </xsl:element>
            <xsl:element name="dif:Dataset_Editor">
                <xsl:value-of select="mmd:dataset_editor" />
            </xsl:element>
            <xsl:element name="dif:Dataset_Title">
                <xsl:value-of select="mmd:dataset_title" />
            </xsl:element>
            <xsl:element name="dif:Dataset_Series_Name">
                <xsl:value-of select="mmd:dataset_series_name" />
            </xsl:element>
            <xsl:element name="dif:Dataset_Release_Place">
                <xsl:value-of select="mmd:dataset_release_place" />
            </xsl:element>
            <xsl:element name="dif:Version">
                <xsl:value-of select="mmd:version" />
            </xsl:element>
            <xsl:element name="dif:Data_Presentation_Form">
                <xsl:value-of select="mmd:dataset_presentation_form" />
            </xsl:element>
            <xsl:element name="dif:Online_Resource">
                <xsl:value-of select="mmd:online_resource" />
            </xsl:element>
        </xsl:element-->

    </xsl:template>

    <xsl:template name="tokenize">
    <xsl:param name="author"/>
    <xsl:choose>
        <xsl:when test="contains($author, ',')">
        <xsl:element name="creator">
        <xsl:element name="creatorName">
        <!--xsl:attribute name="nameType">Personal</xsl:attribute-->
            <xsl:value-of select="normalize-space(substring-before($author, ','))"/>
        </xsl:element>
        </xsl:element>
        <xsl:call-template name="tokenize">
            <xsl:with-param name="author" select="normalize-space(substring-after($author, ','))"/>
        </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
        <xsl:element name="creator">
        <xsl:element name="creatorName">
        <!--xsl:attribute name="nameType">Personal</xsl:attribute-->
            <xsl:value-of select="normalize-space($author)"/>
        </xsl:element>
        </xsl:element>
        </xsl:otherwise>
    </xsl:choose>
 </xsl:template>

</xsl:stylesheet>
