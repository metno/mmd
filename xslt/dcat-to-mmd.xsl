<?xml version="1.0" encoding="UTF-8"?>

<!--
Draft implementation of dcat to mmd mapping
-->

<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mmd="http://www.met.no/schema/mmd"
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcat="http://www.w3.org/ns/dcat#"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:org="http://www.w3.org/ns/org#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
    xmlns:schema="http://schema.org/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:locn="http://www.w3.org/ns/locn#"
    xmlns:adms="http://www.w3.org/ns/adms#"
    xmlns:dif="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/"
    version="1.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/rdf:RDF">
        <xsl:element name="mmd:mmd">
            <xsl:apply-templates select="dcat:Dataset" />
        </xsl:element>
    </xsl:template>


    <xsl:template match="dcat:Dataset">
        <!--Mandatory for Dataset-->    
        <xsl:apply-templates select="dct:title" />
        <xsl:apply-templates select="dct:description" />
        <!--Recommended for Dataset-->    
        <xsl:apply-templates select="dcat:contactPoint" />
	<!--create also investigator, unique in dcat-->
        <xsl:if test="dct:creator/foaf:Agent">
	    <xsl:element name="mmd:personnel">
	        <xsl:element name="mmd:role">
	            <xsl:text>Investigator</xsl:text>
                </xsl:element>
                <xsl:element name="mmd:name">
	            <xsl:value-of select="dct:creator/foaf:Agent/foaf:name" />
                </xsl:element>
                <xsl:element name="mmd:email">
	            <xsl:value-of select="dct:creator/foaf:Agent/foaf:mbox" />
                </xsl:element>
                <xsl:element name="mmd:organization">
	            <xsl:value-of select="dct:creator/foaf:Agent/org:memberOf/foaf:Organization/foaf:name" />
                </xsl:element>
            </xsl:element>
        </xsl:if>
	<xsl:for-each select="dcat:distribution">
            <xsl:apply-templates select="dcat:Distribution" />
        </xsl:for-each>
	<!--in dcat license apply to distribution not dataset. We can't get the use_constraint in mmd -->
        <xsl:element name="mmd:keywords">
            <xsl:attribute name="vocabulary">None</xsl:attribute>
	    <xsl:for-each select="dcat:keyword">
                <xsl:element name="mmd:keyword">
                    <xsl:value-of select="." />
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
        <xsl:element name="mmd:dataset_citation">
            <xsl:element name="mmd:author">
                <xsl:apply-templates select="dct:creator" />
            </xsl:element>
            <xsl:element name="mmd:publisher">
		    <xsl:apply-templates select="dct:publisher" />
            </xsl:element>
            <xsl:element name="mmd:publication_date">
		<xsl:value-of select="substring(dct:issued, 1, 10)" />
            </xsl:element>
        </xsl:element>
        <xsl:apply-templates select="dct:spatial" />
        <xsl:apply-templates select="dct:temporal" />
        <!--Optional for Dataset-->    
	<xsl:apply-templates select="dct:accessRights" />
	<xsl:apply-templates select="dct:identifier" />
	<xsl:apply-templates select="dcat:landingPage" />
	<xsl:apply-templates select="foaf:page" />
	<xsl:apply-templates select="dct:language" />
	<!--probably mapping to alternate_identifier-->
	<!--xsl:apply-templates select="adms:identifier" /-->
    <xsl:element name="mmd:metadata_source">
        <xsl:text>External-Harvest</xsl:text>
    </xsl:element>
    </xsl:template>
    

    <xsl:template match="dct:title">
        <xsl:element name="mmd:title">
            <xsl:attribute name="xml:lang">en</xsl:attribute>
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <xsl:template match="dct:description">
        <xsl:element name="mmd:abstract">
            <xsl:attribute name="xml:lang">en</xsl:attribute>
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <xsl:template match="dcat:contactPoint">
	<xsl:if test="vcard:Organization">
            <xsl:element name="mmd:personnel">
              <xsl:element name="mmd:role">
	          <xsl:text>Technical contact</xsl:text>
              </xsl:element>
              <xsl:element name="mmd:name">
		  <xsl:value-of select="vcard:Organization/vcard:fn" />
              </xsl:element>
              <xsl:element name="mmd:email">
		  <xsl:choose>
		  <xsl:when test="vcard:Organization/vcard:hasEmail/@rdf:resource">
		      <xsl:value-of select="substring-after(vcard:Organization/vcard:hasEmail/@rdf:resource, 'mailto:')" />
	          </xsl:when>
	          <xsl:otherwise>
		      <xsl:value-of select="vcard:Organization/vcard:hasEmail" />
	          </xsl:otherwise>
	          </xsl:choose>
              </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dcat:Distribution">
	<xsl:if test="dcat:downloadURL">
            <xsl:element name="mmd:data_access">
                <xsl:element name="mmd:type">
		    <xsl:text>HTTP</xsl:text>
                </xsl:element>
                <!--xsl:element name="mmd:name">
                    <xsl:value-of select="." />
                </xsl:element-->
		<!--this is probably the description of the distribution, not really matching the description of the data access as in mmd-->
                <xsl:element name="mmd:description">
	    	<xsl:value-of select="dct:description" />
                </xsl:element>
                <xsl:element name="mmd:resource">
	            <xsl:value-of select="@rdf:resource" />
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dct:creator">
        <!--This can be in different format, as resource for example-->
        <xsl:if test="foaf:Organization">
            <xsl:value-of select="foaf:Organization/foaf:name" />
        </xsl:if>
        <xsl:if test="foaf:Agent">
            <xsl:value-of select="foaf:Agent/foaf:name" />
        </xsl:if>
    </xsl:template>
   
    <xsl:template match="dct:publisher">
        <!--This can be in different format, as resource for example-->
        <xsl:if test="foaf:Organization">
            <xsl:value-of select="foaf:Organization/foaf:name" />
        </xsl:if>
        <xsl:if test="foaf:Agent">
            <xsl:value-of select="foaf:Agent/foaf:name" />
        </xsl:if>
    </xsl:template>
   
    <xsl:template match="dct:spatial">
        <xsl:element name="mmd:geographic_extent">
	    <xsl:apply-templates select="dct:Location"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dct:Location">
	<xsl:if test="dcat:bbox and contains(dcat:bbox/@rdf:datatype,'wkt') and contains(dcat:bbox,'POLYGON')">
            <xsl:element name="mmd:rectangle">
                <!--xsl:attribute name="srsName">
                    <xsl:value-of select="'EPSG:4326'" />
                </xsl:attribute-->
		<xsl:variable name="wkt" >
	      	    <!--expect POLYGON((-31.285 70.075,34.099 70.075,34.099 27.642,-31.285 27.642,-31.285 70.075))-->
                    <xsl:value-of select="substring-before(substring-after(dcat:bbox, '(('), '))')" />
                </xsl:variable>
                <xsl:call-template name="wktseparation">
                    <xsl:with-param name="boxcoordinates" select="$wkt" />
                </xsl:call-template>
            </xsl:element>
        </xsl:if>
	<!--xsl:if test="locn:geometry and contains(locn:geometry/@rdf:datatype,'wkt') and contains(locn:geometry,'POLYGON')">
            <xsl:element name="mmd:polygon">
                <xsl:element name="gml:Polygon">
                    <xsl:attribute name="id">polygon</xsl:attribute>
	            <xsl:variable name="polygon" >
                        <xsl:value-of select="substring-before(substring-after(locn:geometry, '(('), '))')" />
                    </xsl:variable>
                    <xsl:call-template name="polygonseparation">
                        <xsl:with-param name="polcoordinates" select="$polygon" />
                    </xsl:call-template>
                </xsl:element>
            </xsl:element>
        </xsl:if-->
    </xsl:template>
    
    <xsl:template name="wktseparation">
	
        <xsl:param name="boxcoordinates"/>
	<xsl:variable name="long1">
		<xsl:value-of select="number(substring-before(substring-before($boxcoordinates, ','), ' '))"/>
	</xsl:variable>
	<xsl:variable name="left1">
		<xsl:value-of select="substring-after($boxcoordinates, ',')"/>
	</xsl:variable>
	<xsl:variable name="long2">
		<xsl:value-of select="number(substring-before(substring-before($left1, ','), ' '))"/>
	</xsl:variable>
	<xsl:variable name="left2">
		<xsl:value-of select="substring-after($left1, ',')"/>
	</xsl:variable>
	<xsl:variable name="long3">
		<xsl:value-of select="number(substring-before(substring-before($left2, ','), ' '))"/>
	</xsl:variable>
	<xsl:variable name="left3">
		<xsl:value-of select="substring-after($left2, ',')"/>
	</xsl:variable>
	<xsl:variable name="long4">
		<xsl:value-of select="number(substring-before(substring-before($left3, ','), ' '))"/>
	</xsl:variable>
          
        <xsl:variable name="maxlong">
	    <xsl:choose>
	        <xsl:when test="($long1 > $long3)">
	    	    <xsl:value-of select="$long1"/>
	        </xsl:when>
	        <xsl:otherwise>
	    	    <xsl:value-of select="$long3"/>
	        </xsl:otherwise>
	    </xsl:choose>
        </xsl:variable>

        <xsl:variable name="minlong">
	    <xsl:choose>
	        <xsl:when test="($long1 > $long3)">
	     	    <xsl:value-of select="$long3"/>
	        </xsl:when>
		<xsl:otherwise>
		    <xsl:value-of select="$long1"/>
		</xsl:otherwise>
	    </xsl:choose>
        </xsl:variable>

	<xsl:variable name="lat1">
		<xsl:value-of select="number(substring-after(substring-before($boxcoordinates, ','), ' '))"/>
	</xsl:variable>
	<xsl:variable name="left1a">
		<xsl:value-of select="substring-after($boxcoordinates, ',')"/>
	</xsl:variable>
	<xsl:variable name="lat2">
		<xsl:value-of select="number(substring-after(substring-before($left1a, ','), ' '))"/>
	</xsl:variable>
	<xsl:variable name="left2a">
		<xsl:value-of select="substring-after($left1a, ',')"/>
	</xsl:variable>
	<xsl:variable name="lat3">
		<xsl:value-of select="number(substring-after(substring-before($left2a, ','), ' '))"/>
	</xsl:variable>
	<xsl:variable name="left3a">
		<xsl:value-of select="substring-after($left2a, ',')"/>
	</xsl:variable>
	<xsl:variable name="lat4">
		<xsl:value-of select="number(substring-after(substring-before($left3a, ','), ' '))"/>
	</xsl:variable>
          
        <xsl:variable name="maxlat">
	    <xsl:choose>
	        <xsl:when test="($lat1 > $lat3)">
	    	    <xsl:value-of select="$lat1"/>
	        </xsl:when>
	        <xsl:otherwise>
	    	    <xsl:value-of select="$lat3"/>
	        </xsl:otherwise>
	    </xsl:choose>
        </xsl:variable>

        <xsl:variable name="minlat">
	    <xsl:choose>
	        <xsl:when test="($lat1 > $lat3)">
	     	    <xsl:value-of select="$lat3"/>
	        </xsl:when>
		<xsl:otherwise>
		    <xsl:value-of select="$lat1"/>
		</xsl:otherwise>
	    </xsl:choose>
        </xsl:variable>

        <xsl:element name="mmd:south">
          <xsl:value-of select="$minlat" />
        </xsl:element>
        <xsl:element name="mmd:north">
          <xsl:value-of select="$maxlat" />
        </xsl:element>
        <xsl:element name="mmd:west">
          <xsl:value-of select="$minlong" />
        </xsl:element>
        <xsl:element name="mmd:east">
          <xsl:value-of select="$maxlong" />
        </xsl:element>
    </xsl:template>

    <!--to be fixed-->
    <xsl:template name="polygonseparation">
    </xsl:template>

    <xsl:template match="dct:temporal">
        <xsl:element name="mmd:temporal_extent">
            <xsl:element name="mmd:start_date">
                <xsl:value-of select="dct:PeriodOfTime/dcat:startDate"/>
            </xsl:element>
            <xsl:element name="mmd:end_date">
                <xsl:value-of select="dct:PeriodOfTime/dcat:endDate"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dct:identifier">
        <xsl:element name="mmd:metadata_identifier">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="dct:accessRights">
	<!--This is most likely a resource URL/controlled vocabulary which should be mapped public, restricted, non-public-->
        <xsl:element name="mmd:access_constraint">
	    <xsl:choose>
	        <xsl:when test="dct:RightsStatement">
	            <xsl:value-of select="dct:RightsStatement" />
	        </xsl:when>
	        <xsl:otherwise>
	            <xsl:value-of select="." />
	        </xsl:otherwise>
	    </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dcat:landingPage">
        <xsl:element name="mmd:related_information">
	    <!--This can probably have a different representation-->
            <xsl:element name="mmd:type">Dataset landing page</xsl:element>
	    <xsl:choose>
	        <xsl:when test="foaf:Document">
                    <xsl:element name="mmd:resource">
	                <xsl:value-of select="foaf:Document/@rdf:about" />
                    </xsl:element>
                    <xsl:element name="mmd:description">
                        <xsl:value-of select="foaf:Document/dct:description" />
                    </xsl:element>
	        </xsl:when>
	        <xsl:otherwise>
                    <xsl:element name="mmd:resource">
	                <xsl:value-of select="." />
                    </xsl:element>
	        </xsl:otherwise>
	    </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="foaf:page">
	<!--This  property  refers  to  a  page  or document about this Dataset. We can't discriminate the type-->
        <xsl:element name="mmd:related_information">
            <xsl:element name="mmd:type">Other documentation</xsl:element>
	    <xsl:choose>
	        <xsl:when test="foaf:Document">
                    <xsl:element name="mmd:resource">
	                <xsl:value-of select="foaf:Document/@rdf:about" />
                    </xsl:element>
                    <xsl:element name="mmd:description">
                        <xsl:value-of select="foaf:Document/dct:description" />
                    </xsl:element>
	        </xsl:when>
	        <xsl:otherwise>
                    <xsl:element name="mmd:resource">
	                <xsl:value-of select="@rdf:resource" />
                    </xsl:element>
	        </xsl:otherwise>
	    </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dct:language">
	    <!--In dcat this element is NOT unique as in mmd-->
        <xsl:element name="mmd:dataset_language">
	    <!--probably dct:LinguisticSystem is used instead. It should be a resource type.-->
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
