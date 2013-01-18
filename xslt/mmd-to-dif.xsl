<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dif="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/" xmlns:mm3="http://www.met.no/schema/mm3"
	xmlns:dc="http://purl.org/dc/elements/1.1/" version="1.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />

	<xsl:template match="/mm3:mm3">
		<xsl:element name="dif:DIF">
			<xsl:apply-templates select="mm3:metadata_identifier" />
			<xsl:apply-templates select="mm3:title" />
			<xsl:apply-templates select="mm3:abstract" />
			<xsl:apply-templates select="mm3:last_metadata_update" />
			<xsl:apply-templates select="mm3:iso_topic_category" />
			<xsl:apply-templates select="mm3:keywords" />
			<xsl:apply-templates select="mm3:project" />
			<xsl:apply-templates select="mm3:instrument" />
			<xsl:apply-templates select="mm3:platform" />
			<xsl:apply-templates select="mm3:temporal_extent" />
			<xsl:apply-templates select="mm3:geographic_extent/mm3:rectangle" />
			<xsl:apply-templates select="mm3:data_access" />
			<xsl:apply-templates select="mm3:data_center" />
			<xsl:apply-templates select="mm3:dataset_citation" />
			<xsl:apply-templates select="mm3:access_constraint" />
			<xsl:apply-templates select="mm3:use_constraint" />
			<xsl:apply-templates select="mm3:dataset_production_status" />
			<xsl:apply-templates select="mm3:dataset_language" />

			<xsl:element name="dif:Metadata_Name">
				CEOS IDN DIF
			</xsl:element>
			<xsl:element name="dif:Metadata_Version">
				9.7
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mm3:metadata_identifier">
		<xsl:element name="dif:Entry_ID">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mm3:title">
		<xsl:element name="dif:Entry_Title">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mm3:abstract">
		<xsl:element name="dif:Summary">
			<xsl:element name="dif:Abstract">
				<xsl:value-of select="." />
			</xsl:element>
			<xsl:element name="dif:Purpose" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mm3:last_metadata_update">
		<xsl:element name="dif:Last_DIF_Revision_Date">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mm3:keywords">
		<xsl:for-each select="mm3:keyword">
			<xsl:element name="dif:Keyword">
				<xsl:value-of select="." />
			</xsl:element>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="mm3:temporal_extent">
		<xsl:element name="dif:Temporal_Coverage">
			<xsl:element name="dif:Start_Date">
				<xsl:value-of select="mm3:start_date" />
			</xsl:element>
			<xsl:element name="dif:End_Date">
				<xsl:value-of select="mm3:end_date" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mm3:geographic_extent/mm3:rectangle">
		<xsl:element name="dif:Spatial_Coverage">
			<xsl:element name="dif:Southernmost_Latitude">
				<xsl:value-of select="mm3:south" />
			</xsl:element>
			<xsl:element name="dif:Northernmost_Latitude">
				<xsl:value-of select="mm3:north" />
			</xsl:element>
			<xsl:element name="dif:Westernmost_Latitude">
				<xsl:value-of select="mm3:west" />
			</xsl:element>
			<xsl:element name="dif:Easternmost_Latitude">
				<xsl:value-of select="mm3:east" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mm3:data_access">
		<xsl:element name="dif:Related_URL">
			<xsl:element name="dif:URL_Content_Type">
				<xsl:element name="dif:Type">
					<xsl:value-of select="mm3:type" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="dif:URL">
				<xsl:value-of select="mm3:resource" />
			</xsl:element>
			<xsl:element name="dif:Description">
				<xsl:value-of select="mm3:description" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mm3:project">
		<xsl:element name="dif:Project">
			<xsl:element name="dif:Short_Name">
				<xsl:value-of select="mm3:short_name" />
			</xsl:element>
			<xsl:element name="dif:Long_Name">
				<xsl:value-of select="mm3:long_name" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mm3:instrument">
		<xsl:element name="dif:Instrument">
			<xsl:element name="dif:Short_Name">
				<xsl:value-of select="mm3:short_name" />
			</xsl:element>
			<xsl:element name="dif:Long_Name">
				<xsl:value-of select="mm3:long_name" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mm3:platform">
		<xsl:element name="dif:Platform">
			<xsl:element name="dif:Short_Name">
				<xsl:value-of select="mm3:short_name" />
			</xsl:element>
			<xsl:element name="dif:Long_Name">
				<xsl:value-of select="mm3:long_name" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="mm3:access_constraint">
		<xsl:element name="dif:Access_Constraints">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mm3:use_constraint">
		<xsl:element name="dif:Use_Constraints">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mm3:dataset_production_status">
		<xsl:element name="dif:Data_Set_Progress">
			TODO: Fix proper translation of status
		</xsl:element>
	</xsl:template>

	<xsl:template match="mm3:dataset_language">
		<xsl:element name="dif:Data_Set_Language">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mm3:iso_topic_category">
		<xsl:element name="dif:ISO_TOPIC_Category">
			<xsl:value-of select="." />
		</xsl:element>
	</xsl:template>

	<xsl:template match="mm3:data_center">

		<xsl:element name="dif:Data_Center">
			<xsl:element name="dif:Data_Center_Name">
				<xsl:element name="dif:Short_Name">
					<xsl:value-of select="mm3:data_center_name/mm3:short_name" />
				</xsl:element>
				<xsl:element name="dif:Long_Name">
					<xsl:value-of select="mm3:data_center_name/mm3:long_name" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="dif:Data_Center_URL">
				<xsl:value-of select="mm3:data_center_url" />
			</xsl:element>
			<xsl:element name="dif:Data_Set_ID">
				<xsl:value-of select="mm3:dataset_id" />
			</xsl:element>
			<xsl:element name="dif:Personel">
				<xsl:element name="dif:Role">
					<xsl:value-of select="mm3:contact/mm3:role"></xsl:value-of>
				</xsl:element>
				<xsl:element name="dif:First_Name" />
				<xsl:element name="dif:Middle_Name" />
				<xsl:element name="dif:Last_Name">
					<xsl:value-of select="mm3:contact/mm3:name"></xsl:value-of>
				</xsl:element>
				<xsl:element name="dif:Phone">
					<xsl:value-of select="mm3:contact/mm3:phone"></xsl:value-of>
				</xsl:element>
				<xsl:element name="dif:Fax">
					<xsl:value-of select="mm3:contact/mm3:fax"></xsl:value-of>
				</xsl:element>

				<xsl:element name="dif:Contact_Address">
					<xsl:element name="dif:Address">
						<xsl:value-of select="mm3:contact/mm3:contact_address/mm3:address" />
					</xsl:element>
					<xsl:element name="dif:City">
						<xsl:value-of select="mm3:contact/mm3:contact_address/mm3:city" />
					</xsl:element>
					<xsl:element name="dif:Province_or_State">
						<xsl:value-of
							select="mm3:contact/mm3:contact_address/mm3:province_or_state" />
					</xsl:element>
					<xsl:element name="dif:Postal_Code">
						<xsl:value-of select="mm3:contact/mm3:contact_address/mm3:postal_code" />
					</xsl:element>
					<xsl:element name="dif:country">
						<xsl:value-of select="mm3:contact/mm3:contact_address/mm3:country" />
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>


    <xsl:template match="mm3:dataset_citation">
    
        <xsl:element name="dif:Data_Set_Citation">
            <xsl:element name="dif:Dataset_Creator">
                <xsl:value-of select="mm3:dataset_creator" />
            </xsl:element>
            <xsl:element name="dif:Dataset_Editor">
                <xsl:value-of select="mm3:dataset_editor" />
            </xsl:element>
            <xsl:element name="dif:Dataset_Title">
                <xsl:value-of select="mm3:dataset_title" />
            </xsl:element>
            <xsl:element name="dif:Dataset_Series_Name">
                <xsl:value-of select="mm3:dataset_series_name" />
            </xsl:element>
            <xsl:element name="dif:Dataset_Release_Date">
                <xsl:value-of select="mm3:dataset_release_date" />
            </xsl:element>
            <xsl:element name="dif:Dataset_Release_Place">
                <xsl:value-of select="mm3:dataset_release_place" />
            </xsl:element>
            <xsl:element name="dif:Dataset_Publisher">
                <xsl:value-of select="mm3:dataset_publisher" />
            </xsl:element>
            <xsl:element name="dif:Version">
                <xsl:value-of select="mm3:version" />
            </xsl:element>
            <xsl:element name="dif:Data_Presentation_Form">
                <xsl:value-of select="mm3:dataset_presentation_form" />
            </xsl:element>
            <xsl:element name="dif:Online_Resource">
                <xsl:value-of select="mm3:online_resource" />
            </xsl:element>
        
        </xsl:element>
    
    </xsl:template>

</xsl:stylesheet>
