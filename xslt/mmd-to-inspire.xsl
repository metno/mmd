<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet 
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:gml="http://www.opengis.net/gml/3.2"
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
	    <xsl:copy-of select="document('')/xsl:stylesheet/namespace::*[name()!='xsl' and name()!='mapping' and name()!='mmd']"/>
            <xsl:copy-of select="document('')/*/@xsi:schemaLocation"/>

	    <!--metadata identfier. INSPIRE: Mandatory for dataset and dataset series. multiplicity [1..*]-->
            <xsl:apply-templates select="mmd:metadata_identifier" />

            <gmd:language>
		<gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2" codeListValue="eng">English</gmd:LanguageCode>
            </gmd:language>
            <!--Conditional for spatial dataset and spatial dataset series: Mandatory if the resource includes textual information. [0..*] for datasets and series-->		
            <gmd:characterSet>
		    <gmd:MD_CharacterSetCode codeListValue="utf8" codeList="https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode">utf8</gmd:MD_CharacterSetCode>
            </gmd:characterSet>
        
            <!--resource type is mandatory, multiplicity [1]-->
            <gmd:hierarchyLevel>
		    <gmd:MD_ScopeCode codeList="https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_ScopeCode" codeListValue="dataset">dataset</gmd:MD_ScopeCode>
            </gmd:hierarchyLevel>
            
            <!--Party responsible for the metadata information (M) multiplicity [1..*] -->
            <xsl:element name="gmd:contact">
                <xsl:choose>
                <xsl:when test="mmd:personnel[mmd:role = 'Metadata author']">
                    <xsl:apply-templates select="mmd:personnel[mmd:role = 'Metadata author']" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="gmd:CI_ResponsibleParty">
                        <xsl:element name="gmd:individualName">
                            <xsl:element name="gco:CharacterString">
				<xsl:value-of select="mmd:personnel[mmd:role = 'Investigator']/mmd:name" />
                            </xsl:element>
                        </xsl:element>
	                    
                        <xsl:element name="gmd:organisationName">
                            <xsl:element name="gco:CharacterString">
                                <xsl:value-of select="mmd:personnel[mmd:role = 'Investigator']/mmd:organisation" />
                            </xsl:element>
                        </xsl:element>            
                        
                        <xsl:element name="gmd:contactInfo">
                            <xsl:element name="gmd:CI_Contact">
                                <xsl:element name="gmd:address">
                                    <xsl:element name="gmd:CI_Address">
                                        <xsl:element name="gmd:deliveryPoint">
                                            <xsl:element name="gco:CharacterString">
                                                <xsl:value-of select="mmd:personnel[mmd:role = 'Investigator']/mmd:contact_address/mmd:address" />
                                            </xsl:element>
                                        </xsl:element>
                                        <xsl:element name="gmd:city">
                                            <xsl:element name="gco:CharacterString">
                                                <xsl:value-of select="mmd:personnel[mmd:role = 'Investigator']/mmd:contact_address/mmd:city" />
                                            </xsl:element>
                                        </xsl:element>
                                        <xsl:element name="gmd:postalCode">
                                            <xsl:element name="gco:CharacterString">
                                                <xsl:value-of select="mmd:personnel[mmd:role = 'Investigator']/mmd:contact_address/mmd:postal_code" />
                                            </xsl:element>
                                        </xsl:element>
                                        <xsl:element name="gmd:country">
                                            <xsl:element name="gco:CharacterString">
                                                <xsl:value-of select="mmd:personnel[mmd:role = 'Investigator']/mmd:contact_address/mmd:country" />
                                            </xsl:element>
                                        </xsl:element>
	                    	    <!--[1..*] (characterString)-->	
                                        <xsl:element name="gmd:electronicMailAddress">
                                            <xsl:element name="gco:CharacterString">
                                                <xsl:value-of select="mmd:personnel[mmd:role = 'Investigator']/mmd:email" />
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

	   <xsl:apply-templates select="mmd:related_information[mmd:type = 'Dataset landing page']" />

           <gmd:locale>
               <gmd:PT_Locale id="locale-nor">
                   <gmd:languageCode>
                       <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2" codeListValue="nor">Norwegian</gmd:LanguageCode>
                   </gmd:languageCode>
                   <gmd:characterEncoding>
                       <gmd:MD_CharacterSetCode codeList="https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode" codeListValue="utf8">utf8</gmd:MD_CharacterSetCode>
                   </gmd:characterEncoding>
               </gmd:PT_Locale>
           </gmd:locale>            

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
                            <!-- non-english elements taken care of within template -->
                            <xsl:choose>
                                <xsl:when test="mmd:title[@xml:lang = 'en']">
                                    <xsl:apply-templates select="mmd:title[@xml:lang = 'en']" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="mmd:title" />
                                </xsl:otherwise>
                            </xsl:choose>
			
                            <xsl:if test="mmd:dataset_citation/mmd:publication_date !='' ">
                                <xsl:element name="gmd:date">
                                    <xsl:element name="gmd:CI_Date">
                                        <xsl:element name="gmd:date">
                                            <xsl:element name="gco:Date">
                                                <xsl:value-of select="mmd:dataset_citation/mmd:publication_date" />
                                            </xsl:element>
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
                            </xsl:if>
                           <xsl:if test="mmd:last_metadata_update/mmd:update/mmd:type ='Created' ">
                                 <xsl:element name="gmd:date">
                                     <xsl:element name="gmd:CI_Date">
                                         <xsl:element name="gmd:date">
                                             <xsl:element name="gco:Date">
                                                 <xsl:value-of select="substring-before(mmd:last_metadata_update/mmd:update/mmd:datetime[../mmd:type = 'Created'], 'T')"/>
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
                           <xsl:if test="(not(mmd:dataset_citation/mmd:publication_date) or not(string(mmd:dataset_citation/mmd:publication_date))) and not(mmd:last_metadata_update/mmd:update/mmd:datetime[../mmd:type ='Created'])">
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
                           </xsl:if>
			    
                        <!--xsl:apply-templates select="mmd:last_metadata_update" /-->
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
                    <!-- non-english elements taken care of within template -->
                    <xsl:choose>
                        <xsl:when test="mmd:abstract[@xml:lang = 'en']">
                            <xsl:apply-templates select="mmd:abstract[@xml:lang = 'en']" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="mmd:abstract" />
                        </xsl:otherwise>
                    </xsl:choose>
		    
		    <!--personnel (M) multiplicity [1] Relative to a responsible organisation, but there may be many responsible organisations for a single resource-->
		    <xsl:for-each select="mmd:personnel[mmd:role != 'Metadata author']">
                        <xsl:element name="gmd:pointOfContact">
			    <xsl:apply-templates select="." />
                        </xsl:element>
		    </xsl:for-each>
		    <!--keywords (M) multiplicity [1..*] -->
                    <xsl:apply-templates select="mmd:keywords" />

	     	    <!--access_constraint Conditional: referring to limitations on public access. Mandatory if accessConstraints or classification are not documented, multiplicity [0..*] for otherConstraints per instance of MD_LegalConstraints-->	
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
			<xsl:choose>
			    <xsl:when test="mmd:spatial_representation">
		                <xsl:element name="gmd:MD_SpatialRepresentationTypeCode">
			            <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_SpatialRepresentationTypeCode</xsl:attribute>
			            <xsl:attribute name="codeListValue">
                                        <xsl:value-of select="mmd:spatial_representation" />
			            </xsl:attribute>
                                        <xsl:value-of select="mmd:spatial_representation" />
		                </xsl:element>
			    </xsl:when>
			    <xsl:otherwise>
			        <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
			    </xsl:otherwise>
			</xsl:choose>
		    </xsl:element>

		    <xsl:element name="gmd:language">
		        <xsl:element name="gmd:LanguageCode">
		        <xsl:attribute name="codeList">http://www.loc.gov/standards/iso639-2/</xsl:attribute> 
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

		    <!--format-->
                    <xsl:apply-templates select="mmd:storage_information" />

                    <xsl:element name="gmd:distributor">
                        <xsl:apply-templates select="mmd:data_center" />
                    </xsl:element>
		    
                    <xsl:element name="gmd:transferOptions">
                        <xsl:element name="gmd:MD_DigitalTransferOptions">
                       	   <!--data_access. INSPIRE: Conditional for spatial dataset and spatial dataset series: Mandatory if a URL is available to obtain more information on the resources and/or access related services. multiplicity [0..*]-->
                            <xsl:apply-templates select="mmd:data_access" />
                            <xsl:element name="gmd:onLine">
                                <xsl:element name="gmd:CI_OnlineResource">
                                    <xsl:element name="gmd:linkage">
                                        <xsl:element name="gmd:URL">
                                            <xsl:value-of select="mmd:related_information[mmd:type = 'Dataset landing page']/mmd:resource" />
                                        </xsl:element>
                                    </xsl:element>
                                    <xsl:element name="gmd:protocol">
                                        <xsl:element name="gco:CharacterString">
                                            <xsl:text>WWW:LINK-1.0-http--link</xsl:text>
                                        </xsl:element>
                                    </xsl:element>
                                    <xsl:element name="gmd:name">
                                        <xsl:element name="gco:CharacterString">
                                            <xsl:value-of select="mmd:related_information[mmd:type = 'Dataset landing page']/mmd:type" />
                                        </xsl:element>
                                    </xsl:element>
                                    <xsl:element name="gmd:description">
                                        <xsl:element name="gco:CharacterString">
                                            <xsl:value-of select="mmd:related_information[mmd:type = 'Dataset landing page']/mmd:description" />
                                        </xsl:element>
                                    </xsl:element>
                                    <xsl:element name="gmd:function">
                                        <xsl:element name="gmd:CI_OnLineFunctionCode">
                                            <xsl:attribute name="codeList">http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_OnLineFunctionCode</xsl:attribute>
                                            <xsl:attribute name="codeListValue">
                                                <xsl:text>information</xsl:text>
                                            </xsl:attribute>
                                            <xsl:text>information</xsl:text>
                                        </xsl:element>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:element>
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
			            <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_ScopeCode</xsl:attribute>
				    <xsl:text>dataset</xsl:text>
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
							 <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode</xsl:attribute> 
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
            <xsl:attribute name="xsi:type">gmd:PT_FreeText_PropertyType</xsl:attribute>
            <xsl:element name="gco:CharacterString">
                <xsl:value-of select="." />
            </xsl:element>
            <xsl:element name="gmd:PT_FreeText">
                <xsl:element name="gmd:textGroup">
                    <xsl:element name="gmd:LocalisedCharacterString">
                        <xsl:attribute name="locale">#locale-nor</xsl:attribute>
                           <xsl:value-of select="../mmd:title[@xml:lang = 'no']" />
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>    

    </xsl:template>

    <!--abstract-->
    <xsl:template match="mmd:abstract">
    
        <xsl:element name="gmd:abstract">
            <xsl:attribute name="xsi:type">gmd:PT_FreeText_PropertyType</xsl:attribute>
            <xsl:element name="gco:CharacterString">
                <xsl:value-of select="." />
            </xsl:element>
            <xsl:element name="gmd:PT_FreeText">
                <xsl:element name="gmd:textGroup">
                    <xsl:element name="gmd:LocalisedCharacterString">
                        <xsl:attribute name="locale">#locale-nor</xsl:attribute>
                        <xsl:value-of select="../mmd:abstract[@xml:lang = 'no']" />
                    </xsl:element>
                </xsl:element>
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
		    <xsl:attribute name="codeList">http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_OnLineFunctionCode</xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="mmd:type = 'HTTP' or mmd:type = 'OPeNDAP' or mmd:type = 'FTP' or mmd:type = 'ODATA'">
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
               <xsl:if test="@vocabulary = 'CFSTDN' or @vocabulary = 'GCMDSK' or @vocabulary = 'GEMET' or @vocabulary = 'NORTHEMES'  or @vocabulary = 'WMOCAT' ">
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
                            <xsl:when test="@vocabulary = 'GCMDSK'">
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
                            <xsl:when test="@vocabulary = 'CFSTDN'">
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

    <xsl:template match="mmd:related_information">
       <xsl:element name="gmd:dataSetURI">
           <xsl:element name="gco:CharacterString">
              <xsl:value-of select="mmd:resource" />
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

    <!--publication date-->
    <xsl:template match="mmd:dataset_citation/mmd:publication_date">
    
        <xsl:element name="gmd:date">
            <xsl:element name="gmd:CI_Date">
                <xsl:element name="gmd:date">
                    <xsl:choose>
                        <xsl:when test=". !='' ">
                            <xsl:element name="gco:Date">
                                <xsl:value-of select="." />
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


    <xsl:template match="mmd:use_constraint">
         <xsl:element name="gmd:resourceConstraints">
             <xsl:element name="gmd:MD_LegalConstraints">
        
                 <xsl:element name="gmd:useConstraints">
                     <xsl:element name="gmd:MD_RestrictionCode">
                         <xsl:attribute name="codeList">https://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode</xsl:attribute>
                         <xsl:attribute name="codeListValue">otherRestrictions</xsl:attribute>
                         <xsl:text>otherRestrictions</xsl:text>
                     </xsl:element>
                 </xsl:element>

		 <xsl:choose>
		 <xsl:when test="mmd:resource != ''">
                     <xsl:element name="gmd:otherConstraints">
                             <xsl:element name="gmx:Anchor">
                                 <xsl:attribute name="xlink:href">
                                     <xsl:value-of select="mmd:resource" />
                                 </xsl:attribute>
		                 <xsl:value-of select="mmd:identifier" />
                             </xsl:element>
                     </xsl:element>
		 </xsl:when>
		 <xsl:when test="mmd:license_text">
                     <xsl:element name="gmd:otherConstraints">
                             <xsl:element name="gco:CharacterString">
		                 <xsl:value-of select="." />
                             </xsl:element>
                     </xsl:element>
		 </xsl:when>
		 <xsl:otherwise>
                     <xsl:element name="gmd:otherConstraints">
                             <xsl:element name="gmx:Anchor">
                                 <xsl:attribute name="xlink:href">
			             <xsl:text>http://inspire.ec.europa.eu/metadata-codelist/ConditionsApplyingToAccessAndUse/conditionsUnknown</xsl:text>
                                 </xsl:attribute>
			             <xsl:text>conditions to access and use unknown</xsl:text>
                             </xsl:element>
                     </xsl:element>
		 </xsl:otherwise>
		 </xsl:choose>
        
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
    

    <!-- Mappings for data_access type specification to OSGEO  -->
    <mapping:data_access_type_osgeo iso="OGC:WMS" mmd="OGC WMS" />    
    <mapping:data_access_type_osgeo iso="OGC:WCS" mmd="OGC WCS" />    
    <mapping:data_access_type_osgeo iso="OGC:WFS" mmd="OGC WFS" />    
    <mapping:data_access_type_osgeo iso="ftp" mmd="FTP" />
    <mapping:data_access_type_osgeo iso="WWW:DOWNLOAD-1.0-http--download" mmd="HTTP" />
    <mapping:data_access_type_osgeo iso="OPENDAP:OPENDAP" mmd="OPeNDAP" />

    <mapping:language_code iso="eng" mmd="en" />
</xsl:stylesheet>
