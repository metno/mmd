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
			<xsl:apply-templates select="mmd:title[@xml:lang = 'en']" />
                        <xsl:choose>
                            <xsl:when test="mmd:dataset_citation">
                                <xsl:apply-templates select="mmd:dataset_citation" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:element name="dif:Dataset_Citation">
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
			<xsl:choose>
			    <xsl:when test="mmd:platform">
			        <xsl:apply-templates select="mmd:platform" />
			    </xsl:when>
			    <xsl:otherwise>
		                <xsl:element name="dif:Platform">
			            <xsl:element name="dif:Type">
				        <xsl:text>Not provided</xsl:text>
			            </xsl:element>
			            <xsl:element name="dif:Short_Name">
				        <xsl:text></xsl:text>
			            </xsl:element>
			            <xsl:element name="dif:Instrument">
			                <xsl:element name="dif:Short_Name">
				            <xsl:text></xsl:text>
			                </xsl:element>
			            </xsl:element>
			        </xsl:element>
			    </xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="mmd:temporal_extent" />
			<xsl:apply-templates select="mmd:dataset_production_status" />
			<xsl:apply-templates select="mmd:geographic_extent/mmd:rectangle" />
			<xsl:apply-templates select="mmd:keywords[@vocabulary = 'GCMDLOC']" />
			<xsl:apply-templates select="mmd:project" />
			<xsl:apply-templates select="mmd:quality_control" />
			<xsl:apply-templates select="mmd:access_constraint" />
			<xsl:apply-templates select="mmd:use_constraint" />
			<xsl:apply-templates select="mmd:dataset_language" />
			<xsl:apply-templates select="mmd:data_center" /> <!--tbd-->
			<xsl:apply-templates select="mmd:abstract[@xml:lang = 'en']" />
			<xsl:apply-templates select="mmd:related_information"/> <!--tbd-->
			<xsl:apply-templates select="mmd:data_access" />
			<xsl:apply-templates select="mmd:related_dataset" />

			<xsl:element name="dif:Metadata_Name">CEOS IDN DIF</xsl:element>
			<xsl:element name="dif:Metadata_Version">VERSION 10.3</xsl:element>
			<xsl:apply-templates select="mmd:last_metadata_update" />
			<xsl:element name="dif:Product_Level_Id">Not provided</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:metadata_identifier">
		<xsl:element name="dif:Entry_ID">
		    <xsl:element name="dif:Short_Name">
			<xsl:value-of select="." />
		    </xsl:element>
		    <xsl:element name="dif:Version">
                        <xsl:text>Not provided</xsl:text>
		    </xsl:element>
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
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:related_information">
		<xsl:if test="mmd:type = 'Dataset landing page'">
                    <xsl:element name="dif:Related_URL">
                        <xsl:element name="dif:URL_Content_Type">
                            <xsl:element name="dif:Type">
                                <xsl:text>DATA SET LANDING PAGE</xsl:text>
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
                        <xsl:text>USE SERVICE API</xsl:text>
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
                                <xsl:text>PROJECT HOME PAGE</xsl:text>
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
                                <xsl:text>EXTENDED METADATA</xsl:text>
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

	<xsl:template match="mmd:last_metadata_update">
            <xsl:element name="dif:Metadata_Dates">
		<xsl:element name="dif:Metadata_Creation">
		<xsl:choose>
		    <xsl:when test="mmd:update/mmd:type = 'Created'">
		        <xsl:value-of select="mmd:update/mmd:datetime"/>
		    </xsl:when>
		    <xsl:otherwise>
	                <xsl:variable name="first">
	                    <xsl:for-each select="mmd:update/mmd:datetime">
                                <xsl:sort select="." order="ascending" />
                                <xsl:if test="position() = 1">
                                    <xsl:value-of select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:value-of select="$first"/>
		    </xsl:otherwise>
		</xsl:choose>
		</xsl:element>
		<xsl:element name="dif:Metadata_Last_Revision">
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
            </xsl:element>
	</xsl:template>

        <xsl:template match="mmd:keywords[@vocabulary = 'GCMDSK']">
            <xsl:for-each select="mmd:keyword">
                <xsl:element name="dif:Science_Keywords">
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
		    <xsl:element name="dif:Range_DateTime">
			<xsl:element name="dif:Beginning_Date_Time">
				<xsl:value-of select="mmd:start_date" />
			</xsl:element>
			<xsl:element name="dif:Ending_Date_Time">
			    <xsl:choose>
				<xsl:when test="mmd:end_date !=''">
				    <xsl:value-of select="mmd:end_date" />
				</xsl:when>
				<xsl:otherwise>
				    <xsl:text>unbounded</xsl:text>
				</xsl:otherwise>
			    </xsl:choose>
			</xsl:element>
		    </xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:geographic_extent/mmd:rectangle">
		<xsl:element name="dif:Spatial_Coverage">
		    <xsl:element name="dif:Granule_Spatial_Representation">
			<xsl:text>CARTESIAN</xsl:text>
		    </xsl:element>
		    <xsl:element name="dif:Geometry">
		        <xsl:element name="dif:Coordinate_System">
			    <xsl:text>CARTESIAN</xsl:text>
		        </xsl:element>
		        <xsl:element name="dif:Bounding_Rectangle">
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
		    </xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:data_access">
		<xsl:element name="dif:Related_URL">
		    <xsl:element name="dif:URL_Content_Type">
			<xsl:if test="mmd:type = 'HTTP'">
			    <xsl:element name="dif:Type">
			        <xsl:text>GET DATA</xsl:text>
			    </xsl:element>
			    <xsl:element name="dif:Subtype">
			        <xsl:text>DIRECT DOWNLOAD</xsl:text>
			    </xsl:element>
			</xsl:if>
			<xsl:if test="mmd:type = 'OPeNDAP'">
			    <xsl:element name="dif:Type">
			        <xsl:text>USE SERVICE API</xsl:text>
			    </xsl:element>
			    <xsl:element name="dif:Subtype">
			        <xsl:text>OPENDAP DATA</xsl:text>
			    </xsl:element>
			</xsl:if>
			<xsl:if test="mmd:type = 'OGC WMS'">
			    <xsl:element name="dif:Type">
			        <xsl:text>USE SERVICE API</xsl:text>
			    </xsl:element>
			    <xsl:element name="dif:Subtype">
			        <xsl:text>WEB MAP SERVICE (WMS)</xsl:text>
			    </xsl:element>
			</xsl:if>
			<xsl:if test="mmd:type = 'OGC WFS'">
			    <xsl:element name="dif:Type">
			        <xsl:text>USE SERVICE API</xsl:text>
			    </xsl:element>
			    <xsl:element name="dif:Subtype">
			        <xsl:text>WEB FEATURE SERVICE (WFS)</xsl:text>
			    </xsl:element>
			</xsl:if>
			<xsl:if test="mmd:type = 'OGC WCS'">
			    <xsl:element name="dif:Type">
			        <xsl:text>USE SERVICE API</xsl:text>
			    </xsl:element>
			    <xsl:element name="dif:Subtype">
			        <xsl:text>WEB COVERAGE SERVICE (WCS)</xsl:text>
			    </xsl:element>
			</xsl:if>
			<xsl:if test="mmd:type = 'FTP'">
			    <xsl:element name="dif:Type">
			        <xsl:text>GET DATA</xsl:text>
			    </xsl:element>
			    <xsl:element name="dif:Subtype">
			        <xsl:text>DIRECT DOWNLOAD</xsl:text>
			    </xsl:element>
			</xsl:if>
		   </xsl:element>
		   <xsl:element name="dif:URL">
		       <xsl:value-of select="mmd:resource" />
		   </xsl:element>
		   <xsl:element name="dif:Description">
		       <xsl:value-of select="mmd:description" />
	           </xsl:element>
	    </xsl:element>
	</xsl:template>

	<xsl:template match="mmd:related_dataset">
		<xsl:if test="@relation_type = 'parent' and . !=''">
		    <xsl:element name="dif:Metadata_Association">
			    <xsl:element name="dif:Entry_ID">
			    <xsl:element name="dif:Short_Name">
		               <xsl:value-of select="." />
		            </xsl:element>
			    <xsl:element name="dif:Version">
                               <xsl:text>Not provided</xsl:text>
		            </xsl:element>
		            </xsl:element>
			    <xsl:element name="dif:Type">
			       <xsl:text>Parent</xsl:text>
		            </xsl:element>
		    </xsl:element>
	        </xsl:if>
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

	<xsl:template match="mmd:quality_control">
		<xsl:element name="dif:Quality">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:platform">
		<xsl:element name="dif:Platform">
			<xsl:element name="dif:Type">
				<xsl:text>Not provided</xsl:text>
			</xsl:element>
			<xsl:element name="dif:Short_Name">
				<xsl:value-of select="mmd:short_name" />
			</xsl:element>
			<xsl:element name="dif:Long_Name">
				<xsl:value-of select="mmd:long_name" />
			</xsl:element>
			<xsl:element name="dif:Instrument">
			    <xsl:element name="dif:Short_Name">
				<xsl:value-of select="mmd:instrument/mmd:short_name" />
			    </xsl:element>
			    <xsl:element name="dif:Long_Name">
				<xsl:value-of select="mmd:instrument/mmd:long_name" />
			    </xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:access_constraint">
		<xsl:element name="dif:Access_Constraints">
		    <xsl:element name="dif:Description">
			<xsl:value-of select="." />
		    </xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:use_constraint">
		<xsl:element name="dif:Use_Constraints">
			<xsl:choose>
			    <xsl:when test="mmd:license_text">
		                <xsl:element name="dif:License_Text">
			            <xsl:value-of select="mmd:license_text" />
		                </xsl:element>
			    </xsl:when>
			    <xsl:otherwise>
		                <xsl:element name="dif:License_URL">
		                    <xsl:element name="dif:URL">
			                <xsl:value-of select="mmd:resource" />
		                    </xsl:element>
		                </xsl:element>
			    </xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:dataset_production_status">
		<xsl:element name="dif:Dataset_Progress">
                    <xsl:variable name="mmd_status" select="normalize-space(.)" />
                    <xsl:variable name="mmd_status_mapping" select="document('')/*/mapping:dataset_status[@mmd=$mmd_status]/@dif" />
                    <xsl:value-of select="$mmd_status_mapping" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mmd:dataset_language">
		<xsl:element name="dif:Dataset_Language">
                    <xsl:variable name="mmd_language" select="normalize-space(.)" />
                    <xsl:variable name="mmd_language_mapping" select="document('')/*/mapping:language[@mmd=$mmd_language]/@dif" />
                    <xsl:value-of select="$mmd_language_mapping" />
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
                <xsl:element name="dif:Ancillary_Keyword">
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:for-each>
        </xsl:template>

	<xsl:template match="mmd:data_center">

		<xsl:element name="dif:Organization">
			<xsl:element name="dif:Organization_Type">
			    <xsl:text>DISTRIBUTOR</xsl:text>
			</xsl:element>
			<xsl:element name="dif:Organization_Name">
				<xsl:element name="dif:Short_Name">
					<xsl:value-of select="mmd:data_center_name/mmd:short_name" />
				</xsl:element>
				<xsl:element name="dif:Long_Name">
					<xsl:value-of select="mmd:data_center_name/mmd:long_name" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="dif:Organization_URL">
				<xsl:value-of select="mmd:data_center_url" />
			</xsl:element>
			<xsl:element name="dif:Personnel">
                            <xsl:element name="dif:Role">
				    <xsl:text>DATA CENTER CONTACT</xsl:text>
                            </xsl:element>
                            <xsl:element name="dif:Contact_Group">
                                <xsl:element name="dif:Name">
		                    <xsl:value-of select="../mmd:personnel/mmd:name[../mmd:role='Data center contact']" />
                                </xsl:element>
				<xsl:if test="../mmd:personnel/mmd:phone[../mmd:role='Data center contact']">
				    <xsl:element name="dif:Phone">
				       <xsl:element name="dif:Number">
		                           <xsl:value-of select="../mmd:personnel/mmd:phone[../mmd:role='Data center contact']" />
                                       </xsl:element>
				       <xsl:element name="dif:Type">
				           <xsl:text>Telephone</xsl:text>
                                       </xsl:element>
                                    </xsl:element>
                                </xsl:if>
                                <!--xsl:element name="dif:Address">
                                    <xsl:element name="dif:Address">
		                        <xsl:value-of select="../mmd:personnel/mmd:contact_address/mmd:address[../../mmd:role='Data center contact']" />
                                    </xsl:element>
                                    <xsl:element name="dif:City">
		                        <xsl:value-of select="../mmd:personnel/mmd:contact_address/mmd:city[../../mmd:role='Data center contact']" />
                                    </xsl:element>
                                    <xsl:element name="dif:Province_or_State">
                                        <xsl:value-of select="../mmd:personnel/mmd:contact_address/mmd:province_or_state[../../mmd:role='Data center contact']" />
                                    </xsl:element>
                                    <xsl:element name="dif:Postal_Code">
		                        <xsl:value-of select="../mmd:personnel/mmd:contact_address/mmd:postal_code[../../mmd:role='Data center contact']" />
                                    </xsl:element>
                                    <xsl:element name="dif:Country">
		                        <xsl:value-of select="../mmd:personnel/mmd:contact_address/mmd:country[../../mmd:role='Data center contact']" />
                                    </xsl:element>
                                </xsl:element-->
			    </xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>


    <xsl:template match="mmd:dataset_citation">

        <xsl:element name="dif:Dataset_Citation">
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
	    <xsl:if test="mmd:doi !=''">
            <xsl:element name="dif:Persistent_Identifier">
                <xsl:element name="dif:Type">
	            <xsl:text>DOI</xsl:text>
                </xsl:element>
                <xsl:element name="dif:Identifier">
                    <xsl:value-of select="substring-after(mmd:doi, 'https://doi.org/')" />
                </xsl:element>
                <xsl:element name="dif:Authority">
	            <xsl:text>https://doi.org/</xsl:text>
                </xsl:element>
            </xsl:element>
            </xsl:if>
            <xsl:element name="dif:Online_Resource">
                <xsl:value-of select="mmd:url" />
            </xsl:element>

        </xsl:element>


    </xsl:template>

    <xsl:template match="mmd:personnel">
        <xsl:element name="dif:Personnel">
            <xsl:element name="dif:Role">
                <xsl:value-of select="translate(mmd:role,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
            </xsl:element>
            <xsl:element name="dif:Contact_Group">
                <xsl:element name="dif:Name">
                    <xsl:value-of select="mmd:name" />
                </xsl:element>
                <xsl:element name="dif:Address">
                    <xsl:element name="dif:Street_Address">
			<xsl:value-of select="mmd:contact_address/mmd:address" />
                    </xsl:element>
                    <xsl:element name="dif:City">
			<xsl:value-of select="mmd:contact_address/mmd:city" />
                    </xsl:element>
                    <xsl:element name="dif:State_Province">
			<xsl:value-of select="mmd:contact_address/mmd:province_or_state" />
                    </xsl:element>
                    <xsl:element name="dif:Postal_Code">
			<xsl:value-of select="mmd:contact_address/mmd:postal_code" />
                    </xsl:element>
                    <xsl:element name="dif:Country">
			<xsl:value-of select="mmd:contact_address/mmd:country" />
                    </xsl:element>
                </xsl:element>
                <xsl:element name="dif:Email">
                    <xsl:value-of select="mmd:email" />
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Mappings for dataset_production_status -->
    <mapping:dataset_status dif="COMPLETE" mmd="Complete" />
    <mapping:dataset_status dif="COMPLETE" mmd="Obsolete" />
    <mapping:dataset_status dif="IN WORK" mmd="In Work" />
    <mapping:dataset_status dif="PLANNED" mmd="Planned" />
    <mapping:dataset_status dif="NOT PROVIDED" mmd="Not available" />

    <mapping:language dif="English" mmd="en" />
    <mapping:language dif="Norwegian" mmd="no" />
</xsl:stylesheet>
