/*
	Basic query to pull out Firefox history
	Author: Jacques Boucher
	Email: jjrboucher@gmail.com
	Date: February 22, 2026
*/

SELECT 	url,
		title,
		visit_count AS "Visit Count",
		
		visit_type as "Visit Type",
		/* Source: https://searchfox.org/firefox-main/source/toolkit/components/places/nsINavHistoryService.idl
		   starting at line 930
		*/
		CASE visit_type
			WHEN 0 THEN "DEPRICATED"
			WHEN 1 THEN "TRANSITION_LINK - User followed a link" 
			WHEN 2 THEN "TRANSITION_Typed - Typed URL"
			WHEN 3 THEN "TRANSITION_BOOKMARK - Navigated via a bookmark"
			WHEN 4 THEN "TRANSITION_EMBED - Inner content is loaded"
			WHEN 5 THEN "TRANSITION_REDIRECT_PERMANENT - Permanent redirect"
			WHEN 6 THEN "TRANSITION_REDIRECT_TEMPORARY - Temporary redirect"
			WHEN 7 THEN "TRANSITION_DOWNLOAD - Download"
			WHEN 8 THEN "TRANSITION_FRAMED_LINK - User followed a link and got a visit in a frame"
			WHEN 9 THEN "TRANSITION_RELOAD - Page has been reloaded"
			ELSE "NEW VALUE DETECTED! Check source code." 
		END AS "Decoded visit_type",
		
		visit_date,
		DATETIME(visit_date/1000000,'unixepoch') AS "Decoded Visit Date (UTC)"

FROM moz_historyvisits, moz_places 

WHERE place_id = moz_places.id
order by visit_date