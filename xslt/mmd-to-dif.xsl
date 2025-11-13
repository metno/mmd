<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dif="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/" 
    xmlns:mmd="http://www.met.no/schema/mmd"
    xmlns:mapping="http://www.met.no/schema/mmd/mmd2dif"      
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dc="http://purl.org/dc/elements/1.1/" version="1.0">

        <xsl:key name="isoc" match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/ISO_Topic_Category']/skos:member/skos:Concept" use="skos:prefLabel"/>
        <xsl:variable name="isoLUD" select="document('../thesauri/mmd-vocabulary.xml')"/>
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />

	<xsl:template match="/mmd:mmd">
		<xsl:element name="dif:DIF">
			<xsl:apply-templates select="mmd:metadata_identifier" />
			<xsl:apply-templates select="mmd:title" />
                        <xsl:choose>
                            <xsl:when test="mmd:dataset_citation">
                                <xsl:apply-templates select="mmd:dataset_citation" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:element name="dif:Data_Set_Citation">
                                    <xsl:element name="dif:Dataset_Title">
				        <xsl:if test="mmd:title[@xml:lang = 'en'] or not(mmd:title[@xml:lang]) or mmd:title[@xml:lang = '']">
				            <xsl:value-of select="mmd:title" />
	                                </xsl:if>
                                    </xsl:element>
                                    <xsl:element name="dif:Online_Resource">
				        <xsl:value-of select="mmd:related_information[mmd:type='Dataset landing page']/mmd:resource"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:apply-templates select="mmd:personnel[mmd:role !='Data center contact']" />
			<xsl:apply-templates select="mmd:keywords[@vocabulary = 'GCMDSK']" />
			<xsl:apply-templates select="mmd:iso_topic_category[. != 'Not available']" />
			<xsl:apply-templates select="mmd:keywords[not(@vocabulary = 'GCMDSK' or @vocabulary = 'GCMDLOC')]" />
			<xsl:apply-templates select="mmd:platform" />
			<xsl:apply-templates select="mmd:temporal_extent" />
			<xsl:apply-templates select="mmd:dataset_production_status[. != 'Not available']" />
			<xsl:apply-templates select="mmd:geographic_extent/mmd:rectangle" />
			<xsl:apply-templates select="mmd:keywords[@vocabulary = 'GCMDLOC']" />
			<xsl:apply-templates select="mmd:project" />
			<xsl:apply-templates select="mmd:access_constraint" />
			<xsl:apply-templates select="mmd:use_constraint" />
			<xsl:apply-templates select="mmd:dataset_language" />
                        <xsl:element name="dif:Originating_Center">
				<xsl:value-of select="mmd:personnel[mmd:role ='Investigator']/mmd:organisation" />
                        </xsl:element>
                        <xsl:apply-templates select="mmd:data_center" />
                        <xsl:apply-templates select="mmd:storage_information" />
			<xsl:apply-templates select="mmd:abstract" />
                        <xsl:apply-templates select="mmd:related_information"/>
			<xsl:apply-templates select="mmd:data_access" />
			<xsl:apply-templates select="mmd:related_dataset" />
			<xsl:apply-templates select="mmd:quality" />

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
		<xsl:if test="@xml:lang = 'en' or not(@xml:lang) or @xml:lang = ''">
		    <xsl:element name="dif:Entry_Title">
			<xsl:value-of select="." />
		    </xsl:element>
	        </xsl:if>
	</xsl:template>

	<xsl:template match="mmd:abstract">
		<xsl:if test="@xml:lang = 'en' or not(@xml:lang) or @xml:lang = ''">
		    <xsl:element name="dif:Summary">
			<xsl:element name="dif:Abstract">
		            <xsl:value-of select="." />
			</xsl:element>
		        <xsl:element name="dif:Purpose" />
		    </xsl:element>
	        </xsl:if>
	</xsl:template>

	<xsl:template match="mmd:related_dataset">
		<xsl:if test="@relation_type = 'parent' and . !=''">
		    <xsl:element name="dif:Parent_DIF">
		        <xsl:value-of select="." />
		    </xsl:element>
	        </xsl:if>
	</xsl:template>

	<xsl:template match="mmd:last_metadata_update">
		<xsl:if test="mmd:update/mmd:type = 'Created'">
		    <xsl:element name="dif:DIF_Creation_Date">
			<xsl:value-of select="mmd:update/mmd:datetime"/>
		    </xsl:element>
		</xsl:if>
		<xsl:element name="dif:Last_DIF_Revision_Date">
	            <xsl:variable name="latest">
	                <xsl:for-each select="mmd:update/mmd:datetime">
                            <xsl:sort select="." order="descending" />
                            <xsl:if test="position() = 1">
                                <xsl:value-of select="."/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:value-of select="$latest"/>
		</xsl:element>
	</xsl:template>

        <xsl:template match="mmd:keywords[@vocabulary = 'GCMDSK']">
            <xsl:for-each select="mmd:keyword">
                <xsl:element name="dif:Parameters">
                    <xsl:variable name="mykeywordstring">
                        <xsl:choose>
                            <xsl:when test="not(contains(.,'EARTH SCIENCE') or contains(.,'Earth Science'))">
                                <xsl:value-of select="."/>
                            </xsl:when>
                            <xsl:otherwise>
				<xsl:if test="contains(.,'EARTH SCIENCE')">
                                    <xsl:value-of select="substring-after(.,'EARTH SCIENCE &gt; ')"/>
			        </xsl:if>
				<xsl:if test="contains(.,'Earth Science')">
                                    <xsl:value-of select="substring-after(.,'Earth Science &gt; ')"/>
			        </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:element name="dif:Category">
                        <xsl:text>EARTH SCIENCE</xsl:text>
                    </xsl:element>
                    <xsl:call-template name="keywordseparation">
                        <xsl:with-param name="keywordstring" select="(translate($mykeywordstring, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'))" />
                    </xsl:call-template>
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
                <xsl:when test="contains($keywordstring,$separator)">
                    <xsl:element name="dif:Topic">
                        <xsl:value-of select="substring-before($keywordstring,$separator)"/>
                    </xsl:element>
                    <xsl:variable name="tmpstr1">
                        <xsl:value-of select="substring-after($keywordstring,$separator)"/>
                    </xsl:variable>
                    <xsl:element name="dif:Term">
                        <xsl:choose>
                            <xsl:when test="contains($tmpstr1,$separator)">
                                <xsl:value-of select="substring-before($tmpstr1,$separator)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$tmpstr1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <xsl:variable name="tmpstr2">
                        <xsl:value-of select="substring-after($tmpstr1,$separator)"/>
                    </xsl:variable>
                    <xsl:element name="dif:Variable_Level_1">
                        <xsl:choose>
                            <xsl:when test="contains($tmpstr2,$separator)">
                                <xsl:value-of select="substring-before($tmpstr2,$separator)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$tmpstr2"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <xsl:variable name="tmpstr3">
                        <xsl:value-of select="substring-after($tmpstr2,$separator)"/>
                    </xsl:variable>
                    <xsl:element name="dif:Variable_Level_2">
                        <xsl:choose>
                            <xsl:when test="contains($tmpstr3,$separator)">
                                <xsl:value-of select="substring-before($tmpstr3,$separator)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$tmpstr3"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>    
        </xsl:template>

        <xsl:template match="mmd:keywords[@vocabulary = 'GCMDLOC']">
            <xsl:for-each select="mmd:keyword">
                <xsl:element name="dif:Location">
                    <xsl:variable name="mykeywordstringloc">
                        <xsl:value-of select="."/>
                    </xsl:variable>
                    <xsl:call-template name="keywordseparationloc">
                        <xsl:with-param name="keywordstringloc" select="(translate($mykeywordstringloc, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'))" />
                    </xsl:call-template>
                </xsl:element>
            </xsl:for-each>
        </xsl:template>
        <!-- Template to split keywords into the sub elements DIF require -->
        <xsl:variable name="separatorloc">
            <xsl:text> &gt; </xsl:text>
        </xsl:variable>
        <xsl:template name="keywordseparationloc">
            <xsl:param name="keywordstringloc"/>
            <xsl:choose>
                <xsl:when test="contains($keywordstringloc,$separatorloc)">
                    <xsl:element name="dif:Location_Category">
                        <xsl:value-of select="substring-before($keywordstringloc,$separatorloc)"/>
                    </xsl:element>
                    <xsl:variable name="tmpstr1">
                        <xsl:value-of select="substring-after($keywordstringloc,$separatorloc)"/>
                    </xsl:variable>
                    <xsl:element name="dif:Location_Type">
                        <xsl:choose>
                            <xsl:when test="contains($tmpstr1,$separator)">
                                <xsl:value-of select="substring-before($tmpstr1,$separatorloc)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$tmpstr1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <xsl:variable name="tmpstr2">
                        <xsl:value-of select="substring-after($tmpstr1,$separatorloc)"/>
                    </xsl:variable>
                    <xsl:element name="dif:Location_Subregion1">
                        <xsl:choose>
                            <xsl:when test="contains($tmpstr2,$separatorloc)">
                                <xsl:value-of select="substring-before($tmpstr2,$separatorloc)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$tmpstr2"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <xsl:variable name="tmpstr3">
                        <xsl:value-of select="substring-after($tmpstr2,$separatorloc)"/>
                    </xsl:variable>
                    <xsl:element name="dif:Location_Subregion2">
                        <xsl:choose>
                            <xsl:when test="contains($tmpstr3,$separator)">
                                <xsl:value-of select="substring-before($tmpstr3,$separatorloc)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$tmpstr3"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <xsl:variable name="tmpstr4">
                        <xsl:value-of select="substring-after($tmpstr3,$separatorloc)"/>
                    </xsl:variable>
                    <xsl:element name="dif:Location_Subregion3">
                        <xsl:choose>
                            <xsl:when test="contains($tmpstr4,$separatorloc)">
                                <xsl:value-of select="substring-before($tmpstr4,$separatorloc)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$tmpstr4"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <xsl:variable name="tmpstr5">
                        <xsl:value-of select="substring-after($tmpstr4,$separatorloc)"/>
                    </xsl:variable>
                    <xsl:element name="dif:Detailed_Location">
                        <xsl:choose>
                            <xsl:when test="contains($tmpstr5,$separatorloc)">
                                <xsl:value-of select="substring-before($tmpstr5,$separatorloc)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$tmpstr5"/>
                            </xsl:otherwise>
                        </xsl:choose>
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


	<xsl:template match="mmd:platform">
		<xsl:if test="mmd:instrument">
		<xsl:element name="dif:Sensor_Name">
			<xsl:element name="dif:Short_Name">
				<xsl:value-of select="mmd:instrument/mmd:short_name" />
			</xsl:element>
			<xsl:element name="dif:Long_Name">
				<xsl:value-of select="mmd:instrument/mmd:long_name" />
			</xsl:element>
		</xsl:element>
		</xsl:if>
		<xsl:element name="dif:Source_Name">
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
			<xsl:choose>
			    <xsl:when test="mmd:license_text">
			        <xsl:value-of select="mmd:license_text" />
			    </xsl:when>
			    <xsl:otherwise>
			        <xsl:value-of select="mmd:identifier" />
			    </xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:dataset_production_status">
		<xsl:element name="dif:Data_Set_Progress">
                    <xsl:variable name="mmd_status" select="normalize-space(.)" />
                    <xsl:variable name="mmd_status_mapping" select="document('')/*/mapping:dataset_status[@mmd=$mmd_status]/@dif" />
                    <xsl:value-of select="$mmd_status_mapping" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:dataset_language">
		<xsl:element name="dif:Data_Set_Language">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:iso_topic_category">
            <xsl:variable name="isov" select="." />
            <xsl:for-each select="$isoLUD">
                <xsl:value-of select ="name()" />
                <xsl:variable name="isoe" select="key('isoc',$isov)/skos:altLabel"/>
		<xsl:element name="dif:ISO_Topic_Category">
		    <xsl:value-of select="$isoe" />
		</xsl:element>
            </xsl:for-each>
	</xsl:template>

	<xsl:template match="mmd:keywords">
            <xsl:for-each select="mmd:keyword">
                <xsl:element name="dif:Keyword">
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:for-each>
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
                     <xsl:element name="dif:Personnel">
                         <xsl:element name="dif:Role">
		     	    <xsl:value-of select="../mmd:personnel/mmd:role[. ='Data center contact']" />
                         </xsl:element>
                         <xsl:element name="dif:Last_Name">
		     	    <xsl:value-of select="../mmd:personnel/mmd:name[../mmd:role='Data center contact']" />
                         </xsl:element>
                         <xsl:element name="dif:Phone">
		     	    <xsl:value-of select="../mmd:personnel/mmd:phone[../mmd:role='Data center contact']" />
                         </xsl:element>

                         <xsl:element name="dif:Contact_Address">
                             <xsl:element name="dif:Address">
		     		<xsl:value-of select="../mmd:personnel/mmd:contact_address/mmd:address[../../mmd:role='Data center contact']" />
                             </xsl:element>
                             <xsl:element name="dif:City">
		     		<xsl:value-of select="../mmd:personnel/mmd:contact_address/mmd:city[../../mmd:role='Data center contact']" />
                             </xsl:element>
                             <xsl:element name="dif:Province_or_State">
                                 <xsl:value-of
		     		    select="../mmd:personnel/mmd:contact_address/mmd:province_or_state[../../mmd:role='Data center contact']" />
                             </xsl:element>
                             <xsl:element name="dif:Postal_Code">
		     		<xsl:value-of select="../mmd:personnel/mmd:contact_address/mmd:postal_code[../../mmd:role='Data center contact']" />
                             </xsl:element>
                             <xsl:element name="dif:Country">
		     		<xsl:value-of select="../mmd:personnel/mmd:contact_address/mmd:country[../../mmd:role='Data center contact']" />
                             </xsl:element>
                         </xsl:element>
                     </xsl:element>
            </xsl:element>
        </xsl:template>

        <xsl:template match="mmd:storage_information">
            <xsl:element name="dif:Distribution">
		<xsl:if test="mmd:file_size">
                    <xsl:element name="dif:Distribution_Size">
		    	<xsl:value-of select="concat(mmd:file_size, ' ', mmd:file_size/@unit)" />
                    </xsl:element>
	        </xsl:if>
		<xsl:if test="mmd:file_format">
                <xsl:element name="dif:Distribution_Format">
                    <xsl:value-of select="mmd:file_format" />
                </xsl:element>
	        </xsl:if>
            </xsl:element>
        </xsl:template>

        <xsl:template match="mmd:personnel">
	    <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
	    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
            <xsl:element name="dif:Personnel">
                <xsl:element name="dif:Role">
                    <xsl:value-of select="translate(mmd:role,$lowercase,$uppercase)" />
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
                    <xsl:value-of select="mmd:author" />
                </xsl:element>
                <xsl:element name="dif:Dataset_Title">
                    <xsl:value-of select="mmd:title" />
                </xsl:element>
                <xsl:element name="dif:Dataset_Series_Name">
                    <xsl:value-of select="mmd:series" />
                </xsl:element>
                <xsl:element name="dif:Dataset_Release_Date">
                    <xsl:value-of select="mmd:publication_date" />
                </xsl:element>
                <xsl:element name="dif:Dataset_Release_Place">
                    <xsl:value-of select="mmd:publication_place" />
                </xsl:element>
                <xsl:element name="dif:Dataset_Publisher">
                    <xsl:value-of select="mmd:publisher" />
                </xsl:element>
                <xsl:element name="dif:Version">
                    <xsl:value-of select="mmd:edition" />
                </xsl:element>
                <xsl:element name="dif:Other_Citation_Details">
                    <xsl:value-of select="mmd:other" />
                </xsl:element>
                <xsl:element name="dif:Dataset_DOI">
                    <xsl:value-of select="mmd:doi" />
                </xsl:element>
                <xsl:element name="dif:Online_Resource">
                    <xsl:value-of select="mmd:url" />
                </xsl:element>
            </xsl:element>
        </xsl:template>


	<xsl:template match="mmd:related_information">
		<xsl:if test="mmd:type = 'Dataset landing page'">
                    <xsl:element name="dif:Related_URL">
                        <xsl:element name="dif:URL_Content_Type">
                            <xsl:element name="dif:Type">
                                <xsl:text>VIEW DATA SET LANDING PAGE</xsl:text>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="dif:URL">
                            <xsl:value-of select="mmd:resource"/>
                        </xsl:element>
                        <xsl:element name="dif:Description">
                            <xsl:value-of select="mmd:description"/>
                        </xsl:element>
                    </xsl:element>
	        </xsl:if>
        <xsl:if test="mmd:type = 'Data server landing page' and contains(mmd:resource,'thredds')">
            <xsl:element name="dif:Related_URL">
                <xsl:element name="dif:URL_Content_Type">
                    <xsl:element name="dif:Type">
                        <xsl:text>GET DATA</xsl:text>
                    </xsl:element>
                    <xsl:element name="dif:Subtype">
                        <xsl:text>THREDDS DATA</xsl:text>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="dif:URL">
                    <xsl:value-of select="mmd:resource"/>
                </xsl:element>
                <xsl:element name="dif:Description">
                    <xsl:value-of select="mmd:description"/>
                </xsl:element>
            </xsl:element>
        </xsl:if>
		<xsl:if test="mmd:type = 'Project home page'">
                    <xsl:element name="dif:Related_URL">
                        <xsl:element name="dif:URL_Content_Type">
                            <xsl:element name="dif:Type">
                                <xsl:text>VIEW PROJECT HOME PAGE</xsl:text>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="dif:URL">
                            <xsl:value-of select="mmd:resource"/>
                        </xsl:element>
                        <xsl:element name="dif:Description">
                            <xsl:value-of select="mmd:description"/>
                        </xsl:element>
                    </xsl:element>
	        </xsl:if>
		<xsl:if test="mmd:type = 'Users guide'">
                    <xsl:element name="dif:Related_URL">
                        <xsl:element name="dif:URL_Content_Type">
                            <xsl:element name="dif:Type">
                                <xsl:text>VIEW RELATED INFORMATION</xsl:text>
                            </xsl:element>
                            <xsl:element name="dif:Subtype">
                                <xsl:text>USER'S GUIDE</xsl:text>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="dif:URL">
                            <xsl:value-of select="mmd:resource"/>
                        </xsl:element>
                        <xsl:element name="dif:Description">
                            <xsl:value-of select="mmd:description"/>
                        </xsl:element>
                    </xsl:element>
	        </xsl:if>
		<xsl:if test="mmd:type = 'Extended metadata'">
                    <xsl:element name="dif:Related_URL">
                        <xsl:element name="dif:URL_Content_Type">
                            <xsl:element name="dif:Type">
                                <xsl:text>VIEW EXTENDED METADATA</xsl:text>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="dif:URL">
                            <xsl:value-of select="mmd:resource"/>
                        </xsl:element>
                        <xsl:element name="dif:Description">
                            <xsl:value-of select="mmd:description"/>
                        </xsl:element>
                    </xsl:element>
	        </xsl:if>
		<xsl:if test="mmd:type = 'Scientific publication' or mmd:type = 'Data paper'">
                    <xsl:element name="dif:Related_URL">
                        <xsl:element name="dif:URL_Content_Type">
                            <xsl:element name="dif:Type">
                                <xsl:text>VIEW RELATED INFORMATION</xsl:text>
                            </xsl:element>
                            <xsl:element name="dif:Subtype">
                                <xsl:text>PUBLICATIONS</xsl:text>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="dif:URL">
                            <xsl:value-of select="mmd:resource"/>
                        </xsl:element>
                        <xsl:element name="dif:Description">
                            <xsl:value-of select="mmd:description"/>
                        </xsl:element>
                    </xsl:element>
	        </xsl:if>
		<xsl:if test="mmd:type = 'Other documentation'">
                    <xsl:element name="dif:Related_URL">
                        <xsl:element name="dif:URL_Content_Type">
                            <xsl:element name="dif:Type">
                                <xsl:text>VIEW RELATED INFORMATION</xsl:text>
                            </xsl:element>
                            <xsl:element name="dif:Subtype">
                                <xsl:text>GENERAL DOCUMENTATION</xsl:text>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="dif:URL">
                            <xsl:value-of select="mmd:resource"/>
                        </xsl:element>
                        <xsl:element name="dif:Description">
                            <xsl:value-of select="mmd:description"/>
                        </xsl:element>
                    </xsl:element>
	        </xsl:if>
        </xsl:template>

        <xsl:template match="mmd:quality_control">
            <xsl:element name="dif:Quality">
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:template>

    <!-- Mappings for dataset_production_status -->
    <mapping:dataset_status dif="COMPLETE" mmd="Complete" />
    <mapping:dataset_status dif="COMPLETE" mmd="Obsolete" />
    <mapping:dataset_status dif="IN WORK" mmd="In Work" />
    <mapping:dataset_status dif="PLANNED" mmd="Planned" />    

</xsl:stylesheet>
