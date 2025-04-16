<?xml version="1.0" encoding="UTF-8"?>

<!--
Not fully adapted for DIF 10, some elements are supported though.
Meaning this should consume both DIF 8, 9 and 10.

Added more support for DIF 10 Øystein Godøy, METNO/FOU, 2023-04-24 
-->

<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dif="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/"
    xmlns:mmd="http://www.met.no/schema/mmd"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:mapping="http://www.met.no/schema/mmd/dif2mmd"
    version="1.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:key name="isoc" match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/ISO_Topic_Category']/skos:member/skos:Concept" use="skos:altLabel"/>
    <xsl:variable name="isoLUD" select="document('../thesauri/mmd-vocabulary.xml')"/>
    <xsl:key name="accessc" match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/Access_Constraint']/skos:member/skos:Concept/skos:altLabel" use="translate(.,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
    <xsl:key name="usec" match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/Use_Constraint']/skos:member/skos:Concept" use="skos:prefLabel"/>
    <xsl:key name="useca" match="skos:Collection[@rdf:about='https://vocab.met.no/mmd/Use_Constraint']/skos:member/skos:Concept" use="skos:altLabel"/>
    <!--
    <xsl:key name="isoc" match="Concept" use="altLabel"/>
-->
    <xsl:key name="mylat" match="//dif:Point_Latitude" use="."/>
    <xsl:key name="mylon" match="//dif:Point_Longitude" use="."/>

    <xsl:template match="/dif:DIF">
        <xsl:element name="mmd:mmd">
            <xsl:apply-templates select="dif:Entry_ID" />
            <xsl:apply-templates select="dif:Entry_Title" />
            <xsl:apply-templates select="dif:Summary" />
            <xsl:element name="mmd:metadata_status">Active</xsl:element>
	    <xsl:element name="mmd:dataset_production_status">
		<xsl:choose>
		    <xsl:when test="dif:Data_Set_Progress|dif:Dataset_Progress">
                        <xsl:apply-templates select="dif:Data_Set_Progress|dif:Dataset_Progress" />
		    </xsl:when>
		    <xsl:otherwise>
			<xsl:text>Not available</xsl:text>
		    </xsl:otherwise>
		</xsl:choose>
	    </xsl:element>
            <xsl:element name="mmd:collection">ADC</xsl:element>
	    <!--Set a default last_metadata_updates if no information provided in dif9-->
	    <xsl:if test="not(dif:Metadata_Dates)">
	    <xsl:choose>
	        <xsl:when test="dif:DIF_Creation_Date !='' or dif:Last_DIF_Revision_Date !=''">
	            <xsl:element name="mmd:last_metadata_update">
                        <xsl:apply-templates select="dif:DIF_Creation_Date" />
                        <xsl:apply-templates select="dif:Last_DIF_Revision_Date" />
	            </xsl:element>
                </xsl:when>
                <xsl:otherwise>
	            <xsl:element name="mmd:last_metadata_update">
                        <xsl:element name="mmd:update">
                            <xsl:element name="mmd:datetime">
                                <xsl:value-of select="concat(substring(date:date-time(),1,19),'Z')" />
                            </xsl:element>
                            <xsl:element name="mmd:type">
                                <xsl:text>Minor modification</xsl:text>
                            </xsl:element>
                            <xsl:element name="mmd:note">
                                <xsl:text>Made by transformation from DIF9 record, type is hardcoded.</xsl:text>
                            </xsl:element>
                        </xsl:element>
	            </xsl:element>
                </xsl:otherwise>
	    </xsl:choose>
            </xsl:if>
            <xsl:apply-templates select="dif:Metadata_Dates" />
            <xsl:apply-templates select="dif:Temporal_Coverage" />
            <xsl:choose>
	        <xsl:when test="dif:ISO_Topic_Category">
                    <xsl:apply-templates select="dif:ISO_Topic_Category" />
		</xsl:when>
		<xsl:otherwise>
	            <xsl:element name="mmd:iso_topic_category">
		        <xsl:text>Not available</xsl:text>
	            </xsl:element>
		</xsl:otherwise>
	    </xsl:choose>
            <xsl:element name="mmd:keywords">
                <xsl:attribute name="vocabulary">GCMDSK</xsl:attribute>
                <xsl:apply-templates select="dif:Parameters|dif:Science_Keywords" />
            </xsl:element>
	    <xsl:if test="dif:Keyword|dif:Ancillary_Keyword">
            <xsl:element name="mmd:keywords">
                <xsl:attribute name="vocabulary">None</xsl:attribute>
                <xsl:apply-templates select="dif:Keyword|dif:Ancillary_Keyword" />
            </xsl:element>
            </xsl:if>
            <xsl:apply-templates select="dif:Project" />
            <xsl:apply-templates select="dif:Spatial_Coverage" />
            <xsl:apply-templates select="dif:Access_Constraints" />
            <xsl:apply-templates select="dif:Use_Constraints" />
	    <xsl:apply-templates select="dif:Data_Set_Language|dif:Dataset_Language"/>
            <xsl:apply-templates select="dif:Related_URL" />
            <xsl:apply-templates select="dif:Personnel" />
            <xsl:apply-templates select="dif:Data_Set_Citation|dif:Dataset_Citation" />
            <xsl:apply-templates select="dif:Data_Center" />
            <xsl:apply-templates select="dif:Organization" />
            <!--xsl:apply-templates select="dif:Originating_Center" /-->
            <xsl:apply-templates select="dif:Parent_DIF" />
            <!-- ... -->
        </xsl:element>
    </xsl:template>

    <!--
  <xsl:template match="dif:Data_Set_Progress">
        <xsl:element name="mmd:dataset_production_status">
                <xsl:value-of select="." />
        </xsl:element>
  </xsl:template>
-->


  <xsl:template match="dif:Entry_ID">
      <xsl:choose>
          <xsl:when test="dif:Short_Name">
              <xsl:element name="mmd:metadata_identifier">
                  <xsl:value-of select="dif:Short_Name" />
              </xsl:element>
          </xsl:when>
          <xsl:otherwise>
              <xsl:element name="mmd:metadata_identifier">
                  <xsl:value-of select="." />
              </xsl:element>
          </xsl:otherwise>
      </xsl:choose>
  </xsl:template>


  <xsl:template match="dif:Entry_Title">
      <xsl:element name="mmd:title">
          <xsl:attribute name="xml:lang">en</xsl:attribute>
          <xsl:value-of select="." />
      </xsl:element>
  </xsl:template>


  <xsl:template match="dif:Data_Set_Citation|dif:Dataset_Citation">
      <xsl:element name="mmd:dataset_citation">
          <xsl:element name="mmd:author">
              <xsl:value-of select="dif:Dataset_Creator" />
          </xsl:element>
          <xsl:element name="mmd:title">
              <xsl:value-of select="dif:Dataset_Title" />
          </xsl:element>
          <xsl:element name="mmd:series">
              <xsl:value-of select="dif:Dataset_Series_Name" />
          </xsl:element>
          <xsl:element name="mmd:publication_date">
              <xsl:if test="string-length(dif:Dataset_Release_Date) &gt;= 10">
                  <xsl:value-of select="dif:Dataset_Release_Date" />
              </xsl:if>
          </xsl:element>
          <xsl:element name="mmd:publication_place">
              <xsl:value-of select="dif:Dataset_Release_Place" />
          </xsl:element>
          <xsl:element name="mmd:publisher">
              <xsl:value-of select="dif:Dataset_Publisher" />
          </xsl:element>
          <xsl:element name="mmd:edition">
              <xsl:value-of select="dif:Version" />
          </xsl:element>
          <xsl:element name="mmd:doi">
	      <xsl:if test="dif:Dataset_DOI">
              <xsl:choose>
                  <xsl:when test="contains(dif:Dataset_DOI, 'doi.org/')">
                      <xsl:value-of select="dif:Dataset_DOI" />
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:value-of select="concat('https://doi.org/',dif:Dataset_DOI)" />
                  </xsl:otherwise>
              </xsl:choose>
	      </xsl:if>
	      <xsl:if test="dif:Persistent_Identifier/dif:Type = 'DOI'">
              <xsl:choose>
                  <xsl:when test="contains(dif:Persistent_Identifier/dif:Identifier, 'doi.org/')">
                      <xsl:value-of select="dif:Persistent_Identifier/dif:Identifier" />
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:value-of select="concat('https://doi.org/', dif:Persistent_Identifier/dif:Identifier)" />
                  </xsl:otherwise>
              </xsl:choose>
	      </xsl:if>
          </xsl:element>
          <xsl:element name="mmd:url">
                  <xsl:value-of select="dif:Online_Resource" />
          </xsl:element>
          <!--
                <xsl:element name="mmd:dataset_presentation_form">
                        <xsl:value-of select="dif:Data_Presentation_Form" />
                </xsl:element>
                -->
        </xsl:element>
        <xsl:if test="dif:Online_Resource and dif:Online_Resource != ''">
            <xsl:element name="mmd:related_information">
                <xsl:element name="mmd:type">Dataset landing page</xsl:element>
                <xsl:element name="mmd:description">NA</xsl:element>
                <xsl:element name="mmd:resource">
                    <xsl:value-of select="dif:Online_Resource"/>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dif:Parameters|dif:Science_Keywords">
        <xsl:if test="/dif:DIF[not(contains(dif:Entry_ID,'PANGAEA'))]">
            <!--
          <xsl:element name="mmd:keywords">
              <xsl:attribute name="vocabulary">GCMD</xsl:attribute>
          -->
              <xsl:element name="mmd:keyword">
                  <xsl:value-of select="dif:Category"/> &gt; <xsl:value-of select="dif:Topic"/> &gt; <xsl:value-of select="dif:Term" /><xsl:if test="dif:Variable_Level_1"> &gt; <xsl:value-of select="dif:Variable_Level_1" /></xsl:if><xsl:if test="dif:Variable_Level_2"> &gt; <xsl:value-of select="dif:Variable_Level_2" /></xsl:if><xsl:if test="dif:Variable_Level_3"> &gt; <xsl:value-of select="dif:Variable_Level_3" /></xsl:if>
              </xsl:element>
              <!--
          </xsl:element>
          -->
      </xsl:if>
  </xsl:template>

  <xsl:template match="dif:ISO_Topic_Category">
      <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
      <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
      <xsl:variable name="isov" select="normalize-space(translate(.,$lowercase,$uppercase))" />
      <xsl:for-each select="$isoLUD">
          <xsl:value-of select ="name()" />
          <xsl:variable name="isoe" select="key('isoc',$isov)/skos:prefLabel"/>
	  <xsl:element name="mmd:iso_topic_category">
	      <xsl:choose>
		  <xsl:when test="$isoe != ''">
                      <xsl:value-of select="$isoe"/>
	          </xsl:when>
		  <xsl:otherwise>
		      <xsl:text>Not available</xsl:text>
	          </xsl:otherwise>
	      </xsl:choose>
	  </xsl:element>
      </xsl:for-each>
  </xsl:template>


  <xsl:template match="dif:Keyword|dif:Ancillary_Keyword">
      <!--
      <xsl:element name="mmd:keywords">
      <xsl:attribute name="vocabulary">None</xsl:attribute>
      -->
          <xsl:element name="mmd:keyword">
              <xsl:value-of select="." />
          </xsl:element>
          <!--
      </xsl:element>
      -->
  </xsl:template>

  <xsl:template match="dif:Data_Set_Progress|dif:Dataset_Progress">
      <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
      <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
      <xsl:variable name="dif_status" select="normalize-space(translate(.,$lowercase, $uppercase))" />
      <xsl:variable name="mmd_status_mapping" select="document('')/*/mapping:dataset_status[@dif=$dif_status]/@mmd" />
      <xsl:choose>
	 <xsl:when test="$mmd_status_mapping != ''">
            <xsl:value-of select="$mmd_status_mapping" />
         </xsl:when>
	 <xsl:otherwise>
            <xsl:text>Not available</xsl:text>
	 </xsl:otherwise>
      </xsl:choose>
  </xsl:template>

  <xsl:template match="dif:Temporal_Coverage">
      <xsl:if test="not(dif:Paleo_DateTime)">
          <xsl:element name="mmd:temporal_extent">
              <xsl:element name="mmd:start_date">
                  <xsl:choose>
                      <xsl:when test="dif:Periodic_DateTime">
                          <xsl:call-template name="formatdate">
                              <xsl:with-param name="datestr" select="dif:Periodic_DateTime/dif:Start_Date" />
                          </xsl:call-template>
                      </xsl:when>
                      <xsl:when test="dif:Range_DateTime">
                          <xsl:call-template name="formatdate">
                              <xsl:with-param name="datestr" select="dif:Range_DateTime/dif:Beginning_Date_Time" />
                          </xsl:call-template>
                      </xsl:when>
                      <xsl:when test="dif:Single_DateTime">
                          <xsl:call-template name="formatdate">
                              <xsl:with-param name="datestr" select="dif:Single_DateTime" />
                          </xsl:call-template>
                      </xsl:when>
                      <xsl:otherwise>
                          <xsl:call-template name="formatdate">
                              <xsl:with-param name="datestr" select="dif:Start_Date" />
                          </xsl:call-template>
                      </xsl:otherwise>
                  </xsl:choose>
              </xsl:element>
              <xsl:if test="dif:Periodic_DateTime/dif:End_Date !='' or dif:Range_DateTime/dif:Ending_Date_Time !='' or dif:Stop_Date !='' or dif:Single_DateTime">
                  <xsl:element name="mmd:end_date">
                      <xsl:choose>
                          <xsl:when test="dif:Periodic_DateTime">
                              <xsl:call-template name="formatdate">
                                  <xsl:with-param name="datestr" select="dif:Periodic_DateTime/dif:End_Date" />
                              </xsl:call-template>
                          </xsl:when>
                          <xsl:when test="dif:Range_DateTime">
                              <xsl:call-template name="formatdate">
                                  <xsl:with-param name="datestr" select="dif:Range_DateTime/dif:Ending_Date_Time" />
                              </xsl:call-template>
                          </xsl:when>
                          <xsl:when test="dif:Single_DateTime">
                              <xsl:call-template name="formatdate">
                                  <xsl:with-param name="datestr" select="dif:Single_DateTime" />
                              </xsl:call-template>
                          </xsl:when>
                          <xsl:otherwise>
                              <xsl:call-template name="formatdate">
                                  <xsl:with-param name="datestr" select="dif:Stop_Date" />
                              </xsl:call-template>
                          </xsl:otherwise>
                      </xsl:choose>
                  </xsl:element>
              </xsl:if>
          </xsl:element>
      </xsl:if>
  </xsl:template>


<!--  <xsl:template match="dif:Temporal_Coverage/dif:Stop_Date">
    <xsl:element name="mmd:datacollection_period_to">
      <xsl:value-of select="." />
    </xsl:element>
  </xsl:template>
-->

  <!-- Need to fix points for KOPRI
  -->
  <xsl:template match="dif:Spatial_Coverage">
      <xsl:choose>
          <xsl:when test="dif:Geometry/dif:Bounding_Rectangle">
              <xsl:element name="mmd:geographic_extent">
                  <xsl:element name="mmd:rectangle">
                      <xsl:attribute name="srsName">
                          <xsl:value-of select="'EPSG:4326'" />
                      </xsl:attribute>
                      <xsl:element name="mmd:south">
                          <xsl:value-of select="dif:Geometry/dif:Bounding_Rectangle/dif:Southernmost_Latitude" />
                      </xsl:element>
                      <xsl:element name="mmd:north">
                          <xsl:value-of select="dif:Geometry/dif:Bounding_Rectangle/dif:Northernmost_Latitude" />
                      </xsl:element>
                      <xsl:element name="mmd:west">
                          <xsl:value-of select="dif:Geometry/dif:Bounding_Rectangle/dif:Westernmost_Longitude" />
                      </xsl:element>
                      <xsl:element name="mmd:east">
                          <xsl:value-of select="dif:Geometry/dif:Bounding_Rectangle/dif:Easternmost_Longitude" />
                      </xsl:element>
                  </xsl:element>
              </xsl:element>
          </xsl:when>
          <xsl:when test="dif:Geometry/dif:Polygon/dif:Boundary/dif:Point or dif:Geometry/dif:Point">
          <!-- For the time being and based on the current search model for MMD, Points are translated into a bounding box. Øystein Godøy, METNO/FOU, 2023-04-27 -->
          <!-- XSLT 2 version, but doesn't help us in python...
              <xsl:element name="mmd:rectangle">
              <xsl:attribute name="srsName">
              <xsl:value-of select="'EPSG:4326'" />
              </xsl:attribute>
              <xsl:element name="mmd:north">
              <xsl:value-of select="max(//dif:Point_Latitude)"/>
              </xsl:element>
              <xsl:element name="mmd:south">
              <xsl:value-of select="min(//dif:Point_Latitude)"/>
              </xsl:element>
              <xsl:element name="mmd:east">
              <xsl:value-of select="max(//dif:Point_Longitude)"/>
              </xsl:element>
              <xsl:element name="mmd:west">
              <xsl:value-of select="min(//dif:Point_Longitude)"/>
              </xsl:element>
              </xsl:element>
          -->
              <xsl:element name="mmd:geographic_extent">
                  <xsl:element name="mmd:rectangle">
                      <xsl:attribute name="srsName">
                          <xsl:value-of select="'EPSG:4326'" />
                      </xsl:attribute>
                      <xsl:for-each select="key('mylat',//dif:Point_Latitude)">
                          <xsl:sort select="." data-type="number" order="ascending"/>
                          <xsl:if test="position() = 1">
                              <xsl:element name="mmd:south">
                                  <xsl:value-of select="."/>
                              </xsl:element>
                          </xsl:if>
                          <xsl:if test="position() = last()">
                              <xsl:element name="mmd:north">
                                  <xsl:value-of select="."/>
                              </xsl:element>
                          </xsl:if>
                      </xsl:for-each>
                      <xsl:for-each select="key('mylon',//dif:Point_Longitude)">
                          <xsl:sort select="." data-type="number" order="ascending"/>
                          <xsl:if test="position() = 1">
                              <xsl:element name="mmd:west">
                                  <xsl:value-of select="."/>
                              </xsl:element>
                          </xsl:if>
                          <xsl:if test="position() = last()">
                              <xsl:element name="mmd:east">
                                  <xsl:value-of select="."/>
                              </xsl:element>
                          </xsl:if>
                      </xsl:for-each>
                  </xsl:element>
              </xsl:element>
          </xsl:when>
          <xsl:otherwise>
              <xsl:element name="mmd:geographic_extent">
                  <xsl:element name="mmd:rectangle">
                      <xsl:attribute name="srsName">
                          <xsl:value-of select="'EPSG:4326'" />
                      </xsl:attribute>
                      <xsl:element name="mmd:south">
                          <xsl:value-of select="dif:Southernmost_Latitude" />
                      </xsl:element>
                      <xsl:element name="mmd:north">
                          <xsl:value-of select="dif:Northernmost_Latitude" />
                      </xsl:element>
                      <xsl:element name="mmd:west">
                          <xsl:value-of select="dif:Westernmost_Longitude" />
                      </xsl:element>
                      <xsl:element name="mmd:east">
                          <xsl:value-of select="dif:Easternmost_Longitude" />
                      </xsl:element>
                  </xsl:element>
              </xsl:element>
          </xsl:otherwise>
      </xsl:choose>
  </xsl:template>

        <!-- Fix me -->
        <xsl:template match="dif:Location">
        </xsl:template>

        <xsl:template match="dif:Data_Resolution/dif:Latitude_Resolution">
        </xsl:template>


        <xsl:template match="dif:Data_Resolution/dif:Longitude_Resolution">
        </xsl:template>

        <xsl:template match="dif:Project">
            <xsl:element name="mmd:project">
                <xsl:element name="mmd:short_name">
                    <xsl:value-of select="dif:Short_Name" />
                </xsl:element>
                <xsl:element name="mmd:long_name">
                    <xsl:value-of select="dif:Long_Name" />
                </xsl:element>
            </xsl:element>
        </xsl:template>

        <xsl:template match="dif:Access_Constraints">
            <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
            <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
            <xsl:variable name="difaccess" select="translate(., $uppercase, $lowercase)"/>
	    <xsl:for-each select="$isoLUD" >
		<xsl:if test="key('accessc', $difaccess)">
		    <xsl:variable name="prefaccess" select="key('accessc', $difaccess)/../skos:prefLabel"/>
                    <xsl:element name="mmd:access_constraint">
                        <xsl:value-of select="$prefaccess" />
                    </xsl:element>
		</xsl:if>
	    </xsl:for-each>
        </xsl:template>

        <xsl:template match="dif:Use_Constraints">
            <xsl:variable name="difuse" select="."/>
	    <xsl:if test="not(normalize-space($difuse)='')">
	        <xsl:for-each select="$isoLUD" >
	            <xsl:choose>
                        <xsl:when test="key('usec', $difuse)">
                            <xsl:variable name="prefuseid" select="key('usec', $difuse)/skos:prefLabel"/>
                            <xsl:variable name="prefuseref" select="key('usec', $difuse)/skos:exactMatch/@rdf:resource[contains(.,'spdx')]"/>
                            <xsl:element name="mmd:use_constraint">
                                <xsl:element name="mmd:identifier">
                                    <xsl:value-of select="$prefuseid" />
                                </xsl:element>
                                <xsl:element name="mmd:resource">
                                    <xsl:value-of select="$prefuseref" />
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="key('useca', $difuse)">
                            <xsl:variable name="prefuseid" select="key('useca', $difuse)/skos:prefLabel"/>
                            <xsl:variable name="prefuseref" select="key('useca', $difuse)/skos:exactMatch/@rdf:resource[contains(.,'spdx')]"/>
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
                                    <xsl:value-of select="$difuse" />
                                </xsl:element>
                            </xsl:element>
	                </xsl:otherwise>
	            </xsl:choose>
	        </xsl:for-each>
            </xsl:if>
        </xsl:template>

        <xsl:template match="dif:Data_Set_Language|dif:Dataset_Language">
           <xsl:variable name="dif_language" select="normalize-space(.)" />
           <xsl:variable name="mmd_language_mapping" select="document('')/*/mapping:language[@dif=$dif_language]/@mmd" />
           <xsl:if test="$mmd_language_mapping != ''">
              <xsl:element name="mmd:dataset_language">
                 <xsl:value-of select="$mmd_language_mapping" />
              </xsl:element>
           </xsl:if>
        </xsl:template>

        <xsl:template match="dif:Related_URL">
            <xsl:choose>
                <xsl:when test="dif:URL_Content_Type/dif:Type[contains(text(),'GET DATA')]">
                    <xsl:choose>
                        <xsl:when test="dif:URL_Content_Type/dif:Subtype[contains(text(),'OPENDAP')]">
                            <xsl:element name="mmd:data_access">
                                <xsl:element name="mmd:type">OPeNDAP</xsl:element>
                                <xsl:element name="mmd:description">
                                    <xsl:value-of select="dif:Description" />
                                </xsl:element>
                                <xsl:element name="mmd:resource">
                                    <xsl:value-of select="dif:URL" />
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="not(dif:URL_Content_Type/dif:Subtype) or dif:URL_Content_Type/dif:Subtype = ''">
                            <xsl:element name="mmd:data_access">
                                <xsl:element name="mmd:type">HTTP</xsl:element>
                                <xsl:element name="mmd:description">
                                    <xsl:value-of select="dif:Description" />
                                </xsl:element>
                                <xsl:element name="mmd:resource">
                                    <xsl:value-of select="dif:URL" />
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="dif:URL_Content_Type/dif:Type[contains(text(),'USE SERVICE API')] or dif:URL_Content_Type/dif:Type[contains(text(),'GET SERVICE')]"> 
                    <xsl:choose>
                        <xsl:when test="dif:URL_Content_Type/dif:Subtype[contains(text(),'OPENDAP DATA')]">
                            <xsl:element name="mmd:data_access">
                                <xsl:element name="mmd:type">OPeNDAP</xsl:element>
                                <xsl:element name="mmd:description">
                                    <xsl:value-of select="dif:Description" />
                                </xsl:element>
                                <xsl:element name="mmd:resource">
                                    <xsl:value-of select="dif:URL" />
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="dif:URL_Content_Type/dif:Subtype[contains(text(),'GET WEB MAP SERVICE')]">
                            <xsl:element name="mmd:data_access">
                                <xsl:element name="mmd:type">OGC WMS</xsl:element>
                                <xsl:element name="mmd:description">
                                    <xsl:value-of select="dif:Description" />
                                </xsl:element>
                                <xsl:element name="mmd:resource">
                                    <xsl:value-of select="dif:URL" />
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
		<xsl:when test="dif:URL_Content_Type/dif:Type = 'DATA SET LANDING PAGE' or dif:URL_Content_Type/dif:Type = 'DATASET LANDING PAGE' or dif:URL_Content_Type/dif:Type = 'VIEW DATA SET LANDING PAGE'">
		    <xsl:if test="(not(../dif:Dataset_Citation/dif:Online_Resource) or ../dif:Dataset_Citation/dif:Online_Resource = '') and (not(../dif:Data_Set_Citation/dif:Online_Resource) or ../dif:Data_Set_Citation/dif:Online_Resource = '')">
		        <xsl:element name="mmd:related_information">
		           <xsl:element name="mmd:type">
                              <xsl:text>Dataset landing page</xsl:text>
                           </xsl:element>
		           <xsl:element name="mmd:description">
                              <xsl:text>Dataset landing page</xsl:text>
                           </xsl:element>
		           <xsl:element name="mmd:resource">
		              <xsl:value-of select="dif:URL" />
                           </xsl:element>
                        </xsl:element>
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
        </xsl:template>


        <!--
        <xsl:template match="dif:Originating_Center">
            <xsl:element name="mmd:personnel">
              <xsl:element name="mmd:role">
		  <xsl:variable name="string-mod">
		      <xsl:call-template name="string-replace">
			<xsl:with-param name="string"  select="/dif:DIF/dif:Personnel/dif:Role"/>
			<xsl:with-param name="replace" select="'Contact'" />
			<xsl:with-param name="with" select="'contact'" />
		      </xsl:call-template>
		    </xsl:variable>
		    <xsl:value-of select="$string-mod" />
                </xsl:element>
                <xsl:element name="mmd:name">
                    <xsl:value-of select="/dif:DIF/dif:Personnel/dif:First_Name"/>  <xsl:text> </xsl:text> <xsl:value-of select="/dif:DIF/dif:Personnel/dif:Last_Name"/>
                </xsl:element>
                <xsl:element name="mmd:email">
                    <xsl:value-of select="/dif:DIF/dif:Personnel/dif:Email" />
                </xsl:element>
                <xsl:element name="mmd:phone"></xsl:element>
                <xsl:element name="mmd:fax"></xsl:element>
                <xsl:element name="mmd:organisation">
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:element>
            </xsl:template>
        -->

        <xsl:template match="dif:Data_Center">
            <xsl:element name="mmd:data_center">
                <xsl:element name="mmd:data_center_name">
                    <xsl:element name="mmd:short_name">
                        <xsl:value-of select="dif:Data_Center_Name/dif:Short_Name" />
                    </xsl:element>
                    <xsl:element name="mmd:long_name">
                        <xsl:value-of select="dif:Data_Center_Name/dif:Long_Name" />
                    </xsl:element>
                </xsl:element>
                <xsl:element name="mmd:data_center_url">
                    <xsl:value-of select="dif:Data_Center_URL" />
                </xsl:element>
            </xsl:element>

            <xsl:element name="mmd:personnel">
                <xsl:element name="mmd:role">
                    <xsl:text>Data center contact</xsl:text>
                </xsl:element>
                <xsl:element name="mmd:name">
                    <xsl:value-of select="dif:Personnel/dif:First_Name"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="dif:Personnel/dif:Last_Name"/>
                </xsl:element>
                <xsl:element name="mmd:email">
                    <xsl:value-of select="dif:Personnel/dif:Email"/>
                </xsl:element>
                <!-- The validity of this translation depends slightly on the providers as the approaches seen are heterogeneous... Øystein Godøy, METNO/FOU, 2023-04-28 -->
                <xsl:element name="mmd:organisation">
                    <xsl:value-of select="dif:Long_Name"/>
                </xsl:element>
            </xsl:element>
        </xsl:template>

        <xsl:template match="dif:Organization">
            <xsl:if test="dif:Organization_Type[contains(text(),'ARCHIVER')]">
                <xsl:element name="mmd:data_center">
                    <xsl:element name="mmd:data_center_name">
                        <xsl:element name="mmd:short_name">
                            <xsl:value-of select="dif:Organization_Name/dif:Short_Name" />
                        </xsl:element>
                        <xsl:element name="mmd:long_name">
                            <xsl:value-of select="dif:Organization_Name/dif:Long_Name" />
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="mmd:data_center_url">
                        <xsl:value-of select="dif:Organization_URL" />
                    </xsl:element>
                </xsl:element>

                <xsl:element name="mmd:personnel">
                    <xsl:element name="mmd:role">
                        <xsl:text>Data center contact</xsl:text>
                    </xsl:element>
                    <xsl:element name="mmd:name">
			<xsl:if test="dif:Personnel/dif:Contact_Person">
                           <xsl:value-of select="dif:Personnel/dif:Contact_Person/dif:First_Name"/>
                           <xsl:text> </xsl:text>
                           <xsl:value-of select="dif:Personnel/dif:Contact_Person/dif:Last_Name"/>
		        </xsl:if>
			<xsl:if test="dif:Personnel/dif:Contact_Group">
                           <xsl:value-of select="dif:Personnel/dif:Contact_Group/dif:Name"/>
		        </xsl:if>
                    </xsl:element>
                    <xsl:element name="mmd:email">
			<xsl:if test="dif:Personnel/dif:Contact_Person">
                           <xsl:value-of select="dif:Personnel/dif:Contact_Person/dif:Email"/>
		        </xsl:if>
			<xsl:if test="dif:Personnel/dif:Contact_Group">
                           <xsl:value-of select="dif:Personnel/dif:Contact_Group/dif:Email"/>
		        </xsl:if>
                    </xsl:element>
                    <!-- The validity of this translation depends slightly on the providers as the approaches seen are heterogeneous... Øystein Godøy, METNO/FOU, 2023-04-28 -->
                    <xsl:element name="mmd:organisation">
                        <xsl:value-of select="dif:Personnel/dif:Contact_Person/dif:Last_Name"/>
                    </xsl:element>
                    <!-- contact_address is not extracted since records harvested differs so much in the implementation that it can't be done in a relieable manner
                    <xsl:if test="dif:Personnel/dif:Contact_Person/dif:Address">
                        <xsl:element name="mmd:contact_address">
                            <xsl:if test="dif:Personnel/dif:Contact_Person/dif:Address/dif:Stree_Address">
                            </xsl:if>
                        </xsl:element>
                        </xsl:if>
                    -->
                </xsl:element>
            </xsl:if>
        </xsl:template>

        <xsl:template match="dif:Reference">
        </xsl:template>

        <xsl:template match="dif:Summary">
            <xsl:choose>
                <xsl:when test="dif:Abstract">
                    <xsl:element name="mmd:abstract">
			<xsl:attribute name="xml:lang">en</xsl:attribute>
                        <xsl:value-of select="dif:Abstract" />
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="mmd:abstract">
			<xsl:attribute name="xml:lang">en</xsl:attribute>
                        <xsl:value-of select="." />
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:template>

        <xsl:template match="dif:Personnel">
            <xsl:element name="mmd:personnel">
	      <xsl:element name="mmd:role">
                  <xsl:choose>
                      <xsl:when test="dif:Role[contains(text(),'DIF Author')]">
                          <xsl:text>Metadata author</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'METADATA AUTHOR')]">
                          <xsl:text>Metadata author</xsl:text>
                      </xsl:when>
                      <!-- Fix for NIPR data, as they are not following the standard. To be extracted and handled as lookup table or SKOS -->
                      <xsl:when test="dif:Role[contains(text(),'pointOfContact')]">
                          <xsl:text>Technical contact</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role = ''">
                          <xsl:text>Technical contact</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'principalInvestigator')]">
                          <xsl:text>Investigator</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'originator')]">
                          <xsl:text>Investigator</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'INVESTIGATOR')]">
                          <xsl:text>Investigator</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'Investigaror')]">
                          <xsl:text>Investigator</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'resourceProvider')]">
                          <xsl:text>Metadata author</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'Data manager')]">
                          <xsl:text>Metadata author</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'publisher')]">
                          <xsl:text>Data center contact</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'TECHNICAL CONTACT')]">
                          <xsl:text>Technical contact</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'processor')]">
                          <xsl:text>Technical contact</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'owner')]">
                          <xsl:text>Technical contact</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'Author')]">
                          <xsl:text>Technical contact</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'author')]">
                          <xsl:text>Technical contact</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'Observer')]">
                          <xsl:text>Technical contact</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'user')]">
                          <xsl:text>Technical contact</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'Coordinator')]">
                          <xsl:text>Technical contact</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'Contributor')]">
                          <xsl:text>Technical contact</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'contributor')]">
                          <xsl:text>Technical contact</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'Station manager')]">
                          <xsl:text>Technical contact</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'Data maneger')]">
                          <xsl:text>Technical contact</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'Programmer')]">
                          <xsl:text>Technical contact</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'Advisor')]">
                          <xsl:text>Technical contact</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'Data provider')]">
                          <xsl:text>Technical contact</xsl:text>
                      </xsl:when>
                      <xsl:when test="dif:Role[contains(text(),'distributor')]">
                          <xsl:text>Data center contact</xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                          <!--xsl:value-of select="." /-->
                          <xsl:variable name="string-mod">
                              <xsl:call-template name="string-replace">
                                  <xsl:with-param name="string"  select="dif:Role"/>
                                  <xsl:with-param name="replace" select="'Contact'" />
                                  <xsl:with-param name="with" select="'contact'" />
                              </xsl:call-template>
                          </xsl:variable>
		    <xsl:value-of select="$string-mod" />
                      </xsl:otherwise>
                  </xsl:choose>
                 <!--   <xsl:value-of select="dif:Role"/> -->
                </xsl:element>
                <xsl:element name="mmd:name">
                    <xsl:choose>
                        <xsl:when test="dif:Contact_Person">
                            <xsl:value-of select="dif:Contact_Person/dif:First_Name"/>
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="dif:Contact_Person/dif:Last_Name"/>
                        </xsl:when>
                        <xsl:when test="dif:Contact_Group">
                            <xsl:value-of select="dif:Contact_Group/dif:Name"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="dif:First_Name"/>
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="dif:Last_Name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <xsl:element name="mmd:email">
                    <xsl:choose>
                        <xsl:when test="dif:Contact_Person">
                            <xsl:value-of select="dif:Contact_Person/dif:Email"/>
                        </xsl:when>
                        <xsl:when test="dif:Contact_Group">
                            <xsl:value-of select="dif:Contact_Group/dif:Email"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="dif:Email"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:element>
        </xsl:template>

        <xsl:template match="dif:Metadata_Name">
        </xsl:template>

        <xsl:template match="dif:Metadata_Version">
        </xsl:template>

        <!-- For DIF10, no date transformation for now... -->
        <xsl:template match="dif:Metadata_Dates">
            <xsl:element name="mmd:last_metadata_update">
                <xsl:if test="dif:Metadata_Creation" >
                    <xsl:element name="mmd:update">
                        <xsl:element name="mmd:datetime">
                            <xsl:value-of select="dif:Metadata_Creation" />
                        </xsl:element>
                        <xsl:element name="mmd:type">
                            <xsl:text>Created</xsl:text>
                        </xsl:element>
                        <xsl:element name="mmd:note">
                            <xsl:text>Made by transformation from DIF10 record</xsl:text>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="dif:Metadata_Last_Revision" >
                    <xsl:variable name="datetimestr">
                        <xsl:value-of select="dif:Metadata_Last_Revision" />
                    </xsl:variable>
		    <!--DIF 10 supports also a DateEnum vocabulary that is not datetime type-->
                    <xsl:if test="$datetimestr != 'Not provided' and $datetimestr !='unknown' and $datetimestr !='present' and $datetimestr !='unbounded' and $datetimestr !='future' and translate($datetimestr, '1234567890', '') != $datetimestr">
                        <xsl:element name="mmd:update">
                            <xsl:element name="mmd:datetime">
                                <xsl:value-of select="dif:Metadata_Last_Revision" />
                            </xsl:element>
                            <xsl:element name="mmd:type">
                                <xsl:text>Major modification</xsl:text>
                            </xsl:element>
                            <xsl:element name="mmd:note">
                                <xsl:text>Captured from DIF10 record</xsl:text>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                </xsl:if>
            </xsl:element>
        </xsl:template>

        <xsl:template match="dif:DIF_Creation_Date">
	    <xsl:if test="current() !=''">
                <xsl:element name="mmd:update">
                    <xsl:element name="mmd:datetime">
                        <xsl:choose>
                            <xsl:when test="contains(.,'/')">
                               <xsl:call-template name="formatdate">
                                   <xsl:with-param name="datestr" select="translate(., '/', '-')" />
                               </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                               <xsl:call-template name="formatdate">
                                   <xsl:with-param name="datestr" select="." />
                               </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <xsl:element name="mmd:type">
                        <xsl:text>Created</xsl:text>
                    </xsl:element>
                    <xsl:element name="mmd:note">
                        <xsl:text>Made by transformation from DIF record</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:template>

        <xsl:template match="dif:Last_DIF_Revision_Date">
	    <xsl:if test="current() !=''">
                <xsl:element name="mmd:update">
                    <xsl:element name="mmd:datetime">
                        <xsl:call-template name="formatdate">
                            <xsl:with-param name="datestr" select="." />
                        </xsl:call-template>
                        <!--xsl:text>T00:00:00.001Z</xsl:text-->
                    </xsl:element>
                    <xsl:element name="mmd:type">
                        <xsl:text>Minor modification</xsl:text>
                    </xsl:element>
                    <xsl:element name="mmd:note">
                        <xsl:text>Made by transformation from DIF record, type is hardcoded.</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:template>

        <xsl:template match="dif:Parent_DIF">
            <xsl:element name="mmd:related_dataset">
                <xsl:attribute name="relation_type">parent</xsl:attribute>
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:template>


        <xsl:template match="dif:Private">
        </xsl:template>

        <xsl:template name="formatdate">
            <xsl:param name="datestr" />
            <!-- input format YYYY-MM-DD or YYYY-MM-DDTHH:MM:SSZ -->
            <!-- output format YYYY-MM-DDTHH:MM:SSZ -->

            <xsl:choose>
                <xsl:when test="translate($datestr,'123456789','000000000') = '0000-00-00T00:00:00Z'">
                    <xsl:variable name="HH">
                        <xsl:value-of select="substring($datestr,12,2)" />
                    </xsl:variable>
                    <xsl:variable name="MM">
                        <xsl:value-of select="substring($datestr,15,2)" />
                    </xsl:variable>
                    <xsl:variable name="SS">
                        <xsl:value-of select="substring($datestr,18,2)" />
                    </xsl:variable>
                <xsl:variable name="yyyy">
                    <xsl:value-of select="substring($datestr,1,4)" />
                </xsl:variable>
                <xsl:variable name="mm">
                    <xsl:value-of select="substring($datestr,6,2)" />
                </xsl:variable>
                <xsl:variable name="dd">
                    <xsl:value-of select="substring($datestr,9,2)" />
                </xsl:variable>
                <xsl:value-of select="$yyyy" />
                <xsl:value-of select="'-'" />
                <xsl:value-of select="$mm" />
                <xsl:value-of select="'-'" />
                <xsl:value-of select="$dd" />
                <xsl:value-of select="'T'" />
                <xsl:value-of select="$HH" />
                <xsl:value-of select="':'" />
                <xsl:value-of select="$MM" />
                <xsl:value-of select="':'" />
                <xsl:value-of select="$SS" />
                <xsl:value-of select="'Z'" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="yyyy">
                        <xsl:value-of select="substring($datestr,1,4)" />
                    </xsl:variable>
                    <xsl:variable name="mm">
                        <xsl:value-of select="substring($datestr,6,2)" />
                    </xsl:variable>
                    <xsl:variable name="dd">
                        <xsl:value-of select="substring($datestr,9,2)" />
                    </xsl:variable>
                    <xsl:variable name="HH">
                        <xsl:value-of select="12" />
                    </xsl:variable>
                    <xsl:variable name="MM">
                        <xsl:value-of select="'00'" />
                    </xsl:variable>
                    <xsl:variable name="SS">
                        <xsl:value-of select="'00'" />
                    </xsl:variable>
                <xsl:value-of select="$yyyy" />
                <xsl:value-of select="'-'" />
                <xsl:value-of select="$mm" />
                <xsl:value-of select="'-'" />
                <xsl:value-of select="$dd" />
                <xsl:value-of select="'T'" />
                <xsl:value-of select="$HH" />
                <xsl:value-of select="':'" />
                <xsl:value-of select="$MM" />
                <xsl:value-of select="':'" />
                <xsl:value-of select="$SS" />
                <xsl:value-of select="'Z'" />
                </xsl:otherwise>

                <!--xsl:value-of select="$yyyy" />
                <xsl:value-of select="'-'" />
                <xsl:value-of select="$mm" />
                <xsl:value-of select="'-'" />
                <xsl:value-of select="$dd" />
          <xsl:value-of select="'T'" />
          <xsl:value-of select="$HH" />
          <xsl:value-of select="':'" />
          <xsl:value-of select="$MM" />
          <xsl:value-of select="':'" />
          <xsl:value-of select="$SS" />
          <xsl:value-of select="'Z'" /-->
            </xsl:choose>
      <!--
      <xsl:value-of select="$yyyy" />
      <xsl:value-of select="'-'" />
      <xsl:value-of select="$mm" />
      <xsl:value-of select="'-'" />
      <xsl:value-of select="$dd" />
      -->
        </xsl:template>

<!--
    ALTERNATIVE SEARCH & REPLACE
    string:     The text to be evaluated
    replace:    The character or string to look for in the above string
    with:       What to replace it with
    Slightly more long winded approach if that's how you prefer to roll.
--> 

<xsl:template name="string-replace">
    <xsl:param name="string" />
    <xsl:param name="replace" />
    <xsl:param name="with" />

    <xsl:choose>
        <xsl:when test="contains($string, $replace)">
            <xsl:value-of select="substring-before($string, $replace)" />
            <xsl:value-of select="$with" />
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="substring-after($string,$replace)" />
                <xsl:with-param name="replace" select="$replace" />
                <xsl:with-param name="with" select="$with" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$string" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Mappings for dataset_production_status -->
<mapping:dataset_status dif="COMPLETE" mmd="Complete" />
<mapping:dataset_status dif="FINISHED" mmd="Complete" />
<mapping:dataset_status dif="IN WORK" mmd="In Work" />
<mapping:dataset_status dif="INWORK" mmd="In Work" />
<mapping:dataset_status dif="PLANNED" mmd="Planned" />
<mapping:dataset_status dif="NOT PROVIDED" mmd="Not available" />
<mapping:dataset_status dif="NOT APPLICABLE" mmd="Not available" />

<!-- Mappings for dataset_language -->
<mapping:language dif="English" mmd="en" />
<mapping:language dif="en" mmd="en" />
<mapping:language dif="eng" mmd="en" />
<mapping:language dif="Norwegian" mmd="no" />


</xsl:stylesheet>
