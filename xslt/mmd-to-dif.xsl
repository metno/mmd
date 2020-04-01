<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dif="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/" 
    xmlns:mmd="http://www.met.no/schema/mmd"
    xmlns:dc="http://purl.org/dc/elements/1.1/" version="1.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />

	<xsl:template match="/mmd:mmd">
		<xsl:element name="dif:DIF">
			<xsl:apply-templates select="mmd:metadata_identifier" />
			<xsl:apply-templates select="mmd:title" />
			<xsl:apply-templates select="mmd:dataset_citation" />
                        <xsl:apply-templates select="mmd:personnel[mmd:role='Investigator']" />
			<xsl:apply-templates select="mmd:keywords[@vocabulary='GCMD']" />
			<xsl:apply-templates select="mmd:iso_topic_category" />
			<xsl:apply-templates select="mmd:instrument" />
			<xsl:apply-templates select="mmd:platform" />
			<xsl:apply-templates select="mmd:temporal_extent" />
			<xsl:apply-templates select="mmd:dataset_production_status" />
			<xsl:apply-templates select="mmd:geographic_extent/mmd:rectangle" />
			<xsl:apply-templates select="mmd:project" />
			<xsl:apply-templates select="mmd:access_constraint" />
			<xsl:apply-templates select="mmd:use_constraint" />
			<xsl:apply-templates select="mmd:dataset_language" />
                        <xsl:element name="dif:Originating_Center">
                            <xsl:value-of select="mmd:organisation" />
                        </xsl:element>
                        <xsl:choose>
                            <xsl:when test="not(mmd:data_center)">
                                <xsl:element name="dif:Data_Center">
                                    <xsl:element name="dif:Data_Center_Name">
                                        <xsl:element name="dif:Short_Name">
                                            <xsl:text>MET</xsl:text>
                                        </xsl:element>
                                        <xsl:element name="dif:Long_Name">
                                            <xsl:text>Norwegian Meteorological Institute</xsl:text>
                                        </xsl:element>
                                    </xsl:element>
                                    <xsl:element name="dif:Data_Center_URL">
                                        <xsl:text>https://adc.met.no/</xsl:text>
                                    </xsl:element>
                                    <xsl:element name="dif:Personnel">
                                        <xsl:element name="dif:Role">Technical Contact</xsl:element>
                                        <xsl:element name="dif:Last_Name">ADC Support</xsl:element>
                                        <xsl:element name="dif:Email">adc-support@met.no</xsl:element>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="mmd:data_center" />
                            </xsl:otherwise>
                        </xsl:choose>
			<xsl:apply-templates select="mmd:abstract" />
			<xsl:apply-templates select="mmd:data_access" />

			<xsl:element name="dif:Metadata_Name">CEOS IDN DIF</xsl:element>
			<xsl:element name="dif:Metadata_Version">9.8.4</xsl:element>
			<xsl:apply-templates select="mmd:last_metadata_update" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:metadata_identifier">
		<xsl:element name="dif:Entry_ID">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:title">
		<xsl:element name="dif:Entry_Title">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:abstract">
		<xsl:element name="dif:Summary">
			<xsl:element name="dif:Abstract">
				<xsl:value-of select="." />
			</xsl:element>
			<xsl:element name="dif:Purpose" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:last_metadata_update">
		<xsl:element name="dif:Last_DIF_Revision_Date">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

        <xsl:template match="mmd:keywords[@vocabulary='GCMD']">
            <xsl:for-each select="mmd:keyword">
                <xsl:element name="dif:Parameters">
                    <xsl:element name="dif:Category">EARTH SCIENCE</xsl:element>
                    <xsl:variable name="mykeywordstring">
                        <xsl:value-of select="."/>
                    </xsl:variable>
                    <xsl:call-template name="keywordseparation">
                        <xsl:with-param name="keywordstring" select="$mykeywordstring" />
                    </xsl:call-template>
                    <!-- Removed as the current OAI-PMH provider cannot
                         use XSLT2. Øystein Godøy, METNO/FOU, 2020-04-01 
                    <xsl:for-each select="tokenize(.,'&gt;')">
                        <xsl:if test="position() = 1"><xsl:element name="dif:Topic"><xsl:sequence select="."/></xsl:element></xsl:if>
                        <xsl:if test="position() = 2"><xsl:element name="dif:Term"><xsl:sequence select="."/></xsl:element></xsl:if>
                        <xsl:if test="position() = 3"><xsl:element name="dif:Variable_Level_1"><xsl:sequence select="."/></xsl:element></xsl:if>
                        <xsl:if test="position() = 4"><xsl:element name="dif:Detailed_Variable"><xsl:sequence select="."/></xsl:element></xsl:if>
                    </xsl:for-each>
                    -->
                </xsl:element>
            </xsl:for-each>
        </xsl:template>
        <!-- Template to split keywords into the sub elements DIF require -->
        <xsl:variable name="separator">
            <xsl:text> &gt; </xsl:text>
        </xsl:variable>
        <xsl:template name="keywordseparation">
            <xsl:param name="keywordstring"/>
            <xsl:choose>
                <xsl:when test="contains($keywordstring,$separator)  ">
                    <xsl:element name="dif:Topic">
                        <xsl:value-of select="substring-before($keywordstring,$separator)"/>
                    </xsl:element>
                    <xsl:variable name="tmpstr1">
                        <xsl:value-of select="substring-after($keywordstring,$separator)"/>
                    </xsl:variable>
                    <xsl:element name="dif:Term">
                        <xsl:value-of select="substring-after($tmpstr1,$separator)"/>
                    </xsl:element>
                    <xsl:variable name="tmpstr2">
                        <xsl:value-of select="substring-after($tmpstr1,$separator)"/>
                    </xsl:variable>
                    <xsl:element name="dif:Variable_Level_1">
                        <xsl:value-of select="substring-after($tmpstr2,$separator)"/>
                    </xsl:element>
                    <xsl:variable name="tmpstr3">
                        <xsl:value-of select="substring-after($tmpstr1,$separator)"/>
                    </xsl:variable>
                    <xsl:element name="dif:Variable_Level_2">
                        <xsl:value-of select="substring-after($tmpstr3,$separator)"/>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>    
        </xsl:template>

	<xsl:template match="mmd:temporal_extent">
		<xsl:element name="dif:Temporal_Coverage">
			<xsl:element name="dif:Start_Date">
				<xsl:value-of select="mmd:start_date" />
			</xsl:element>
			<xsl:element name="dif:Stop_Date">
				<xsl:value-of select="mmd:end_date" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:geographic_extent/mmd:rectangle">
		<xsl:element name="dif:Spatial_Coverage">
			<xsl:element name="dif:Southernmost_Latitude">
				<xsl:value-of select="mmd:south" />
			</xsl:element>
			<xsl:element name="dif:Northernmost_Latitude">
				<xsl:value-of select="mmd:north" />
			</xsl:element>
			<xsl:element name="dif:Westernmost_Longitude">
				<xsl:value-of select="mmd:west" />
			</xsl:element>
			<xsl:element name="dif:Easternmost_Longitude">
				<xsl:value-of select="mmd:east" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:data_access">
		<xsl:element name="dif:Related_URL">
			<xsl:element name="dif:URL_Content_Type">
                            <xsl:element name="dif:Type">
                                <xsl:text>GET DATA</xsl:text>
                            </xsl:element>
				<xsl:element name="dif:Subtype">
                                    <xsl:choose>
                                        <xsl:when test="mmd:type = 'OPeNDAP'">
                                            <xsl:text>OPENDAP DATA (DODS)</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="mmd:type = 'OGC WMS'">
                                            <xsl:text>WEB MAP SERVICE (WMS)</xsl:text>
                                        </xsl:when>
                                    </xsl:choose>
				</xsl:element>
			</xsl:element>
			<xsl:element name="dif:URL">
				<xsl:value-of select="mmd:resource" />
			</xsl:element>
			<xsl:element name="dif:Description">
				<xsl:value-of select="mmd:description" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:project">
		<xsl:element name="dif:Project">
			<xsl:element name="dif:Short_Name">
				<xsl:value-of select="mmd:short_name" />
			</xsl:element>
			<xsl:element name="dif:Long_Name">
				<xsl:value-of select="mmd:long_name" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:instrument">
		<xsl:element name="dif:Instrument">
			<xsl:element name="dif:Short_Name">
				<xsl:value-of select="mmd:short_name" />
			</xsl:element>
			<xsl:element name="dif:Long_Name">
				<xsl:value-of select="mmd:long_name" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:platform">
		<xsl:element name="dif:Platform">
			<xsl:element name="dif:Short_Name">
				<xsl:value-of select="mmd:short_name" />
			</xsl:element>
			<xsl:element name="dif:Long_Name">
				<xsl:value-of select="mmd:long_name" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:access_constraint">
		<xsl:element name="dif:Access_Constraints">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:use_constraint">
		<xsl:element name="dif:Use_Constraints">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:dataset_production_status">
		<xsl:element name="dif:Data_Set_Progress">
			<!--TODO: Fix proper translation of status -->
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:dataset_language">
		<xsl:element name="dif:Data_Set_Language">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:iso_topic_category">
		<xsl:element name="dif:ISO_Topic_Category">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

        <xsl:template match="mmd:data_center">
            <xsl:element name="dif:Data_Center">
                <xsl:element name="dif:Data_Center_Name">
                    <xsl:element name="dif:Short_Name">
                        <xsl:value-of select="mmd:data_center_name/mmd:short_name" />
                    </xsl:element>
                    <xsl:element name="dif:Long_Name">
                        <xsl:value-of select="mmd:data_center_name/mmd:long_name" />
                    </xsl:element>
                </xsl:element>
                <xsl:element name="dif:Data_Center_URL">
                    <xsl:value-of select="mmd:data_center_url" />
                </xsl:element>
                <xsl:element name="dif:Data_Set_ID">
                    <xsl:value-of select="mmd:dataset_id" />
                </xsl:element>
                <xsl:choose>
                    <xsl:when test="mmd:personnel[mmd:role='Data center contact']">
                        <xsl:element name="dif:Personnel">
                            <xsl:element name="dif:Role">
                                <xsl:value-of select="mmd:personnel/mmd:role[mmd:role='Data center contact']"></xsl:value-of>
                            </xsl:element>
                            <xsl:element name="dif:First_Name" />
                            <xsl:element name="dif:Middle_Name" />
                            <xsl:element name="dif:Last_Name">
                                <xsl:value-of select="mmd:personnel/mmd:name[mmd:role='Data center contact']"></xsl:value-of>
                            </xsl:element>
                            <xsl:element name="dif:Phone">
                                <xsl:value-of select="mmd:personnel/mmd:phone[mmd:role='Data center contact']"></xsl:value-of>
                            </xsl:element>
                            <xsl:element name="dif:Fax">
                                <xsl:value-of select="mmd:personnel/mmd:fax[mmd:role='Data center contact']"></xsl:value-of>
                            </xsl:element>

                            <xsl:element name="dif:Contact_Address">
                                <xsl:element name="dif:Address">
                                    <xsl:value-of select="mmd:personnel/mmd:contact_address/mmd:address[mmd:role='Data center contact']" />
                                </xsl:element>
                                <xsl:element name="dif:City">
                                    <xsl:value-of select="mmd:personnel/mmd:contact_address/mmd:city[mmd:role='Data center contact']" />
                                </xsl:element>
                                <xsl:element name="dif:Province_or_State">
                                    <xsl:value-of
                                        select="mmd:personnel/mmd:contact_address/mmd:province_or_state[mmd:role='Data center contact']" />
                                </xsl:element>
                                <xsl:element name="dif:Postal_Code">
                                    <xsl:value-of select="mmd:personnel/mmd:contact_address/mmd:postal_code[mmd:role='Data center contact']" />
                                </xsl:element>
                                <xsl:element name="dif:country">
                                    <xsl:value-of select="mmd:personnel/mmd:contact_address/mmd:country[mmd:role='Data center contact']" />
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="dif:Personnel">
                            <xsl:element name="dif:Role">Technical Contact</xsl:element>
                            <xsl:element name="dif:First_Name"></xsl:element>
                            <xsl:element name="dif:Last_Name">FOU-FD Department</xsl:element>
                            <xsl:element name="dif:Email">adc-support@met.no</xsl:element>
                            <xsl:element name="dif:Phone">+47 2296 3000</xsl:element>
                            <xsl:element name="dif:Contact_Address">
                                <xsl:element name="dif:Address"></xsl:element>
                                <xsl:element name="dif:City">Oslo</xsl:element>
                                <xsl:element name="dif:Postal_Code">NO-0313</xsl:element>
                                <xsl:element name="dif:Country">Norway</xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:template>

        <xsl:template match="mmd:personnel[mmd:role='Investigator']">
            <xsl:element name="dif:Personnel">
                <xsl:element name="dif:Role">
                    <xsl:value-of select="mmd:role" />
                </xsl:element>
                <!--
                <xsl:element name="dif:First_Name">
                    <xsl:value-of select="mmd:name" />
                </xsl:element>
                -->
                <xsl:element name="dif:Last_Name">
                    <xsl:value-of select="mmd:name" />
                </xsl:element>
                <xsl:element name="dif:Email">
                    <xsl:value-of select="mmd:email" />
                </xsl:element>
            </xsl:element>
        </xsl:template>

        <xsl:template match="mmd:dataset_citation">

            <xsl:element name="dif:Data_Set_Citation">
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
                <xsl:element name="dif:Dataset_Release_Date">
                    <xsl:value-of select="mmd:dataset_release_date" />
                </xsl:element>
                <xsl:element name="dif:Dataset_Release_Place">
                    <xsl:value-of select="mmd:dataset_release_place" />
                </xsl:element>
                <xsl:element name="dif:Dataset_Publisher">
                    <xsl:value-of select="mmd:dataset_publisher" />
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

            </xsl:element>

        </xsl:template>

</xsl:stylesheet>
