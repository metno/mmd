<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
        xmlns:mm2="http://www.met.no/schema/metamod/MM2"
        xmlns:mmd="http://www.met.no/schema/mmd" 
        xmlns:mapping="http://www.met.no/schema/metamod/mm2mm3"
        xmlns:xmd="http://www.met.no/schema/metamod/dataset" version="1.0"
        xmlns:w="http://www.met.no/schema/metamod/ncWmsSetup">
  <xsl:param name="xmd"/>
  <xsl:param name="mmdid"/>
  <xsl:param name="parentDataset"/>
  <xsl:param name="currentYear"/>
  <xsl:output method="xml" indent="yes"/>
  <xsl:template match="/mm2:MM2">
        <xsl:element name="mmd:mmd">
            <xsl:element name="mmd:metadata_identifier">
                <xsl:value-of select="$mmdid"/>
            </xsl:element>
            <xsl:apply-templates select="*[@name='title']"/>
            <xsl:apply-templates select="*[@name='abstract']"/>
            <xsl:apply-templates select="document($xmd)/xmd:dataset/xmd:info/@status"/>
            <xsl:element name="mmd:dataset_production_status">
              <xsl:choose>
                <xsl:when test="number(substring(mm2:metadata[@name='datacollection_period_to'],1,4)) > $currentYear">
                  In Work
                </xsl:when>
                <xsl:when test="normalize-space(mm2:metadata[@name='datacollection_period_to'])=''">
                  In Work
                </xsl:when>
                <xsl:otherwise>Complete</xsl:otherwise>
              </xsl:choose>
            </xsl:element>

            <xsl:element name="mmd:collection">
              <xsl:value-of select="document($xmd)/xmd:dataset/xmd:info/@ownertag"/>
            </xsl:element>

            <xsl:apply-templates select="document($xmd)/xmd:dataset/xmd:info/@datestamp"/>
            <xsl:element name="mmd:temporal_extent">
                <xsl:element name="mmd:start_date">
		    <xsl:value-of select="concat(substring(mm2:metadata[@name='datacollection_period_from'],1,10),'T12:00:00Z')"/>
                </xsl:element>
                <xsl:element name="mmd:end_date">
                    <xsl:value-of select="concat(substring(mm2:metadata[@name='datacollection_period_to'],1,10),'T12:00:00Z')"/>
                </xsl:element>
            </xsl:element>

            <xsl:apply-templates select="*[@name='topiccategory']"/>

            <xsl:element name="mmd:keywords">
                <xsl:attribute name="vocabulary">gcmd</xsl:attribute>

                <xsl:for-each select="mm2:metadata[@name='variable' and contains(., '>')]">
                    <xsl:variable name="value">  <!-- strip away HIDDEN suffix -->
                        <xsl:choose>
                            <xsl:when test="contains(., 'HIDDEN')">
                                <xsl:value-of select="substring-before(., ' > HIDDEN')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:element name="mmd:keyword">
                        <xsl:value-of select="$value"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>

            <xsl:element name="mmd:keywords">
                <xsl:attribute name="vocabulary">CF</xsl:attribute>

                <xsl:for-each select="mm2:metadata[@name='keywords']">
                    <xsl:element name="mmd:keyword">
                        <!--<xsl:attribute name="vocabulary">none</xsl:attribute> -->
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
            
            
            <xsl:apply-templates select="*[@name='operational_status']"/>    
            <xsl:apply-templates select="*[@name='dataref']"/>
           <!-- <xsl:apply-templates select="*[@name='dataref_WMS']"/> -->
           <!-- while testing
            -->
            <xsl:apply-templates select="document($xmd)/xmd:dataset/xmd:wmsInfo/w:ncWmsSetup"/>
            <xsl:apply-templates select="*[@name='dataref_OPENDAP']"/>
            <xsl:apply-templates select="*[@name='bounding_box']"/>

            <!-- assume only single contact -->
            <xsl:element name="mmd:personnel">
                <xsl:element name="mmd:role">Investigator</xsl:element>
                <xsl:element name="mmd:name">
                    <xsl:value-of select="mm2:metadata[@name='PI_name']"/>
                </xsl:element>
                <xsl:element name="mmd:email">
                    <xsl:value-of select="mm2:metadata[@name='contact']"/>
                </xsl:element>
                <xsl:element name="mmd:phone"/>
                <xsl:element name="mmd:fax"/>
                <xsl:element name="mmd:organisation">
                    <xsl:value-of select="mm2:metadata[@name='institution']"/>
                </xsl:element>
            </xsl:element>

            <xsl:apply-templates select="*[@name='distribution_statement']"/>

            <xsl:apply-templates select="*[@name='project_name']"/>
            <xsl:apply-templates select="*[@name='Platform_name']"/>
            <xsl:apply-templates select="*[@name='activity_type']"/>

            <xsl:choose>
              <xsl:when test="mm2:metadata[@name='dataref_WMS']">
                      <xsl:apply-templates select="*[@name='dataref_WMS']"/>
              </xsl:when>
              <!--
              <xsl:otherwise>
                  <xsl:element name="mmd:data_access">
                  <xsl:element name="mmd:type">OGC WMS</xsl:element>
                  <xsl:element name="mmd:description"/>
                  <xsl:element name="mmd:resource">
                      <xsl:value-of select="document($xmd)/xmd:dataset/xmd:wmsInfo/w:ncWmsSetup/@aggregate_url"/>
                  </xsl:element>                  
                -->
                  <!-- include wms layers -->
              <!--
                  <xsl:element name="mmd:wms_layers">
                    <xsl:for-each select="document($xmd)/xmd:dataset/xmd:wmsInfo/w:ncWmsSetup/w:layer">
                          <xsl:element name="mmd:wms_layer">                        
                              <xsl:value-of select="@name"/>
                          </xsl:element>
                      </xsl:for-each>
                  </xsl:element>
              </xsl:element>     
          </xsl:otherwise>
          -->
            </xsl:choose>
            
<!--
            <xsl:element name="mmd:keywords">
                <xsl:attribute name="vocabulary">cf</xsl:attribute>
                <xsl:for-each
                    select="mm2:metadata[@name='variable' and not(contains(., '&gt;'))]">
                    <xsl:element name="mmd:keyword">
                        <xsl:value-of select="." />
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
-->
<!--
           <xsl:element name="mmd:system_specific_product_metadata">
                <xsl:attribute name="for">metamod</xsl:attribute>
                <xsl:copy-of select="document($xmd)/*" />
            </xsl:element>
-->
	   <xsl:element name="mmd:related_dataset">
                <xsl:attribute name="mmd:relation_type">parent</xsl:attribute>
                <xsl:copy-of select="$parentDataset"/>
           </xsl:element>
        </xsl:element>
    </xsl:template>
  <xsl:template match="xmd:dataset/xmd:info/@status">
      <xsl:element name="mmd:metadata_status">
              <xsl:value-of select="."/>
            </xsl:element>
    </xsl:template>
  <xsl:template match="xmd:dataset/xmd:info/@datestamp">
        <xsl:element name="mmd:last_metadata_update">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="xmd:dataset/xmd:wmsInfo/w:ncWmsSetup">
        <xsl:element name="mmd:data_access">
            <xsl:element name="mmd:type">OGC WMS</xsl:element>
            <xsl:element name="mmd:description"/>
            <xsl:element name="mmd:resource">
                <xsl:value-of select="@aggregate_url"/>
            </xsl:element>            
            <!-- include wms layers -->
            <!-- while testing
            <xsl:element name="mmd:wms_layers">
              <xsl:for-each select="document($xmd)/xmd:dataset/xmd:wmsInfo/w:ncWmsSetup/w:layer">
                    <xsl:element name="mmd:wms_layer">                        
                        <xsl:value-of select="@name"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
            -->
        </xsl:element>
    </xsl:template>
  <xsl:template match="*[@name='operational_status']">
        <xsl:element name="mmd:operational_status">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
  <xsl:template match="*[@name='activity_type']">
        <xsl:element name="mmd:activity_type">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
  <xsl:template match="*[@name='distribution_statement']">
        <xsl:element name="mmd:access_constraint">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
  <xsl:template match="*[@name='topiccategory']">
        <xsl:element name="mmd:iso_topic_category">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
  <xsl:template match="*[@name='title']">
        <xsl:element name="mmd:title">
            <xsl:attribute name="xml:lang">en</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
  <xsl:template match="*[@name='abstract']">
        <xsl:element name="mmd:abstract">
            <xsl:attribute name="xml:lang">en</xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
  <xsl:template match="*[@name='project_name']">
        <xsl:element name="mmd:project">
            <xsl:element name="mmd:short_name"/>
            <xsl:element name="mmd:long_name">
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
  <xsl:template match="*[@name='Platform_name']">
        <xsl:element name="mmd:platform">
            <xsl:element name="mmd:short_name"/>
            <xsl:element name="mmd:long_name">
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
  <xsl:template match="*[@name='dataref']">
        <xsl:element name="mmd:data_access">
            <xsl:element name="mmd:type">HTTP</xsl:element>
            <xsl:element name="mmd:description"/>
            <xsl:element name="mmd:resource">
                <xsl:value-of select="."/>
            </xsl:element>            
        </xsl:element>
    </xsl:template>
  <xsl:template match="*[@name='dataref_WMS']">
        <xsl:element name="mmd:data_access">
            <xsl:element name="mmd:type">OGC WMS</xsl:element>
            <xsl:element name="mmd:description"/>
            <xsl:element name="mmd:resource">
                <xsl:value-of select="."/>
            </xsl:element>            
            <!-- include wms layers -->
            <xsl:element name="mmd:wms_layers">
              <xsl:for-each select="document($xmd)/xmd:dataset/xmd:wmsInfo/w:ncWmsSetup/w:layer">
                    <xsl:element name="mmd:wms_layer">                        
                        <xsl:value-of select="@name"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:element>
    </xsl:template>
  <xsl:template match="*[@name='dataref_OPENDAP']">
        <xsl:element name="mmd:data_access">
            <xsl:element name="mmd:type">OPeNDAP</xsl:element>
            <xsl:element name="mmd:description"/>
            <xsl:element name="mmd:resource">
                <xsl:value-of select="."/>
            </xsl:element>            
        </xsl:element>
    </xsl:template>
  <xsl:template match="*[@name='bounding_box']">

        <!-- input format is ESWN, output format is SNWE -->
        <xsl:variable name="ESWN" select="."/>
        <xsl:variable name="SWN" select="substring-after($ESWN, ',')"/>
        <xsl:variable name="WN" select="substring-after($SWN, ',')"/>
        <xsl:variable name="N" select="substring-after($WN, ',')"/>

        <xsl:element name="mmd:geographic_extent">
            <xsl:element name="mmd:rectangle">
                <xsl:attribute name="srsName">EPSG:4326</xsl:attribute>
                <xsl:element name="mmd:north">
                    <xsl:value-of select="$N"/>
                </xsl:element>
                <xsl:element name="mmd:south">
                    <xsl:value-of select="substring-before($SWN, ',')"/>
                </xsl:element>
                <xsl:element name="mmd:west">
                    <xsl:value-of select="substring-before($WN, ',')"/>
                </xsl:element>
                <xsl:element name="mmd:east">
                    <xsl:value-of select="substring-before($ESWN, ',')"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
