<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet 
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.isotc211.org/2005/gmd http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd http://www.isotc211.org/2005/gmx http://schemas.opengis.net/iso/19139/20060504/gmx/gmx.xsd"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mmd="http://www.met.no/schema/mmd"
    xmlns:mapping="http://www.met.no/schema/mmd/iso2mmd"      
    version="1.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes" />

    <xsl:template match="/mmd:mmd">
        <xsl:element name="gmd:MD_Metadata">

	    <!--metadata identfier. INSPIRE: Mandatory for dataset and dataset series. multiplicity [1..*]-->
            <xsl:apply-templates select="mmd:metadata_identifier" />

            <gmd:language>
		    <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/" codeListValue="eng"/>
            </gmd:language>
            <!--gmd:locale>
                <gmd:PT_Locale id="locale-nob">
                    <gmd:languageCode>
                        <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2" codeListValue="nob">Norwegian</gmd:LanguageCode>
                    </gmd:languageCode>
                    <gmd:characterEncoding>
                        <gmd:MD_CharacterSetCode
                            codeList="resources/Codelist/gmxcodelists.xml#MD_CharacterSetCode"
                            codeListValue="utf8"/>
                    </gmd:characterEncoding>
                </gmd:PT_Locale>
            </gmd:locale-->            

            <!--resource type is mandatory, multiplicity [1]-->
            <gmd:hierarchyLevel>
		    <gmd:MD_ScopeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_ScopeCode" codeListValue="dataset"/>
            </gmd:hierarchyLevel>
            
            <!--Conditional for spatial dataset and spatial dataset series: Mandatory if the resource includes textual information. [0..*] for datasets and series-->		
            <gmd:characterSet>
		    <gmd:MD_CharacterSetCode codeListValue="utf8" codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_CharacterSetCode"/>
            </gmd:characterSet>
        
            <!--Party responsible for the metadata information (M) multiplicity [1..*] -->
            <xsl:element name="gmd:contact">
	        <xsl:apply-templates select="mmd:personnel[mmd:role = 'Metadata author']" />
            </xsl:element>

           <xsl:element name="gmd:dateStamp">
               <xsl:element name="gco:Date">
	           <xsl:variable name="latest">
		       <xsl:for-each select="mmd:last_metadata_update/mmd:update/mmd:datetime">
                           <xsl:sort select="." order="descending" />
                           <xsl:if test="position() = 1">
                               <xsl:value-of select="."/>
                           </xsl:if>
                       </xsl:for-each>
                   </xsl:variable>
                   <xsl:value-of select="substring-before($latest,'T')"/>
               </xsl:element>
           </xsl:element>

           <gmd:metadataStandardName>
               <gco:CharacterString>ISO 19115:2003/19139</gco:CharacterString>
           </gmd:metadataStandardName>
           <gmd:metadataStandardVersion>
               <gco:CharacterString>1.0</gco:CharacterString>
           </gmd:metadataStandardVersion>

	   <xsl:element name="gmd:referenceSystemInfo">
               <xsl:element name="gmd:MD_ReferenceSystem">
                   <xsl:element name="gmd:referenceSystemIdentifier">
                       <xsl:element name="gmd:RS_Identifier">
                           <xsl:element name="gmd:code">
			       <xsl:element name="gco:CharacterString">
			           <xsl:value-of select="mmd:geographic_extent/mmd:rectangle/@srsName"/>
                               </xsl:element>
		           </xsl:element>
		       </xsl:element>
		  </xsl:element>
              </xsl:element>
            </xsl:element>

            <xsl:element name="gmd:identificationInfo">
                <xsl:element name="gmd:MD_DataIdentification">
                
                    <xsl:element name="gmd:citation">
                        <xsl:element name="gmd:CI_Citation">
	                <!--title (M) multiplicity [1]-->
                        <xsl:apply-templates select="mmd:title[@xml:lang = 'en']" />
                        <xsl:apply-templates select="mmd:dataset_citation/mmd:publication_date" />
                        <xsl:apply-templates select="mmd:last_metadata_update" />
			<!--it should be the DOI, or a URL. Identifier for now-->
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

		    <!--abstract (M) multiplicity [1] -->
                    <xsl:apply-templates select="mmd:abstract[@xml:lang = 'en']" />
		    <!--personnel (M) multiplicity [1] Relative to a responsible organisation, but there may be many responsible organisations for a single resource-->
                    <xsl:element name="gmd:pointOfContact">
		        <xsl:apply-templates select="mmd:personnel[mmd:role != 'Metadata author']" />
                    </xsl:element>
		    <!--keywords (M) multiplicity [1..*] -->
                    <xsl:apply-templates select="mmd:keywords" />

	     	    <!--access_constraint Conditional: referring to limitations on public access. Mandatory if accessConstraints or classification are not documented, multiplicity [0..*] for otherConstraints per instance of MD_LegalConstraints-->	
                    <xsl:element name="gmd:resourceConstraints">
                        <xsl:element name="gmd:MD_LegalConstraints">
                    
                            <xsl:element name="gmd:accessConstraints">
                                <xsl:element name="gmd:MD_RestrictionCode">
                                    <xsl:attribute name="codeList">ttp://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/gmxCodelists.xml#MD_RestrictionCode</xsl:attribute>
                                    <xsl:attribute name="codeListValue">otherRestrictions</xsl:attribute>
                                    <xsl:text>otherRestrictions</xsl:text>
                                </xsl:element>
                            </xsl:element>
                    
                            <xsl:element name="gmd:otherConstraints">
                                <xsl:choose>
                                <xsl:when test="mmd:access_constraint !=''">		     
                        	    <xsl:choose>
                                        <xsl:when test="mmd:access_constraint = 'Open'">		     
                                            <xsl:element name="gmx:Anchor">
                                                <xsl:attribute name="xlink:href">
                        	        	    <xsl:text>http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations</xsl:text>
                                                </xsl:attribute>
                        	                <xsl:text>Open data</xsl:text>
                                           </xsl:element>
                        	        </xsl:when>
                        	        <xsl:otherwise>
                                            <xsl:element name="gco:CharacterString">
                                                <xsl:value-of select="mmd:access_constraint" />
                                            </xsl:element>
                        	        </xsl:otherwise>
                    	            </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:element name="gco:CharacterString">
                                        <xsl:text>conditionsUnknown</xsl:text>
                                    </xsl:element>
                                </xsl:otherwise>
                                </xsl:choose>
                            </xsl:element>
                    
                        </xsl:element>
                    </xsl:element>

		    <!--use_constraints (M) multiplicity [1..*] -->
                    <xsl:apply-templates select="mmd:use_constraint" />

		    <xsl:element name="gmd:spatialRepresentationType">
		        <xsl:element name="gmd:MD_SpatialRepresentationTypeCode">
			    <xsl:attribute name="codeList">http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_SpatialRepresentationTypeCode</xsl:attribute>
			    <xsl:attribute name="codeListValue">
                                <xsl:value-of select="mmd:spatial_representation" />
			    </xsl:attribute>
                                <xsl:value-of select="mmd:spatial_representation" />
		        </xsl:element>
		    </xsl:element>

		    <xsl:element name="gmd:language">
		        <xsl:element name="gmd:LanguageCode">
		        <xsl:attribute name="codeList">http://www.loc.gov/standards/iso639-2/</xsl:attribute> 
			    <xsl:attribute name="codeListValue">

                            <xsl:variable name="language" select="mmd:dataset_language" />
                            <xsl:variable name="language_mapping" select="document('')/*/mapping:language_code[@mmd=$language]/@inspire" />
                            <xsl:value-of select="$language_mapping" />

			    </xsl:attribute>
        	        </xsl:element>	
        	    </xsl:element>	

		    <!--iso_topic_category (M) multiplicity [1..*]-->
                    <xsl:apply-templates select="mmd:iso_topic_category" />

                    <xsl:element name="gmd:extent">
                        <xsl:element name="gmd:EX_Extent">
		           <!--geographical extent (M) multiplicity [1..*] -->
                            <xsl:apply-templates select="mmd:geographic_extent/mmd:rectangle" />
                            <xsl:apply-templates select="mmd:geographic_extent/mmd:polygon" />
			    <!--temporal extent Conditional: At least one temporal reference is required 
				 multiplicity [0..*] -->
			    <xsl:apply-templates select="mmd:temporal_extent"/>
                        </xsl:element>                    
                    </xsl:element>

                </xsl:element>

            </xsl:element>        

            <xsl:element name="gmd:distributionInfo">
                <xsl:element name="gmd:MD_Distribution">

		    <!--format-->
                    <xsl:apply-templates select="mmd:storage_information" />

                    <xsl:element name="gmd:transferOptions">
                        <xsl:element name="gmd:MD_DigitalTransferOptions">
                       	   <!--data_access. INSPIRE: Conditional for spatial dataset and spatial dataset series: Mandatory if a URL is available to obtain more information on the resources and/or access related services. multiplicity [0..*]-->
                            <xsl:apply-templates select="mmd:data_access" />
                        </xsl:element>
		    </xsl:element>

                </xsl:element>
            </xsl:element>


	    <!--Lineage (M) multiplicity [1]-->
            <xsl:element name="gmd:dataQualityInfo">        
 	        <xsl:element name="gmd:DQ_DataQuality">        
 	            <xsl:element name="gmd:scope">        
 	                <xsl:element name="gmd:DQ_Scope">        
 	                    <xsl:element name="gmd:level">        
				<xsl:element name="gmd:MD_ScopeCode"> 
			            <xsl:attribute name="codeListValue">dataset</xsl:attribute>
			            <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/gmxCodelists.xml#MD_ScopeCode</xsl:attribute>
                                </xsl:element>        
                            </xsl:element>        
                        </xsl:element>        
                    </xsl:element>        
 	            <xsl:element name="gmd:report">        
 	                <xsl:element name="gmd:DQ_DomainConsistency">        
 	                    <xsl:element name="gmd:result">        
 	                        <xsl:element name="gmd:DQ_ConformanceResult">        
				    <!--Mandatory [1] understood in the context of a conformity statement when reported in the metadata –   there may be more than one conformity statement-->
 	                            <xsl:element name="gmd:specification">        
	                                 <xsl:element name="gmd:CI_Citation">
	                                     <xsl:element name="gmd:title">
                                                 <xsl:element name="gco:CharacterString">
		                             	     <xsl:text>COMMISSION REGULATION (EU) No 1089/2010 of 23 November 2010 implementing Directive 2007/2/EC of the European Parliament and of the Council as regards interoperability of spatial data sets and services</xsl:text>
                                                 </xsl:element>
	                                     </xsl:element>	
					     <xsl:element name="gmd:date">
		 	 	 	         <xsl:element name="gmd:CI_Date">
     					             <xsl:element name="gmd:date">
					                 <gco:Date>2010-12-08</gco:Date>
        	                                     </xsl:element>	
						     <xsl:element name="gmd:dateType">
						         <xsl:element name="gmd:CI_DateTypeCode">
							 <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode</xsl:attribute> 
						             <xsl:attribute name="codeListValue">publication</xsl:attribute>
                                                             <xsl:text>publication</xsl:text>
        	                                         </xsl:element>	
        	                                     </xsl:element>	
        	                                </xsl:element>	
        	                             </xsl:element>	
        	                         </xsl:element>	
                                    </xsl:element>        
	                            <xsl:element name="gmd:explanation">
                                        <xsl:element name="gco:CharacterString">
		                            <xsl:text>The dataset has not been evaluated against the requirements of Inspire</xsl:text>
                                        </xsl:element>
	                            </xsl:element>	
	                            <xsl:element name="gmd:pass">
				            <xsl:attribute name="gco:nilReason">unknown</xsl:attribute>
	                            </xsl:element>	
                                </xsl:element>        
                            </xsl:element>        
                        </xsl:element>        
                    </xsl:element>        
 	            <xsl:element name="gmd:lineage">        
 	                <xsl:element name="gmd:LI_Lineage">        
 	                    <xsl:element name="gmd:statement">        
 	                        <xsl:element name="gco:CharacterString">No lineage statement has been provided</xsl:element>        
                            </xsl:element>        
                        </xsl:element>        
                    </xsl:element>        
                </xsl:element>        
            </xsl:element>        

            
        </xsl:element>
            
    </xsl:template>

    <!--templates-->
    <!--metadata identifier-->
    <xsl:template match="mmd:metadata_identifier">

        <xsl:element name="gmd:fileIdentifier">
            <xsl:element name="gco:CharacterString">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:element>

    </xsl:template>

    <!--title-->
    <xsl:template match="mmd:title">

        <xsl:element name="gmd:title">
            <xsl:element name="gco:CharacterString">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:element>    

    </xsl:template>

    <!--abstract-->
    <xsl:template match="mmd:abstract">
    
        <xsl:element name="gmd:abstract">
            <xsl:element name="gco:CharacterString">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:element>
          
    </xsl:template>

    <!--data access-->
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
                        <xsl:variable name="mmd_da_type" select="normalize-space(./mmd:type)" />
                        <xsl:variable name="mmd_da_mapping" select="document('')/*/mapping:data_access_type_osgeo[@mmd=$mmd_da_type]/@iso" />
                        <xsl:value-of select="$mmd_da_mapping" />
                    </xsl:element>
                </xsl:element>            
		<!--not mandatory in INSPIRE-->
                <xsl:element name="gmd:name">
                    <xsl:element name="gco:CharacterString">
                        <xsl:value-of select="mmd:name" />
                    </xsl:element>
                </xsl:element>
		<!--not mandatory in INSPIRE-->
                <xsl:element name="gmd:description">
                    <xsl:element name="gco:CharacterString">
                        <xsl:value-of select="mmd:description" />
                    </xsl:element>
                </xsl:element>                
                <xsl:element name="gmd:function">
                    <xsl:element name="gmd:CI_OnLineFunctionCode">
		    <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_OnLineFunctionCode</xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="mmd:type = 'HTTP' or 'OPENDAP'">
                                    <xsl:attribute name="codeListValue">
                                        <xsl:text>download</xsl:text>
                                    </xsl:attribute>
                                    <xsl:text>download</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="codeListValue">
                                        <xsl:text>information</xsl:text>
                                    </xsl:attribute>
                                    <xsl:text>information</xsl:text>
                                </xsl:otherwise>
	              	    </xsl:choose>
                    </xsl:element>                
                </xsl:element>                
            </xsl:element>
        </xsl:element>
        
    </xsl:template>

    <!--format -->
    <xsl:template match="mmd:storage_information">
        <xsl:element name="gmd:distributionFormat">
            <xsl:element name="gmd:MD_Format">
                <xsl:element name="gmd:name">
                    <xsl:element name="gco:CharacterString">
                        <xsl:value-of select="mmd:file_format" />
                    </xsl:element>
                </xsl:element>
                <xsl:element name="gmd:version">
                    <xsl:attribute name="gco:nilReason">unknown</xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!--iso topic category-->
    <xsl:template match="mmd:iso_topic_category">
        <xsl:element name="gmd:topicCategory">
            <xsl:element name="gmd:MD_TopicCategoryCode">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!--keywords
	 required  keyword  from  the  GEMET -  INSPIRE  themes  (for dataset  and  dataset  series) -->
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
	        <xsl:element name="gmd:thesaurusName">
	            <xsl:element name="gmd:CI_Citation">
                        <xsl:choose>
                            <xsl:when test="@vocabulary = 'gcmd' or @vocabulary ='GCMD'">
	                        <xsl:element name="gmd:title">
                                    <xsl:element name="gco:CharacterString">
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
			                        <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode</xsl:attribute> 
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
			                        <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode</xsl:attribute> 
			                        <xsl:attribute name="codeListValue">publication</xsl:attribute>
                                                <xsl:text>publication</xsl:text>
        	                            </xsl:element>	
        	                        </xsl:element>	
        	                  </xsl:element>	
        	                </xsl:element>	
                            </xsl:when>
                            <xsl:when test="@vocabulary = 'Norwegian thematic categories'">
			        <xsl:element name="gmd:title">
                                    <xsl:element name="gmx:Anchor">
	                                <xsl:attribute name="xlink:href">
	    			            <xsl:text>https://register.geonorge.no/subregister/metadata-kodelister/kartverket/nasjonal-temainndeling</xsl:text>
	                                </xsl:attribute>
	        	                <xsl:text>Nasjonal tematisk inndeling (DOK-kategori)</xsl:text>
                                    </xsl:element>
	                        </xsl:element>	
			        <xsl:element name="gmd:date">
		 	            <xsl:element name="gmd:CI_Date">
     			                <xsl:element name="gmd:date">
			                    <gco:Date>2014-10-28</gco:Date>
        	                        </xsl:element>	
			                <xsl:element name="gmd:dateType">
			                    <xsl:element name="gmd:CI_DateTypeCode">
			                        <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode</xsl:attribute> 
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
                            </xsl:otherwise>
                        </xsl:choose>
        	    </xsl:element>	
        	</xsl:element>	
            </xsl:element>                    
        </xsl:element>
    </xsl:template>

    <!--geographical extent-->
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

    <!--temporal extent-->
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
				<xsl:text>unknown</xsl:text>
                            </xsl:element>
		        </xsl:otherwise>
		        </xsl:choose>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>

    </xsl:template>

    <!--publication date-->
    <xsl:template match="mmd:dataset_citation/mmd:publication_date">
    
        <xsl:element name="gmd:date">
            <xsl:element name="gmd:CI_Date">
                <xsl:element name="gmd:date">
                    <xsl:element name="gco:Date">
                        <xsl:value-of select="." />
                    </xsl:element>
                </xsl:element>
                <xsl:element name="gmd:dateType">
                    <xsl:element name="gmd:CI_DateTypeCode">
		    <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode</xsl:attribute>
                        <xsl:attribute name="codeListValue">publication</xsl:attribute>
                        <xsl:text>publication</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>

    </xsl:template>

    <!--creation and/or revision date-->
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
		    <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode</xsl:attribute>
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
                        <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode</xsl:attribute>
                        <xsl:attribute name="codeListValue">revision</xsl:attribute>
                        <xsl:text>revision</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>


    <xsl:template match="mmd:use_constraint">
         <xsl:element name="gmd:resourceConstraints">
             <xsl:element name="gmd:MD_LegalConstraints">
        
                 <xsl:element name="gmd:useConstraints">
                     <xsl:element name="gmd:MD_RestrictionCode">
                         <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/gmxCodelists.xml#MD_RestrictionCode</xsl:attribute>
                         <xsl:attribute name="codeListValue">otherRestrictions</xsl:attribute>
                         <xsl:text>otherRestrictions</xsl:text>
                     </xsl:element>
                 </xsl:element>

                 <xsl:element name="gmd:otherConstraints">
                         <xsl:element name="gmx:Anchor">
                             <xsl:attribute name="xlink:href">
                                 <xsl:value-of select="mmd:resource" />
                             </xsl:attribute>
                                 <xsl:variable name="license" select="mmd:identifier" />
                                 <xsl:variable name="license_mapping" select="document('')/*/mapping:use_constraint[@mmd=$license]/@geon" />
                                 <xsl:value-of select="$license_mapping" />
                                 <xsl:value-of select="mmd:identifier" />
                         </xsl:element>
                 </xsl:element>
        
             </xsl:element>
         </xsl:element>
    </xsl:template>

    <xsl:template match="mmd:personnel">
    
        <xsl:element name="gmd:CI_ResponsibleParty">
            <xsl:element name="gmd:organisationName">
                <xsl:element name="gco:CharacterString">
                    <xsl:value-of select="mmd:organisation" />
                </xsl:element>
            </xsl:element>            
            
            <xsl:element name="gmd:contactInfo">
                <xsl:element name="gmd:CI_Contact">
                    <xsl:element name="gmd:address">
                        <xsl:element name="gmd:CI_Address">
			    <!--[1..*] (characterString)-->	
                            <xsl:element name="gmd:electronicMailAddress">
                                <xsl:element name="gco:CharacterString">
                                    <xsl:value-of select="mmd:email" />
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>

	    <!--Mandatory [1] relative to a responsible organisation, but there may be many responsible organisations for a single resource--> 
            <xsl:element name="gmd:role">
                <xsl:element name="gmd:CI_RoleCode">
                    <xsl:attribute name="codeList">http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/gmxCodelists.xml#CI_RoleCode</xsl:attribute>
		        <!--mapping should be revised-->
                        <xsl:choose>
                            <xsl:when test="mmd:role = 'Principal investigator'">
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
			    <!--The role of the responsible party serving as a metadata point of contact is  out  of  scope  of  the  INSPIRE Metadata  Regulation 1205/2008/EC, but  this  property  is  mandated  by  ISO  19115.  The  default  value  is pointOfContact. See SC15 and-->
                            <xsl:when test="mmd:role = 'Metadata author'">
                                <xsl:attribute name="codeListValue">
                                    <xsl:text>pointOfContact</xsl:text>
                                </xsl:attribute>
                                <xsl:text>pointOfContact</xsl:text>
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

    <!-- Mappings for data_access type specification to OSGEO  -->
    <mapping:data_access_type_osgeo iso="OGC:WMS" mmd="OGC WMS" />    
    <mapping:data_access_type_osgeo iso="OGC:WCS" mmd="OGC WCS" />    
    <mapping:data_access_type_osgeo iso="OGC:WFS" mmd="OGC WFS" />    
    <mapping:data_access_type_osgeo iso="ftp" mmd="FTP" />
    <mapping:data_access_type_osgeo iso="download" mmd="HTTP" />
    <mapping:data_access_type_osgeo iso="OPENDAP:OPENDAP" mmd="OPeNDAP" />

    <mapping:language_code inspire="eng" mmd="en" />    

    <!--Mapping to https://register.geonorge.no/metadata-kodelister/lisenser-->
    <mapping:use_constraint geon="Creative Commons 0" mmd="CC0-1.0" />    
    <mapping:use_constraint geon="Creative Commons BY 4.0 (CC BY 4.0)" mmd="CC-BY-4.0" />    
    <mapping:use_constraint geon="Creative Commons BY-NC 4.0 (CC BY-NC 4.0)" mmd="CC-BY-NC-4.0" />    
</xsl:stylesheet>
