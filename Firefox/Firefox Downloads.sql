/*
	Date: February 22, 2026
	Firefox downloads query.
	Initially authored by Jacques Boucher - jjrboucher@gmail.com
	Subsequently improved by Damien Bloor (Canadian Police College) by using json_extract now that it's supported by SQLite
*/

SELECT 	moz_places.id,
		url, a1.content as "Destination File URI",
		a2.content as "Meta Data",
		json_extract(a2.content,"$.endTime") AS "EndTime UTC",
		datetime(json_extract(a2.content,"$.endTime")/1000,'unixepoch') as "Decoded EndTime UTC",

		json_extract(a2.content,"$.state") AS "Download State",
		CASE json_extract(a2.content,"$.state")
			WHEN  0 THEN "In Progress"
			WHEN  1 THEN "Complete"
			WHEN  3 THEN "Stopped"
			WHEN  4 THEN "Paused"
			ELSE "NEW value detected! Check the source code!"
		END as "Decoded Download State",

		json_extract(a2.content,"$.deleted") AS "Deleted via Firefox",
		CASE json_extract(a2.content,"$.deleted")
			WHEN 0 THEN "No"
			WHEN 1 THEN "Yes"
			ELSE "NEW value detected! Check the source code!"
		End AS "Decoded Deleted via Firefox",

		json_extract(a2.content,"$.fileSize") as "File Size in bytes"

FROM 	moz_places,
		(
			SELECT *
			FROM moz_annos
			WHERE moz_annos.anno_attribute_id=(
												SELECT moz_anno_attributes.id 
												FROM moz_anno_attributes 
												WHERE moz_anno_attributes.name="downloads/destinationFileURI"
												)
		) a1,
		(
			SELECT *
			FROM moz_annos
			WHERE moz_annos.anno_attribute_id=(
												SELECT moz_anno_attributes.id
												FROM moz_anno_attributes
												WHERE moz_anno_attributes.name="downloads/metaData"
												)
		) a2 

WHERE (a1.place_id=a2.place_id) AND a1.place_id=moz_places.id