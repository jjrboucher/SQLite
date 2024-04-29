/*
Last updated 2019-01-17
Author: Jacques Boucher - jjrboucher@gmail.com
Tested with:  Chrome 71
*/

/* 
Google Chrome Query
Runs against the History SQLite file
Extracts all visits as well as entries in urls with no visits (result of bookmarks for which no urls exist in the 'visits' table.
Remember that Chrome only keeps the last 3 months of history.  So a user could bookmark a site they surfed.  But if they
don't navigate back to it for more than 3 months, it will disappear from the 'visits' table, but it will persist in the 'urls' table
because of the bookmark that exists for it.
Presumably Chrome prepopulates the 'urls' table with bookmarks so that when a user is typing in the omnibox and Chrome looks
to see if that URL exsits in the 'urls' table, it's also checking bookmarks by having those populated in there.
*/

/*
References:
https://cs.chromium.org/chromium/src/ui/base/page_transition_types.h

https://cs.chromium.org/chromium/src/components/history/core/browser/history_types.h  (lines 54-60)
*/

/*
In testing using Chrome 71, there is a field called incremented_omnibox_typed_score in the 
visits table.  It's not included in the SQLite statement below, as the author observed what appeared to be conflicting rules for when it was populated.  Plus at the time of testing, a computer forensic analyst would be able to form a proper opinion using what's 
already being reported using this statement.
*/

SELECT  DISTINCT /* If you don't use the DISTINCT statement, you will end up with duplicate records because of the JOIN of multiple tables */
	urls.id AS 'urls.id', 
	visits.id AS 'visits.id' /* Bookmark that does not have a corresponding visit in 'visits' table will have a NULL value */,
	urls.url,
	urls.title,
/*	visits.from_visit AS 'from visit', */
	urls.visit_count AS 'visit_count',
/*	urls.typed_count AS 'typed_count', */

/*	visit_source.source,*/
	/* Checking if activity is locally browsed, synced, or otherwise */
	CASE visit_source.source
		WHEN 0 THEN 'Synced'
		WHEN 1 OR visit_source.source IS NULL THEN 'Local'
		WHEN 2 THEN 'Extension'
		WHEN 3 THEN 'Firefox Imported'
		WHEN 4 THEN 'IE Imported'
		WHEN 5 THEN 'Safari Imported'
		ELSE 'New value!: '||visit_source.source||' Check source code for meaning!'
	END AS 'Visit Source',

/*	transition, */
	/* Checking the value of the right most byte of the four byte transition value and decoding it */
	CASE (transition&0xff)
		WHEN 0 THEN 'Clicked on a link'
        	WHEN 1 THEN 'Typed URL'
        	WHEN 2 THEN 'Clicked on suggestion in the UI'
        	WHEN 3 THEN 'Auto subframe navigation'
        	WHEN 4 THEN 'User manual subframe navigation'
        	WHEN 5 THEN 'User typed text in URL bar, then selected an entry that did not look like a URL'
        	WHEN 6 THEN 'Top level navigation'
        	WHEN 7 THEN 'User submitted form data'
        	WHEN 8 THEN 'User reloaded page (either hitting ENTER in address bar, or hitting reload button'
        	WHEN 9 THEN 'URL generated from a replaceable keyword other than default search provider'
        	WHEN 10 THEN 'Corresponds to a visit generated for a keyword.'
        	ELSE 'New value!: '||transition&0xff||' Check source code for meaning!'
	END AS 'Transition Type',


	visit_time,
	datetime(visit_time/1000000-11644473600,'unixepoch', 'localtime') AS 'Decoded visit_time (local time)', 
	term 

FROM	urls
	LEFT JOIN visits ON visits.url=urls.id
	LEFT JOIN segments ON visits.segment_id=segments.id
	LEFT JOIN keyword_search_terms ON keyword_search_terms.url_id=urls.id
	LEFT JOIN visit_source ON visit_source.id=visits.id

/*
a few suggested optional commands could be to only display URLs where visit duration is greater than 0, and/or you could display only URLs where there is a corresponding keyword term.
*/

/*
If you want all URL browsing activity in the visits table that denotes user action
you could use a condition as follows:
WHERE transition&0xff IN (0,1,2,5,7) 
Change values (0-10) to filter on desired interactions as per the 'CASE (transition&0xff)' statement
*/

/*
Look for all URLs where it invovled a user search (whether search engine, or search box on a site.
WHERE  term NOT NULL
*/

/*
Look for URLs from form data activity
WHERE "Transition Type"="User submitted form data"
*/

/* 
or if you only want to see what is local
WHERE 'Visit Source' = 'Local'
*/

/*WHERE urls.url LIKE "%godaddy%" OR urls.url LIKE "%marble%" AND visit_count>0*/

ORDER BY visits.visit_time
