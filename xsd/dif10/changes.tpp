--author thomas.a.cherry@nasa.gov
--title 10.1 to 10.2 changes
--date 2015-09-30
--heading Top level changes
* Removed Dataset_Short_Name
* Removed Dataset_Version
* Spatial_Coverage not repetable
* Renamed ProductLevelID to Processing_Level_ID
* Removed Product_Flag

--newpage
--heading Changes in Fields
Entry_ID
* Moved top level field Version to inside Entry_ID
* added ShortName, content is former content of Entry_ID
---
Geometry
* Spatial_Coverage not repeatable
* Coordinate_System and choices now repeatable
* moved all Altitude and Depth tags to inside Bounding_Rectangle
---
Parent_Metadata
* Dropped, use Metadata_Association
* Metadata_Association Entry_ID contains short name and version
---
Enums
* Added 'Not applicable' to Platfrom Type
* Added 'ON_DEMAND' to Collection Data Type
* Added 'Parent', 'Child', 'Related' to Metadata Association type
* Updated Version
* Dropped the word 'Level' from Processing Level
--newpage
--heading Proposed Changes for 10.3
1 Rename, 3 Depications, 2 Additions, 2 Changes
---
--heading Details
* Rename Product_Level_ID to Processing_Level_ID Entry_ID
* Depricate Product_Flag
* Add optional attributes for document uuid, provider
* Change Paleo_Start_Date and _Stop_Date type from xs:string to DateOrTimeOrEnum
* Depricate Protocol from Related URL
* Depricate Private
* Change Update_Date type from xs:string to xs:date
