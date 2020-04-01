# DIF/UMM Schema #

## Overview ##
To better support UMM GCMD has created a new, proposed, DIF schema with full support of the UMM. This schema includes more modern XSD techniques such as the use of ENUM lists and brings the DIF more in line with ECHO 10 features.

## Files ##
* 10.0 draft copies
	* dif_v10.0a.xsd - dif xsd
	* UmmCommon_0.1a.xsd - enums
	* dif_v10.0b.xsd - dif xsd
	* UmmCommon_0.1b.xsd - enums
	* dif_v10.0c.xsd - dif xsd
	* UmmCommon_0.1c.xsd - enums
* 10.0 Final
	* dif_v10.0.xsd
	* UmmCommon_1.0.xsd
* 10.1
	*  

## Recent Changes ##

* Parent_DIF renamed to Parent_Metadata
    * Added Entry_ID as sub field
    * Added Version as sub field
* Contact_Person or Contact_Person for Contacts
* URLs such as Online_Resource type changed from string to xs:anyURI
* all uuid attribute types changed
* platform type changed from string to enum
* Many dates such as Beginning_Date_Time and MetadataDatesType changed from Date-Enum to Date-Time-Enum
* Dataset_Language changed from string to ENUM
* Metadata_Association/Type changed to enum
* Product_Level_Id changed from string to enum
* Added "Not provided" to Product flag enum
* updated MetadataVersionEnum
* moved PersistentIdentifierType from DIF schema to common schema
* Added date-time-enum type

## URLs ##
* http://gcmd.gsfc.nasa.gov/Aboutus/xml/umm/
* http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/dif_v10.0.xsd - (future)
* https://bugs.earthdata.nasa.gov/browse/CMRQ-300