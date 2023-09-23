/*
Last updated 2019-03-12
Author: Jacques Boucher - jjrboucher@gmail.com
Tested with:  Chrome 72
*/

/* 
Google Chrome Query
Runs against the Favicons SQLite file
Extracts favicons information. 

Decoded icon_type is commented out, as the author has not yet confirmed that it's indeed what is found in the source code at:
https://cs.chromium.org/chromium/src/components/favicon_base/favicon_types.h?q=icon_type&g=0&l=86
lines 142-171

If you run this from within DB Browser for SQLite, you can double click on a BLOB for the image_data and select "Image" mode in the lower right pane to see 
the image of the favicon.

*/

/*
References:
https://cs.chromium.org/chromium/src/ui/base/page_transition_types.h

https://cs.chromium.org/chromium/src/components/history/core/browser/history_types.h  (lines 54-60)
*/


SELECT favicons.id,
	icon_mapping.page_url AS 'page URL', 
	favicons.url  AS 'favicon URL', 
	favicon_bitmaps.image_data, 
	(favicon_bitmaps.height || " X " || favicon_bitmaps.width) AS "icon dimensions",
	favicons.icon_type, 

/*  reference: https://cs.chromium.org/chromium/src/components/favicon_base/favicon_types.h?q=icon_type&g=0&l=86, lines 142-172. */
/*
CASE icon_type
	WHEN 0 THEN 'SUCCESS'
	WHEN 1 THEN 'FAILURE_CONNECTION_ERROR'
	WHEN 2 THEN 'FAILURE_HTTP_ERROR'
	WHEN 3 THEN 'FAILURE_HTTP_ERROR_CACHED'
	WHEN 4 THEN 'FAILURE_ON_WRITE'
	WHEN 5 THEN 'DEPRECATED_FAILURE_INVALID'
	WHEN 6 THEN 'FAILURE_TARGET_URL_SKIPPED'
	WHEN 7 THEN 'FAILURE_TARGET_URL_INVALID'
	WHEN 8 THEN 'FAILURE_SERVER_URL_INVALID'
	WHEN 9 THEN 'FAILURE_ICON_EXISTS_IN_DB'
	ELSE 'New value!  Check Chromium source code for meaning'
END AS 'Decoded icon_type',
*/

favicon_bitmaps.last_updated, 
CASE favicon_bitmaps.last_updated
	WHEN 0 THEN 0
	ELSE datetime(favicon_bitmaps.last_updated/1000000-11644473600,'unixepoch','localtime') 
END AS 'Decoded last_udated (local time)',

favicon_bitmaps.last_requested,
CASE favicon_bitmaps.last_requested
	WHEN 0 THEN 0
	ELSE datetime(favicon_bitmaps.last_requested/1000000-11644473600,'unixepoch','localtime')
END AS 'Decoded last_requested (local time)'

FROM 	favicons
			LEFT JOIN favicon_bitmaps ON favicon_bitmaps.icon_id == favicons.id
			LEFT JOIN icon_mapping ON icon_mapping.icon_id == favicons.id
			
WHERE (icon_mapping.page_url  LIKE "%?q=%" OR icon_mapping.page_url  LIKE "%&q=%") AND icon_mapping.page_url LIKE "%www.google%"
