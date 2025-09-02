<?xml version="1.0" encoding="utf-8"?>
<!--This xslt converts from mmd to iso 19115-2 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:gmi="http://www.isotc211.org/2005/gmi" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:mmd="http://www.met.no/schema/mmd"
    xsi:schemaLocation="http://www.isotc211.org/2005/gmd http://www.isotc211.org/2005/gmx http://www.isotc211.org/2005/gmi http://www.ngdc.noaa.gov/metadata/published/xsd/schema.xsd"
    xmlns:mapping="http://www.met.no/schema/mmd/iso2mmd"      
    version="1.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes" />

    <xsl:template match="/mmd:mmd">
        <xsl:element name="gmi:MI_Metadata">
            <xsl:copy-of select="document('')/xsl:stylesheet/namespace::*[name()!='xsl' and name()!='mapping' and name()!='mmd']"/>
            <xsl:copy-of select="document('')/*/@xsi:schemaLocation"/>


            <xsl:apply-templates select="mmd:metadata_identifier" />

            <gmd:language>
                <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2" codeListValue="eng">English</gmd:LanguageCode>
            </gmd:language>        
            <gmd:characterSet>
                <gmd:MD_CharacterSetCode codeList="https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode"
                               codeListValue="utf8">utf8</gmd:MD_CharacterSetCode>
            </gmd:characterSet>
            
            <gmd:hierarchyLevel>
                <gmd:MD_ScopeCode codeList="https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_ScopeCode"
                                codeListValue="dataset"/>
            </gmd:hierarchyLevel>        

            <xsl:element name="gmd:contact">
		<xsl:choose>
		<xsl:when test="mmd:personnel[mmd:role = 'Metadata author']">
                    <xsl:apply-templates select="mmd:personnel[mmd:role = 'Metadata author']" />
		</xsl:when>
		<xsl:otherwise>
                    <xsl:element name="gmd:CI_ResponsibleParty">
                        
                        <xsl:element name="gmd:organisationName">
                            <xsl:element name="gco:CharacterString">
	            		<xsl:value-of select="mmd:personnel[mmd:role = 'Investigator']/mmd:organisation" />
                            </xsl:element>
                        </xsl:element>            
                        
                        
                        <xsl:element name="gmd:role">
                            <xsl:element name="gmd:CI_RoleCode">
                                <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode</xsl:attribute>
                                    <xsl:attribute name="codeListValue">
                                        <xsl:text>pointOfContact</xsl:text>
                                    </xsl:attribute>
                                    <xsl:text>pointOfContact</xsl:text>
                            </xsl:element>             
                        </xsl:element>
                    </xsl:element>
		</xsl:otherwise>
		</xsl:choose>
            </xsl:element>
       

            <xsl:element name="gmd:dateStamp">
                <xsl:element name="gco:DateTime">
	            <xsl:variable name="latest">
	                <xsl:for-each select="mmd:last_metadata_update/mmd:update/mmd:datetime">
                            <xsl:sort select="." order="descending" />
                            <xsl:if test="position() = 1">
                                <xsl:value-of select="."/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:value-of select="$latest"/>
                </xsl:element>
            </xsl:element>

            <gmd:metadataStandardName>
                <gco:CharacterString>ISO 19115-2 Geographic Information - Metadata Part 2 Extensions for imagery and gridded data</gco:CharacterString>
            </gmd:metadataStandardName>
            <gmd:metadataStandardVersion>
                <gco:CharacterString>ISO 19115-2:2009(E)</gco:CharacterString>
            </gmd:metadataStandardVersion>

            <xsl:apply-templates select="mmd:related_information[mmd:type = 'Dataset landing page']" />

            <gmd:locale>
                <gmd:PT_Locale id="locale-nob">
                    <gmd:languageCode>
                        <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2" codeListValue="nob">Norwegian</gmd:LanguageCode>
                    </gmd:languageCode>
                    <gmd:characterEncoding>
                        <gmd:MD_CharacterSetCode
                            codeList="https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode"
                            codeListValue="utf8"/>
                    </gmd:characterEncoding>
                </gmd:PT_Locale>
            </gmd:locale>            
            
        
            <xsl:element name="gmd:identificationInfo">
                <xsl:element name="gmd:MD_DataIdentification">
                
                
                    <xsl:element name="gmd:citation">
                        <xsl:element name="gmd:CI_Citation">
                
                            <!-- non-english elements taken care of within template -->
			    <xsl:choose>
			        <xsl:when test="mmd:title[@xml:lang = 'en']">
                                    <xsl:apply-templates select="mmd:title[@xml:lang = 'en']" />
			        </xsl:when>
			        <xsl:otherwise>
                                    <xsl:apply-templates select="mmd:title" />
			        </xsl:otherwise>
		            </xsl:choose>
                            
                            
                            <xsl:element name="gmd:date">
                                <xsl:element name="gmd:CI_Date">
                                    <xsl:element name="gmd:date">
					<xsl:choose>
					    <xsl:when test="mmd:dataset_citation/mmd:publication_date !='' ">
                                                <xsl:element name="gco:Date">
                                                    <xsl:value-of select="mmd:dataset_citation/mmd:publication_date" />
                                                </xsl:element>
					    </xsl:when>
					    <xsl:otherwise>
				                <xsl:attribute name="gco:nilReason">unknown</xsl:attribute>
					    </xsl:otherwise>
				        </xsl:choose>
                                    </xsl:element>
                                    <xsl:element name="gmd:dateType">
                                        <xsl:element name="gmd:CI_DateTypeCode">
                                            <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode</xsl:attribute>
                                            <xsl:attribute name="codeListValue">publication</xsl:attribute>
                                            <xsl:text>publication</xsl:text>
                                        </xsl:element>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:element>
                            
                            <!--xsl:apply-templates select="mmd:last_metadata_update" /-->

                            <xsl:element name="gmd:edition">
                                <xsl:element name="gco:CharacterString">
                                    <xsl:value-of select="mmd:dataset_citation/mmd:edition" />
                                </xsl:element>
                            </xsl:element>
                            
                            <xsl:element name="gmd:otherCitationDetails">
                                <xsl:element name="gco:CharacterString">
                                    <xsl:value-of select="mmd:dataset_citation/mmd:other_citation_details" />
                                </xsl:element>                            
                            </xsl:element>

                            <xsl:element name="gmd:identifier">
                                <xsl:element name="gmd:MD_Identifier">
                                    <xsl:element name="gmd:code">
                                        <xsl:element name="gco:CharacterString">
				    	    <xsl:value-of select="mmd:metadata_identifier" />
                                        </xsl:element>					    
                                    </xsl:element>
                                </xsl:element>
                            </xsl:element>
                            
                        </xsl:element>
                    </xsl:element>
                    
                    <!-- non-english elements taken care of within template -->
		    <xsl:choose>
		        <xsl:when test="mmd:abstract[@xml:lang = 'en']">
                            <xsl:apply-templates select="mmd:abstract[@xml:lang = 'en']" />
		        </xsl:when>
		        <xsl:otherwise>
                            <xsl:apply-templates select="mmd:abstract" />
		        </xsl:otherwise>
		    </xsl:choose>

		    <xsl:if test="mmd:dataset_production_status != 'Not available'">
                        <xsl:apply-templates select="mmd:dataset_production_status" />
	            </xsl:if>
                    
		    <xsl:for-each select="mmd:personnel[mmd:role != 'Metadata author']">
                        <xsl:element name="gmd:pointOfContact">
			    <xsl:apply-templates select="." />
                        </xsl:element>
		    </xsl:for-each>
                    
                    <xsl:apply-templates select="mmd:keywords" />

	            <xsl:if test="mmd:access_constraint != ''">
                        <xsl:element name="gmd:resourceConstraints">
                            <xsl:element name="gmd:MD_LegalConstraints">
                        
                                <xsl:element name="gmd:accessConstraints">
                                    <xsl:element name="gmd:MD_RestrictionCode">
                                        <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode</xsl:attribute>
                                        <xsl:attribute name="codeListValue">otherRestrictions</xsl:attribute>
                                        <xsl:text>otherRestrictions</xsl:text>
                                    </xsl:element>
                                </xsl:element>
                        
                                <xsl:element name="gmd:otherConstraints">
                                    <xsl:element name="gco:CharacterString">
                                        <xsl:value-of select="mmd:access_constraint" />
                                    </xsl:element>
                                </xsl:element>
                        
                            </xsl:element>
        
                        </xsl:element>
	            </xsl:if>
         
	            <xsl:if test="mmd:use_constraint != ''">
                        <xsl:element name="gmd:resourceConstraints">
                            <xsl:element name="gmd:MD_LegalConstraints">
                        
                                <xsl:element name="gmd:useConstraints">
                                    <xsl:element name="gmd:MD_RestrictionCode">
                                        <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode</xsl:attribute>
                                        <xsl:attribute name="codeListValue">otherRestrictions</xsl:attribute>
                                        <xsl:text>otherRestrictions</xsl:text>
                                    </xsl:element>
                                </xsl:element>
                        
                                <xsl:element name="gmd:otherConstraints">
                                        <xsl:element name="gmx:Anchor">
                                            <xsl:attribute name="xlink:href">
                            		    <xsl:value-of select="mmd:use_constraint/mmd:resource" />
                                            </xsl:attribute>
                            		    <xsl:value-of select="mmd:use_constraint/mmd:identifier" />
                                        </xsl:element>
                                    <!--xsl:element name="gco:CharacterString">
		            		<xsl:value-of select="mmd:use_constraint/mmd:identifier" />
                                    </xsl:element-->
                                </xsl:element>
                                
                            </xsl:element>
                        </xsl:element>
	            </xsl:if>

                    <xsl:element name="gmd:language">
                        <xsl:element name="gmd:LanguageCode">
                            <xsl:attribute name="codeList">http://www.loc.gov/standards/iso639-2</xsl:attribute>
			        <xsl:choose>
			            <xsl:when test="mmd:dataset_language != ''">
			                <xsl:variable name="language" select="mmd:dataset_language" />
                                        <xsl:variable name="language_mapping" select="document('')/*/mapping:language_code[@mmd=$language]/@iso" />
                                        <xsl:attribute name="codeListValue">
                                           <xsl:value-of select="$language_mapping" />
                                        </xsl:attribute>
                                       <xsl:value-of select="$language_mapping" />
			 	    </xsl:when>
			            <xsl:otherwise>
                                        <xsl:attribute name="codeListValue">
					    <xsl:text>eng</xsl:text>
                                        </xsl:attribute>
					    <xsl:text>eng</xsl:text>
			 	    </xsl:otherwise>
				</xsl:choose>
                        </xsl:element>
                    </xsl:element>


		    <xsl:if test="mmd:iso_topic_category != 'Not available'">
                        <xsl:apply-templates select="mmd:iso_topic_category" />
	            </xsl:if>
                    
                    <xsl:element name="gmd:extent">
                        <xsl:element name="gmd:EX_Extent">
                            <xsl:apply-templates select="mmd:geographic_extent/mmd:rectangle" />
                            <xsl:apply-templates select="mmd:geographic_extent/mmd:polygon" />
                            <xsl:apply-templates select="mmd:temporal_extent" />
                        </xsl:element>                    
                    </xsl:element>


                 </xsl:element>

            </xsl:element>        
            
	    <!--gmi acquisition info-->
	    <xsl:if test="mmd:platform != ''">
                <xsl:element name="gmi:acquisitionInformation">
                    <xsl:element name="gmi:MI_AcquisitionInformation">
                        <xsl:element name="gmi:platform">
                            <xsl:element name="gmi:MI_Platform">
                                <xsl:element name="gmi:identifier">
                                    <xsl:element name="gmd:MD_Identifier">
                                        <xsl:element name="gmd:code">
                                            <xsl:element name="gmx:Anchor">
                                                 <xsl:attribute name="xlink:href">
                                                     <xsl:value-of select="mmd:platform/mmd:resource" />
                                                 </xsl:attribute>
                                                 <xsl:value-of select="mmd:platform/mmd:short_name" />
                                            </xsl:element>
                                        </xsl:element>
                                    </xsl:element>
                                </xsl:element>
                                <xsl:element name="gmi:description">
                                    <xsl:element name="gco:CharacterString">
                                        <xsl:value-of select="mmd:platform/mmd:long_name" />
                                    </xsl:element>
                                </xsl:element>
                                <xsl:element name="gmi:instrument">
                                    <xsl:element name="gmi:MI_Instrument">
                                        <xsl:element name="gmi:identifier">
                                            <xsl:element name="gmd:MD_Identifier">
                                                <xsl:element name="gmd:code">
                                                    <xsl:element name="gmx:Anchor">
                                                         <xsl:attribute name="xlink:href">
                                                             <xsl:value-of select="mmd:platform/mmd:instrument/mmd:resource" />
                                                         </xsl:attribute>
	            		                         <xsl:value-of select="mmd:platform/mmd:instrument/mmd:short_name" />
                                                    </xsl:element>
                                                </xsl:element>
                                            </xsl:element>
                                        </xsl:element>
                                        <xsl:element name="gmi:type">
                                            <xsl:element name="gco:CharacterString">
	            		                <xsl:value-of select="mmd:platform/mmd:instrument/mmd:long_name" />
                                            </xsl:element>
                                        </xsl:element>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:if>

	    <!--gmi content info-->
	    <xsl:if test="mmd:platform/mmd:ancillary/mmd:cloud_coverage != ''">
                <xsl:element name="gmd:contentInfo">
                    <xsl:element name="gmd:MD_ImageDescription">
                        <xsl:element name="gmd:cloudCoverPercentage">
                            <xsl:element name="gco:Real">
	            	    <xsl:value-of select="mmd:platform/mmd:ancillary/mmd:cloud_coverage" />
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            
            <xsl:element name="gmd:distributionInfo">
                <xsl:element name="gmd:MD_Distribution">
                        <xsl:element name="gmd:distributor">
                            <xsl:apply-templates select="mmd:data_center" />
                        </xsl:element>
                    <xsl:element name="gmd:transferOptions">
                        <xsl:element name="gmd:MD_DigitalTransferOptions">
                            <xsl:apply-templates select="mmd:data_access" />
                        </xsl:element>
                    </xsl:element>
                    <xsl:apply-templates select="mmd:storage_information" />
                </xsl:element>
            </xsl:element>
                
            
            <!--            
            
            <xsl:apply-templates select="mmd:keywords" />
            <xsl:apply-templates select="mmd:project" />
            <xsl:apply-templates select="mmd:instrument" />
            <xsl:apply-templates select="mmd:platform" />
            
             -->

        </xsl:element>
    </xsl:template>

    <xsl:template match="mmd:metadata_identifier">
        <xsl:element name="gmd:fileIdentifier">
            <xsl:element name="gco:CharacterString">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mmd:title">
        
        <xsl:element name="gmd:title">
            <xsl:attribute name="xsi:type">gmd:PT_FreeText_PropertyType</xsl:attribute>
            <xsl:element name="gco:CharacterString">
                <xsl:value-of select="." />
            </xsl:element>
            <xsl:element name="gmd:PT_FreeText">
                <xsl:element name="gmd:textGroup">
                    <xsl:element name="gmd:LocalisedCharacterString">
                        <xsl:attribute name="locale">#locale-nob</xsl:attribute>
                        <xsl:value-of select="../mmd:title[@xml:lang = 'no']" />
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>    
        
    </xsl:template>

    <xsl:template match="mmd:abstract">
    
        <xsl:element name="gmd:abstract">
            <xsl:attribute name="xsi:type">gmd:PT_FreeText_PropertyType</xsl:attribute>
            <xsl:element name="gco:CharacterString">
                <xsl:value-of select="." />
            </xsl:element>
            <xsl:element name="gmd:PT_FreeText">
                <xsl:element name="gmd:textGroup">
                    <xsl:element name="gmd:LocalisedCharacterString">
                        <xsl:attribute name="locale">#locale-nob</xsl:attribute>
                        <xsl:value-of select="../mmd:abstract[@xml:lang = 'no']" />
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
          
    </xsl:template>

    <xsl:template match="mmd:last_metadata_update">
	<xsl:if test="mmd:update/mmd:type = 'Created'">    
        <xsl:element name="gmd:date">
            <xsl:element name="gmd:CI_Date">
                <xsl:element name="gmd:date">
                    <xsl:element name="gco:DateTime">
		        <xsl:value-of select="mmd:update/mmd:datetime"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="gmd:dateType">
                    <xsl:element name="gmd:CI_DateTypeCode">
		    <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode</xsl:attribute>
                        <xsl:attribute name="codeListValue">creation</xsl:attribute>
                        <xsl:text>creation</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
        </xsl:if>    

        <xsl:element name="gmd:date">
            <xsl:element name="gmd:CI_Date">
                <xsl:element name="gmd:date">
                    <xsl:element name="gco:DateTime">
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
                <xsl:element name="gmd:dateType">
                    <xsl:element name="gmd:CI_DateTypeCode">
                        <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode</xsl:attribute>
                        <xsl:attribute name="codeListValue">revision</xsl:attribute>
                        <xsl:text>revision</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mmd:keywords">
       <xsl:element name="gmd:descriptiveKeywords">
        <xsl:element name="gmd:MD_Keywords">
        <xsl:for-each select="mmd:keyword">
           <xsl:element name="gmd:keyword">
              <xsl:element name="gco:CharacterString">
                 <xsl:value-of select="." />
	      </xsl:element>
	   </xsl:element>
        </xsl:for-each>
        <xsl:if test="@vocabulary = 'GCMDSK' or @vocabulary = 'GEMET' or @vocabulary = 'NORTHEMES'  or @vocabulary = 'WMOCAT' ">
	    <xsl:element name="gmd:type">
	        <xsl:element name="gmd:MD_KeywordTypeCode">
		    <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode</xsl:attribute>
		    <xsl:attribute name="codeListValue">theme</xsl:attribute>
		    <xsl:text>theme</xsl:text>
	        </xsl:element>
	    </xsl:element>
	</xsl:if>
        <xsl:if test="@vocabulary = 'GCMDLOC'">
	    <xsl:element name="gmd:type">
	        <xsl:element name="gmd:MD_KeywordTypeCode">
		    <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode</xsl:attribute>
		    <xsl:attribute name="codeListValue">place</xsl:attribute>
		    <xsl:text>place</xsl:text>
	        </xsl:element>
	    </xsl:element>
	</xsl:if>
        <xsl:if test="@vocabulary = 'GCMDPROV'">
	    <xsl:element name="gmd:type">
	        <xsl:element name="gmd:MD_KeywordTypeCode">
		    <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode</xsl:attribute>
		    <xsl:attribute name="codeListValue">dataCentre</xsl:attribute>
		    <xsl:text>dataCentre</xsl:text>
	        </xsl:element>
	    </xsl:element>
	</xsl:if>
	<xsl:element name="gmd:thesaurusName">
	    <xsl:element name="gmd:CI_Citation">
                <xsl:choose>
		    <xsl:when test="@vocabulary = 'GCMD' or @vocabulary= 'GCMDSK' or @vocabulary= 'gcmd' or contains(@vocabulary, 'Global Change Master Directory')">
	                <xsl:element name="gmd:title">
                            <xsl:element name="gmx:Anchor">
	                        <xsl:attribute name="xlink:href">
			            <xsl:text>https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/sciencekeywords</xsl:text>
	                        </xsl:attribute>
			        <xsl:text>NASA/GCMD Earth Science Keywords</xsl:text>
        	            </xsl:element>
	                </xsl:element>	
		        <xsl:element name="gmd:date">
	 	            <xsl:element name="gmd:CI_Date">
     		                <xsl:element name="gmd:date">
		                    <gco:Date>2021-02-12</gco:Date>
                                </xsl:element>	
		                <xsl:element name="gmd:dateType">
		                    <xsl:element name="gmd:CI_DateTypeCode">
		                        <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode</xsl:attribute> 
		                        <xsl:attribute name="codeListValue">publication</xsl:attribute>
                                        <xsl:text>publication</xsl:text>
                                    </xsl:element>	
                                </xsl:element>	
                          </xsl:element>	
                        </xsl:element>	
                    </xsl:when>
                    <xsl:when test="@vocabulary = 'GCMDLOC'">
	                <xsl:element name="gmd:title">
                            <xsl:element name="gmx:Anchor">
	                        <xsl:attribute name="xlink:href">
			            <xsl:text>https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/locations</xsl:text>
	                        </xsl:attribute>
			        <xsl:text>NASA/GCMD Locations</xsl:text>
        	            </xsl:element>
	                </xsl:element>	
		        <xsl:element name="gmd:date">
	 	            <xsl:element name="gmd:CI_Date">
     		                <xsl:element name="gmd:date">
		                    <gco:Date>2021-02-01</gco:Date>
                                </xsl:element>	
		                <xsl:element name="gmd:dateType">
		                    <xsl:element name="gmd:CI_DateTypeCode">
		                        <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode</xsl:attribute> 
		                        <xsl:attribute name="codeListValue">publication</xsl:attribute>
                                        <xsl:text>publication</xsl:text>
                                    </xsl:element>	
                                </xsl:element>	
                          </xsl:element>	
                        </xsl:element>	
                    </xsl:when>
                    <xsl:when test="@vocabulary = 'GCMDPROV'">
	                <xsl:element name="gmd:title">
                            <xsl:element name="gmx:Anchor">
	                        <xsl:attribute name="xlink:href">
			            <xsl:text>https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/providers</xsl:text>
	                        </xsl:attribute>
			        <xsl:text>NASA/GCMD Providers</xsl:text>
        	            </xsl:element>
	                </xsl:element>	
		        <xsl:element name="gmd:date">
	 	            <xsl:element name="gmd:CI_Date">
     		                <xsl:element name="gmd:date">
		                    <gco:Date>2021-04-26</gco:Date>
                                </xsl:element>	
		                <xsl:element name="gmd:dateType">
		                    <xsl:element name="gmd:CI_DateTypeCode">
		                        <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode</xsl:attribute> 
		                        <xsl:attribute name="codeListValue">publication</xsl:attribute>
                                        <xsl:text>publication</xsl:text>
                                    </xsl:element>	
                                </xsl:element>	
                          </xsl:element>	
                        </xsl:element>	
                    </xsl:when>
                    <xsl:when test="@vocabulary = 'GEMET'">
		        <xsl:element name="gmd:title">
                            <xsl:element name="gmx:Anchor">
	                        <xsl:attribute name="xlink:href">
			            <xsl:text>http://inspire.ec.europa.eu/theme</xsl:text>
	                        </xsl:attribute>
		                <xsl:text>GEMET - INSPIRE themes, version 1.0</xsl:text>
                            </xsl:element>
	                </xsl:element>	
		        <xsl:element name="gmd:date">
	 	            <xsl:element name="gmd:CI_Date">
     		                <xsl:element name="gmd:date">
		                    <gco:Date>2008-06-01</gco:Date>
                                </xsl:element>	
		                <xsl:element name="gmd:dateType">
		                    <xsl:element name="gmd:CI_DateTypeCode">
		                        <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode</xsl:attribute> 
		                        <xsl:attribute name="codeListValue">publication</xsl:attribute>
                                        <xsl:text>publication</xsl:text>
                                    </xsl:element>	
                                </xsl:element>	
                          </xsl:element>	
                        </xsl:element>	
                    </xsl:when>
		    <xsl:when test="@vocabulary = 'CF' or @vocabulary = 'CFSTDN' or @vocabulary = 'cf' or contains(@vocabulary, 'Climate and Forecast')">
		        <xsl:element name="gmd:title">
                            <xsl:element name="gmx:Anchor">
	                        <xsl:attribute name="xlink:href">
			            <xsl:text>https://vocab.nerc.ac.uk/standard_name/</xsl:text>
	                        </xsl:attribute>
		                <xsl:text>CF Standard Names</xsl:text>
                            </xsl:element>
	                </xsl:element>	
		        <xsl:element name="gmd:date">
	 	            <xsl:element name="gmd:CI_Date">
     		                <xsl:element name="gmd:date">
	                            <xsl:attribute name="gco:nilReason">unknown</xsl:attribute>
                                </xsl:element>	
		                <xsl:element name="gmd:dateType">
		                    <xsl:element name="gmd:CI_DateTypeCode">
		                        <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode</xsl:attribute> 
		                        <xsl:attribute name="codeListValue">publication</xsl:attribute>
                                        <xsl:text>publication</xsl:text>
                                    </xsl:element>	
                                </xsl:element>	
                          </xsl:element>	
                        </xsl:element>	
                    </xsl:when>
                    <xsl:when test="@vocabulary = 'NORTHEMES'">
		        <xsl:element name="gmd:title">
                            <xsl:element name="gmx:Anchor">
	                        <xsl:attribute name="xlink:href">
			            <xsl:text>https://register.geonorge.no/metadata-kodelister/nasjonal-temainndeling</xsl:text>
	                        </xsl:attribute>
		                <xsl:text>Norwegian thematic categories</xsl:text>
                            </xsl:element>
	                </xsl:element>	
		        <xsl:element name="gmd:date">
	 	            <xsl:element name="gmd:CI_Date">
     		                <xsl:element name="gmd:date">
		                    <gco:Date>2014-10-28</gco:Date>
                                </xsl:element>	
		                <xsl:element name="gmd:dateType">
		                    <xsl:element name="gmd:CI_DateTypeCode">
		                        <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode</xsl:attribute> 
		                        <xsl:attribute name="codeListValue">publication</xsl:attribute>
                                        <xsl:text>publication</xsl:text>
                                    </xsl:element>	
                                </xsl:element>	
                          </xsl:element>	
                        </xsl:element>	
                    </xsl:when>
                    <xsl:when test="@vocabulary = 'WMOCAT'">
		        <xsl:element name="gmd:title">
                            <xsl:element name="gmx:Anchor">
	                        <xsl:attribute name="xlink:href">
			            <xsl:text>http://wis.wmo.int/2012/codelists/WMOCodeLists.xml#WMO_CategoryCode</xsl:text>
	                        </xsl:attribute>
		                <xsl:text>WMO_CategoryCode</xsl:text>
                            </xsl:element>
	                </xsl:element>	
		        <xsl:element name="gmd:date">
	 	            <xsl:element name="gmd:CI_Date">
     		                <xsl:element name="gmd:date">
		                    <gco:Date>2008-06-01</gco:Date>
                                </xsl:element>	
		                <xsl:element name="gmd:dateType">
		                    <xsl:element name="gmd:CI_DateTypeCode">
		                        <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode</xsl:attribute> 
		                        <xsl:attribute name="codeListValue">publication</xsl:attribute>
                                        <xsl:text>publication</xsl:text>
                                    </xsl:element>	
                                </xsl:element>	
                          </xsl:element>	
                        </xsl:element>	
                    </xsl:when>
                    <xsl:otherwise>
	                <xsl:element name="gmd:title">
                            <xsl:element name="gco:CharacterString">
                                <xsl:value-of select="@vocabulary" />
        	            </xsl:element>
	                </xsl:element>	
		        <xsl:element name="gmd:date">
	 	            <xsl:element name="gmd:CI_Date">
     		                <xsl:element name="gmd:date">
	                            <xsl:attribute name="gco:nilReason">unknown</xsl:attribute>
                                </xsl:element>	
		                <xsl:element name="gmd:dateType">
		                    <xsl:element name="gmd:CI_DateTypeCode">
		                        <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode</xsl:attribute> 
		                        <xsl:attribute name="codeListValue">publication</xsl:attribute>
                                        <xsl:text>publication</xsl:text>
                                    </xsl:element>	
                                </xsl:element>	
                          </xsl:element>	
                        </xsl:element>	
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>	
        </xsl:element>	
        </xsl:element>                    
       </xsl:element>
    </xsl:template>

    <xsl:template match="mmd:related_information">
       <xsl:element name="gmd:dataSetURI">
           <xsl:element name="gco:CharacterString">
              <xsl:value-of select="mmd:resource" />
	   </xsl:element>
       </xsl:element>
    </xsl:template>

    <xsl:template match="mmd:temporal_extent">
    
        <xsl:element name="gmd:temporalElement">
            <xsl:element name="gmd:EX_TemporalExtent">
                <xsl:element name="gmd:extent">
                    <xsl:element name="gml:TimePeriod">
                        <xsl:attribute name="gml:id">
			    <!--Should be revided-->
			    <xsl:text>Temporal</xsl:text>
                        </xsl:attribute>
                        <xsl:element name="gml:beginPosition">
                            <xsl:value-of select="mmd:start_date" />
                        </xsl:element>
			<xsl:choose>
			    <xsl:when test="string-length(mmd:end_date) > 0">
                                <xsl:element name="gml:endPosition">
                                    <xsl:value-of select="mmd:end_date" />
                                </xsl:element>
		            </xsl:when>
			    <xsl:otherwise>
                                <xsl:element name="gml:endPosition">
			            <xsl:attribute name="indeterminatePosition">
					<xsl:text>now</xsl:text>
				    </xsl:attribute>
                                </xsl:element>
		             </xsl:otherwise>
		        </xsl:choose>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mmd:geographic_extent/mmd:rectangle">
    
        <xsl:element name="gmd:geographicElement">
            <xsl:element name="gmd:EX_GeographicBoundingBox">
                <xsl:element name="gmd:westBoundLongitude">
                     <xsl:element name="gco:Decimal">
                        <xsl:value-of select="mmd:west" />
                    </xsl:element>
                </xsl:element>
                <xsl:element name="gmd:eastBoundLongitude">
                    <xsl:element name="gco:Decimal">
                        <xsl:value-of select="mmd:east" />
                    </xsl:element>
                </xsl:element>
                <xsl:element name="gmd:southBoundLatitude">
                    <xsl:element name="gco:Decimal">
                        <xsl:value-of select="mmd:south" />
                    </xsl:element>
                </xsl:element>
                <xsl:element name="gmd:northBoundLatitude">
                    <xsl:element name="gco:Decimal">
                        <xsl:value-of select="mmd:north" />
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>                

    </xsl:template>
    
    <xsl:template match="mmd:geographic_extent/mmd:polygon">
    
        <xsl:element name="gmd:geographicElement">
            <xsl:element name="gmd:EX_BoundingPolygon">
                <xsl:element name="gmd:polygon">
                    <xsl:copy-of select="gml:Polygon" />
                </xsl:element>
            </xsl:element>
        </xsl:element>                

    </xsl:template>    

    <xsl:template match="mmd:data_center">
	<xsl:element name="gmd:MD_Distributor">
	   <xsl:element name="gmd:distributorContact">
	      <xsl:element name="gmd:CI_ResponsibleParty">
	         <xsl:element name="gmd:organisationName">
	            <xsl:element name="gco:CharacterString">
		       <xsl:choose>
			  <xsl:when test="mmd:data_center_name/mmd:long_name != ''">
	                      <xsl:value-of select="concat(mmd:data_center_name/mmd:short_name, ' &gt; ', mmd:data_center_name/mmd:long_name)" />
	                  </xsl:when>
	                  <xsl:otherwise>
	                      <xsl:value-of select="mmd:data_center_name/mmd:short_name" />
	                  </xsl:otherwise>
	               </xsl:choose>
                    </xsl:element>
                 </xsl:element>
	         <xsl:element name="gmd:contactInfo">
	            <xsl:element name="gmd:CI_Contact">
                      <xsl:element name="gmd:address">
                          <xsl:element name="gmd:CI_Address">
                              <xsl:element name="gmd:electronicMailAddress">
                                  <xsl:element name="gco:CharacterString">
					  <xsl:value-of select="../mmd:personnel[mmd:role = 'Data center contact']/mmd:email" />
                                  </xsl:element>
                              </xsl:element>
                          </xsl:element>
                      </xsl:element>
	               <xsl:element name="gmd:onlineResource">
	                  <xsl:element name="gmd:CI_OnlineResource">
	                     <xsl:element name="gmd:linkage">
	                        <xsl:element name="gmd:URL">
	                           <xsl:value-of select="mmd:data_center_url" />
                                </xsl:element>
                             </xsl:element>
                          </xsl:element>
                       </xsl:element>
                    </xsl:element>
                 </xsl:element>
                 <xsl:element name="gmd:role">
                     <xsl:element name="gmd:CI_RoleCode">
                         <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode</xsl:attribute>
                             <xsl:attribute name="codeListValue">
                                 <xsl:text>distributor</xsl:text>
                             </xsl:attribute>
                         <xsl:text>distributor</xsl:text>
                     </xsl:element>             
                 </xsl:element>
              </xsl:element>
           </xsl:element>
        </xsl:element>
    </xsl:template>
	    
    <xsl:template match="mmd:data_access">
    
        <xsl:element name="gmd:onLine">
            <xsl:element name="gmd:CI_OnlineResource">
                <xsl:element name="gmd:linkage">
                    <xsl:element name="gmd:URL">
                        <xsl:variable name="myprot" select="normalize-space(./mmd:type)" />
                        <xsl:choose>
                            <xsl:when test="contains($myprot,'OGC WMS')">
                                <xsl:variable name="myurl" select="normalize-space(./mmd:resource)" />
                                <xsl:choose>
                                    <xsl:when test="contains($myurl,'?SERVICE=WMS&amp;REQUEST=GetCapabilities')">
                                        <xsl:value-of select="mmd:resource" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat($myurl,'?SERVICE=WMS&amp;REQUEST=GetCapabilities')" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="mmd:resource" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="gmd:protocol">
                    <xsl:element name="gco:CharacterString">
                        <!--xsl:value-of select="mmd:type" / -->
                        <xsl:variable name="mmd_da_type" select="normalize-space(./mmd:type)" />
                        <xsl:variable name="mmd_da_mapping" select="document('')/*/mapping:data_access_type_osgeo[@mmd=$mmd_da_type]/@iso" />
                        <xsl:value-of select="$mmd_da_mapping" />
                    </xsl:element>
                </xsl:element>            
                <!--xsl:element name="gmd:applicationProfile">
                    <xsl:element name="gco:CharacterString">
			<xsl:text>OSGEO</xsl:text>
                    </xsl:element>
                </xsl:element-->                
                <xsl:element name="gmd:name">
                    <xsl:element name="gco:CharacterString">
                        <xsl:value-of select="mmd:name" />
                    </xsl:element>
                </xsl:element>
                <xsl:element name="gmd:description">
                    <xsl:element name="gco:CharacterString">
                        <xsl:value-of select="mmd:description" />
                    </xsl:element>
                </xsl:element>                
            </xsl:element>
        </xsl:element>
        
    </xsl:template>
    
    
    <xsl:template match="mmd:personnel">
    
        <xsl:element name="gmd:CI_ResponsibleParty">
            <xsl:element name="gmd:individualName">
                <xsl:element name="gco:CharacterString">
                    <xsl:value-of select="mmd:name" />
                </xsl:element>
            </xsl:element>
            
            <xsl:element name="gmd:organisationName">
                <xsl:element name="gco:CharacterString">
                    <xsl:value-of select="mmd:organisation" />
                </xsl:element>
            </xsl:element>            
            
            <xsl:element name="gmd:contactInfo">
                <xsl:element name="gmd:CI_Contact">
                    <xsl:element name="gmd:phone">
                        <xsl:element name="gmd:CI_Telephone">
                            <xsl:element name="gmd:voice">
                                <xsl:element name="gco:CharacterString">
                                    <xsl:value-of select="mmd:phone" />
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="gmd:address">
                        <xsl:element name="gmd:CI_Address">
                            <xsl:element name="gmd:deliveryPoint">
                                <xsl:element name="gco:CharacterString">
                                    <xsl:value-of select="mmd:contact_address/mmd:address" />
                                </xsl:element>
                            </xsl:element>
                            <xsl:element name="gmd:city">
                                <xsl:element name="gco:CharacterString">
                                    <xsl:value-of select="mmd:contact_address/mmd:city" />
                                </xsl:element>
                            </xsl:element>
                            <xsl:element name="gmd:postalCode">
                                <xsl:element name="gco:CharacterString">
                                    <xsl:value-of select="mmd:contact_address/mmd:postal_code" />
                                </xsl:element>
                            </xsl:element>
                            <xsl:element name="gmd:country">
                                <xsl:element name="gco:CharacterString">
                                    <xsl:value-of select="mmd:contact_address/mmd:country" />
                                </xsl:element>
                            </xsl:element>
                            <xsl:element name="gmd:electronicMailAddress">
                                <xsl:element name="gco:CharacterString">
                                    <xsl:value-of select="mmd:email" />
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            
            
            <xsl:element name="gmd:role">
                <xsl:element name="gmd:CI_RoleCode">
                    <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode</xsl:attribute>
		        <!--mapping should be revised-->
                        <xsl:choose>
                            <xsl:when test="mmd:role = 'Investigator'">
                                <xsl:attribute name="codeListValue">
                                    <xsl:text>principalInvestigator</xsl:text>
                                </xsl:attribute>
                                <xsl:text>principalInvestigator</xsl:text>
                            </xsl:when>
                            <xsl:when test="mmd:role = 'Technical contact'">
                                <xsl:attribute name="codeListValue">
                                    <xsl:text>pointOfContact</xsl:text>
                                </xsl:attribute>
                                <xsl:text>pointOfContact</xsl:text>
                            </xsl:when>
                            <xsl:when test="mmd:role = 'Metadata author'">
                                <xsl:attribute name="codeListValue">
                                    <xsl:text>author</xsl:text>
                                </xsl:attribute>
                                <xsl:text>author</xsl:text>
                            </xsl:when>
                            <xsl:when test="mmd:role = 'Data center contact'">
                                <xsl:attribute name="codeListValue">
                                    <xsl:text>distributor</xsl:text>
                                </xsl:attribute>
                                <xsl:text>distributor</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="codeListValue">
                                    <xsl:text>pointOfContact</xsl:text>
                                </xsl:attribute>
                                <xsl:text>pointOfContact</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                </xsl:element>             
            </xsl:element>
        </xsl:element>
    
    </xsl:template>

    <xsl:template match="mmd:dataset_production_status">

        <xsl:element name="gmd:status">
            <xsl:variable name="mmd_status" select="normalize-space(.)" />
            <xsl:variable name="mmd_status_mapping" select="document('')/*/mapping:dataset_status[@mmd=$mmd_status]/@iso" />
	    <xsl:element name="gmd:MD_ProgressCode">
	        <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_ProgressCode</xsl:attribute>
	        <xsl:attribute name="codeListValue">
                    <xsl:value-of select="$mmd_status_mapping" />
	        </xsl:attribute>
                <xsl:value-of select="$mmd_status_mapping" />
	    </xsl:element>
        </xsl:element>

    </xsl:template>

    <xsl:template match="mmd:storage_information">
        <xsl:element name="gmd:distributionFormat">
            <xsl:element name="gmd:MD_Format">
                <xsl:element name="gmd:name">
                    <xsl:element name="gco:CharacterString">
                        <xsl:value-of select="mmd:file_format" />
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mmd:iso_topic_category">
        <xsl:element name="gmd:topicCategory">
            <xsl:element name="gmd:MD_TopicCategoryCode">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Mappings for thesaurs -->
    <mapping:vocabulary iso="Global Change Master Directory (GCMD)" mmd="gcmd" />
    <mapping:vocabulary iso="Global Change Master Directory (GCMD)" mmd="GCMD" />
    <mapping:vocabulary iso="Climate and Forecast (CF) Standard Name Table" mmd="CF" />
    <mapping:vocabulary iso="Climate and Forecast (CF) Standard Name Table" mmd="cf" />

    <!-- Mappings for dataset_production_status -->
    <mapping:dataset_status iso="completed" mmd="Complete" />
    <mapping:dataset_status iso="obsolete" mmd="Obsolete" />
    <mapping:dataset_status iso="onGoing" mmd="In Work" />
    <mapping:dataset_status iso="planned" mmd="Planned" />    

    <!-- Mappings for data_access type specification to OSGEO  -->
    <mapping:data_access_type_osgeo iso="OGC:WMS" mmd="OGC WMS" />    
    <mapping:data_access_type_osgeo iso="OGC:WCS" mmd="OGC WCS" />    
    <mapping:data_access_type_osgeo iso="OGC:WFS" mmd="OGC WFS" />    
    <mapping:data_access_type_osgeo iso="ftp" mmd="FTP" />
    <mapping:data_access_type_osgeo iso="download" mmd="HTTP" />
    <mapping:data_access_type_osgeo iso="OPeNDAP:OPeNDAP" mmd="OPeNDAP" />

    <!-- Mappings for data_access type specification to geonetwork  -->
    <mapping:data_access_type_geonetwork iso="OGC:WMS" mmd="OGC WMS" />    
    <mapping:data_access_type_geonetwork iso="OGC:WCS" mmd="OGC WCS" />    
    <mapping:data_access_type_geonetwork iso="OGC:WFS" mmd="OGC WFS" />    
    <mapping:data_access_type_geonetwork iso="WWW:DOWNLOAD-1.0-ftp--download" mmd="FTP" />
    <mapping:data_access_type_geonetwork iso="WWW:DOWNLOAD-1.0-http--download" mmd="HTTP" />
    <mapping:data_access_type_geonetwork iso="WWW:LINK-1.0-http--opendap" mmd="OPeNDAP" />

    <mapping:language_code iso="eng" mmd="en" />

</xsl:stylesheet>
