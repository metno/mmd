<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:dif="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/"
        xmlns:mmd="http://www.met.no/schema/mmd"
        version="1.0">
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/dif:DIF">
    <xsl:element name="mmd:mmd">
      <xsl:apply-templates select="dif:Entry_ID" />
      <xsl:apply-templates select="dif:Entry_Title" />
      <xsl:apply-templates select="dif:Summary" />
      <xsl:element name="mmd:metadata_status">Active</xsl:element>
      <xsl:apply-templates select="dif:Data_Set_Progress" />
      <xsl:element name="mmd:collection">ADC</xsl:element>
      <xsl:element name="mmd:collection">NSDN</xsl:element>
      <xsl:apply-templates select="dif:Last_DIF_Revision_Date" />
      <xsl:apply-templates select="dif:Temporal_Coverage" />
      <xsl:apply-templates select="dif:ISO_Topic_Category" />
      <xsl:apply-templates select="dif:Parameters" />
      <xsl:apply-templates select="dif:Keyword" />
      <xsl:apply-templates select="dif:Project" />
      <xsl:apply-templates select="dif:Spatial_Coverage" />
      <xsl:apply-templates select="dif:Access_Constraints" />
      <xsl:apply-templates select="dif:Related_URL" />
      <xsl:apply-templates select="dif:Data_Set_Citation" />
      <xsl:apply-templates select="dif:Data_Center" />
      <xsl:apply-templates select="dif:Originating_Center" />
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
	<xsl:element name="mmd:metadata_identifier">
		<xsl:value-of select="." />
	</xsl:element>
  </xsl:template>


  <xsl:template match="dif:Entry_Title">
    <xsl:element name="mmd:title">
      <xsl:attribute name="xml:lang">en</xsl:attribute>
      <xsl:value-of select="." />
    </xsl:element>
  </xsl:template>


  <xsl:template match="dif:Data_Set_Citation">
	<xsl:element name="mmd:dataset_citation">
		<xsl:element name="mmd:dataset_creator">
                	<xsl:value-of select="dif:Dataset_Creator" />
        	</xsl:element>
		<xsl:element name="mmd:dataset_editor">
                	<xsl:value-of select="dif:Dataset_Editor" />
            	</xsl:element>
		<xsl:element name="mmd:dataset_title">
                	<xsl:value-of select="dif:Dataset_Title" />
            	</xsl:element>
		<xsl:element name="mmd:dataset_series_name">
                	<xsl:value-of select="dif:Dataset_Series_Name" />
            	</xsl:element>
		<xsl:element name="mmd:dataset_release_date">
                	<xsl:value-of select="dif:Dataset_Release_Date" />
            	</xsl:element>
		<xsl:element name="mmd:dataset_release_place">
                	<xsl:value-of select="dif:Dataset_Release_Place" />
            	</xsl:element>
		<xsl:element name="mmd:dataset_publisher">
                	<xsl:value-of select="dif:Dataset_Publisher" />
            	</xsl:element>
		<xsl:element name="mmd:version">
                	<xsl:value-of select="dif:Version" />
            	</xsl:element>
                <!--
		<xsl:element name="mmd:dataset_presentation_form">
                	<xsl:value-of select="dif:Data_Presentation_Form" />
                </xsl:element>
		<xsl:element name="mmd:online_resource">
                	<xsl:value-of select="dif:Online_Resource" />
            	</xsl:element>
                -->
	</xsl:element>
        <xsl:element name="mmd:related_information">
            <xsl:element name="mmd:type">Dataset landing page</xsl:element>
            <xsl:element name="mmd:description">NA</xsl:element>
            <xsl:element name="mmd:resource">
                <xsl:value-of select="dif:Online_Resource"/>
            </xsl:element>
        </xsl:element>
  </xsl:template>

  <xsl:template match="dif:Parameters">
      <xsl:if test="/dif:DIF[not(contains(dif:Entry_ID,'PANGAEA'))]">
          <xsl:element name="mmd:keywords">
              <xsl:attribute name="vocabulary">GCMD</xsl:attribute>
              <xsl:element name="mmd:keyword">
                  <xsl:value-of select="dif:Category"/> &gt; <xsl:value-of select="dif:Topic"/> &gt; <xsl:value-of select="dif:Term" /><xsl:if test="dif:Variable_Level_1/*"> &gt; <xsl:value-of select="dif:Variable_Level_1" /></xsl:if><xsl:if test="dif:Variable_Level_2/*"> &gt; <xsl:value-of select="dif:Variable_Level_2" /></xsl:if><xsl:if test="dif:Variable_Level_3/*"> &gt; <xsl:value-of select="dif:Variable_Level_3" /></xsl:if>
              </xsl:element>
          </xsl:element>
      </xsl:if>
  </xsl:template>

  <xsl:template match="dif:ISO_Topic_Category">
	<xsl:element name="mmd:iso_topic_category">
		<xsl:value-of select="." />
	</xsl:element>
  </xsl:template>


  <xsl:template match="dif:Keyword">
      <xsl:element name="mmd:keywords">
      <xsl:attribute name="vocabulary">None</xsl:attribute>
          <xsl:element name="mmd:keyword">
              <xsl:value-of select="." />
          </xsl:element>
      </xsl:element>
  </xsl:template>

	<xsl:template match="dif:Data_Set_Progress">
		<xsl:element name="mmd:dataset_production_status">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

  <xsl:template match="dif:Temporal_Coverage">
  	<xsl:element name="mmd:temporal_extent">
      		<xsl:element name="mmd:start_date">
			<xsl:value-of select="dif:Start_Date" />
		</xsl:element>
		<xsl:element name="mmd:end_date">
			<xsl:value-of select="dif:Stop_Date" />
		</xsl:element>
    	</xsl:element>
  </xsl:template>


<!--  <xsl:template match="dif:Temporal_Coverage/dif:Stop_Date">
    <xsl:element name="mmd:datacollection_period_to">
      <xsl:value-of select="." />
    </xsl:element>
  </xsl:template>
-->

	<xsl:template match="dif:Spatial_Coverage">
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
	</xsl:template>

<!--
	<xsl:template match="dif:Spatial_Coverage">
		<xsl:element name="mmd:bounding_box">
      <xsl:value-of select="dif:Easternmost_Longitude" />,<xsl:value-of select="dif:Southernmost_Latitude" />,<xsl:value-of select="dif:Westernmost_Longitude" />,<xsl:value-of select="dif:Northernmost_Latitude" />
    </xsl:element>
	</xsl:template>
-->

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
<!--
	<xsl:template match="dif:Project/dif:Long_Name">
	</xsl:template>
-->
  <xsl:template match="dif:Access_Constraints">
	<xsl:element name="mmd:access_constraint">
		<xsl:value-of select="." />
	</xsl:element>
  </xsl:template>

  <xsl:template match="dif:Related_URL">
      <!-- This is probably not necessary, nor consistent for providers
           use Online_Resource in Data_Citation instead...
      <xsl:if test="dif:Description[contains(text(),'text/html')]">
          <xsl:element name="mmd:related_information">
              <xsl:element name="mmd:type">Dataset landing page</xsl:element>
              <xsl:element name="mmd:description">
                  <xsl:value-of select="dif:Description"/>
              </xsl:element>
              <xsl:element name="mmd:resource">
                  <xsl:value-of select="dif:URL"/>
              </xsl:element>
          </xsl:element>
      </xsl:if>
      -->
<!-- while testing
      <xsl:if test="dif:URL_Content_Type/dif:Type[contains(text(),'GET DATA')]">
          <xsl:element name="mmd:data_access">
              <xsl:element name="mmd:type">HTTP</xsl:element>
              -->
              <!--
                  <xsl:value-of select="dif:URL_Content_Type/dif:Type" />
              </xsl:element>
              -->
              <!--
              <xsl:element name="mmd:description">
                  <xsl:value-of select="dif:Description" />
              </xsl:element>
              <xsl:element name="mmd:resource">
                  <xsl:value-of select="dif:URL" />
              </xsl:element>
          </xsl:element>
      </xsl:if>
      -->
      <xsl:choose>
          <xsl:when test="dif:URL_Content_Type/dif:Type[contains(text(),'GET DATA')]">
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
          <xsl:when test="dif:URL_Content_Type/dif:Type[contains(text(),'USE SERVICE API')]"> 
              <!-- Need to fix this
              <xsl:choose>
                  <xsl:when test="dif:URL_Content_Type/dif:SubType[contains(text(),'OPENDAP DATA')]">
-->
                      <xsl:element name="mmd:data_access">
                          <xsl:element name="mmd:type">OPENDAP</xsl:element>
                          <xsl:element name="mmd:description">
                              <xsl:value-of select="dif:Description" />
                          </xsl:element>
                          <xsl:element name="mmd:resource">
                              <xsl:value-of select="dif:URL" />
                          </xsl:element>
                      </xsl:element>
                      <!--
                  </xsl:when>
              </xsl:choose>
-->
          </xsl:when>
      </xsl:choose>
  </xsl:template>


  <xsl:template match="dif:Originating_Center">
      <xsl:element name="mmd:personnel">
          <xsl:element name="mmd:role">
              <xsl:value-of select="/dif:DIF/dif:Personnel/dif:Role" />
          </xsl:element>
          <xsl:element name="mmd:name">
              <xsl:value-of select="/dif:DIF/dif:Personnel/dif:First_Name"/> <xsl:value-of select="/dif:DIF/dif:Personnel/dif:Last_Name"/>
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
		<xsl:element name="mmd:dataset_id">
			<xsl:value-of select="dif:Data_Set_ID" />
		</xsl:element>
		<xsl:element name="mmd:contact">
			<xsl:element name="mmd:role">
				<xsl:value-of select="dif:Personnel/dif:Role" />
			</xsl:element>
			<xsl:element name="mmd:name">
				<!-- Since last name is required it used in translation -->
				<xsl:value-of select="dif:Personnel/dif:Last_Name" />
			</xsl:element>
			<xsl:element name="mmd:email">
				<xsl:value-of select="dif:Personnel/dif:Email" />
			</xsl:element>
			<xsl:element name="mmd:phone">
				<xsl:value-of select="dif:Personnel/dif:Phone" />
			</xsl:element>
			<xsl:element name="mmd:fax">
				<xsl:value-of select="dif:Personnel/dif:Fax" />
			</xsl:element>
		</xsl:element>
	</xsl:element>
  </xsl:template>


  <xsl:template match="dif:Reference">
  </xsl:template>

  <xsl:template match="dif:Summary">
      <xsl:choose>
          <xsl:when test="dif:Abstract">
              <xsl:element name="mmd:abstract">
                  <xsl:value-of select="dif:Abstract" />
              </xsl:element>
          </xsl:when>
          <xsl:otherwise>
              <xsl:element name="mmd:abstract">
                  <xsl:value-of select="." />
              </xsl:element>
          </xsl:otherwise>
      </xsl:choose>
  </xsl:template>


  <xsl:template match="dif:Metadata_Name">
  </xsl:template>


  <xsl:template match="dif:Metadata_Version">
  </xsl:template>

  <xsl:template match="dif:Last_DIF_Revision_Date">
	<xsl:element name="mmd:last_metadata_update">
		<xsl:value-of select="." />
	</xsl:element>
  </xsl:template>

  <xsl:template match="dif:Parent_DIF">
      <xsl:element name="mmd:related_dataset">
          <xsl:attribute name="mmd:relation_type">parent</xsl:attribute>
          <xsl:value-of select="." />
      </xsl:element>
  </xsl:template>


  <xsl:template match="dif:Private">
  </xsl:template>

</xsl:stylesheet>
