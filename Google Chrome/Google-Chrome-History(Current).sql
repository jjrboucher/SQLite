/*
Last updated 2021-12-17
Now includes the field urls.last_visit_time as well as decoded value. Especially useful for entries that have no entry in the visits table.

Author: Jacques Boucher - jjrboucher@gmail.com
Tested with:  Chrome 78, but should work fine with 71, as 
the changes to the earlier query are cosmetics (adding a raw field to the output
and formating an output to a float rather than an integer.

2021-10-10, tested with Chrome 94 and appears to still produce the correct results.

2021-12-17 - tested with Chrome 96 and appears to still produce correct results.
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
	visits.id AS 'visits.id' /* Entries that does not have a corresponding visit in 'visits' table will have a NULL value. Likely a bookmark or related URL*/,
	urls.url,
	urls.title,
	visits.from_visit AS 'from visit',
	urls.visit_count AS 'visit_count',
	urls.typed_count AS 'typed_count',

	visit_source.source,
	/* Checking if activity is locally browsed, synced, or otherwise */
	CASE ifnull(visit_source.source,1)
		WHEN 0 THEN 'Synced'
		WHEN 1 OR visit_source.source IS NULL THEN 'Local'
		WHEN 2 THEN 'Extension'
		WHEN 3 THEN 'Firefox Imported'
		WHEN 4 THEN 'IE Imported'
		WHEN 5 THEN 'Safari Imported'
		ELSE 'New value!: '||visit_source.source||' Check source code for meaning!'
	END AS 'Visit Source',

	transition, 
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

	/* Next series of CASE statements checks the three left bytes of the four byte transition value in the transition value to see what qualifiers apply */
	
	CASE (transition&0x00800000) /* Applies mask to isolate 24th bit from the right */
		WHEN 0x00800000 THEN 'yes' /* bit is set */
	END AS 'URL Blocked',

	CASE (transition&0x01000000) /* Applies mask to isolate 25th bit from the right */
		WHEN 0x01000000 THEN 'yes'  /*bit is set */
	END AS 'Navigated using Forward/Back button',
	
	CASE (transition&0x02000000) /* Applies mask to isolate 26th bit from the right */
		WHEN 0x02000000 THEN 'yes' /* bit is set */
	END AS 'From Address Bar',
	
	CASE (transition&0x04000000) /* Applies mask to isolate 27th bit from the right */
		WHEN 0x04000000 THEN 'yes' /* bit is set */
	END AS 'Navigated to the home page.',

	CASE (transition&0x08000000) /* Applies mask to isolate 28th bit from the right */
		WHEN 0x08000000 THEN 'yes' /* bit is set */
	END AS 'Transaction originated from an external application.',

	CASE (transition&0x10000000) /* Applies mask to isolate 29th bit from the right */
		WHEN 0x10000000 THEN 'yes' /* bit is set */
	END AS 'Beginning of a navigation chain.',

	CASE (transition&0x20000000) /* Applies mask to isolate 30th bit from the right */
		WHEN 0x20000000 THEN 'yes' /* bit is set */
	END AS 'Last transition in a redirect chain.',

	CASE (transition&0x40000000) /* Applies mas to isolate 31st bit from the right */
		WHEN 0x40000000 THEN 'yes' /* bit is set */
	END AS 'Redirects caused by JS.',

	CASE (transition&0x80000000) /* Applies mask to isolate 32nd bit from the right */
		WHEN 0x80000000 THEN 'yes' /* bit is set */
	END AS 'Redirects sent from the server by HTTP headers.',

	/*  This one is redundant to some extent.  It's checking both previous bits to see if any redirect is involved.
		  We could omit this check since the previous two checks are more verbose.
		  The value of using this check is if you want to customize the query with a WHERE statement to look for
		  all redirects (or exclude all redirects for example).
		  
		  It's included in the statement because it's noted in the source code.  Chrome developers must
		  use this as a shortcut to check for redirects rather than individually checking bits 31 & 32.
		  
		  Included in the statement for the sake of consistency with what was noted in the source code.
	*/
	CASE (transition&0xC0000000) /* Applies mask to isolate bits 31-32 from the right */
		WHEN 0xC0000000 THEN 'yes' /* bits are set */
	END AS 'Used to test whether a transition involves a redirect.',

	visit_time,
	CASE /*added CASE check to 2019-12 version of the query*/
		WHEN visit_time is NULL THEN NULL
		ELSE datetime(visit_time/1000000-11644473600,'unixepoch', 'localtime') 
	END AS 'Decoded visit_time (local time)',
	
	CASE last_visit_time
		WHEN 0 THEN NULL
		ELSE last_visit_time
	END AS "last_visit_time",
	
	CASE last_visit_time
		WHEN 0 THEN NULL
		ELSE datetime(last_visit_time/1000000-11644473600,'unixepoch', 'localtime')
	END AS 'Decoded last_visit_time (local time)',

	segments.name AS 'Segment',

	visit_duration, /*added to 2019-12 version of query*/
	CASE /*added to 2019-12 version of the query.*/
		WHEN visit_duration IS NULL THEN NULL /*Checking if it's null.  If yes, don't decode, just display null for decoded value*/
		ELSE printf("%.2f",visit_duration/1000000.0) 
	END AS 'Decoded Visit Duration in seconds', /*minor changes for 2019-12 query:  formatting output, dividing by float to retain float, and text in AS clarified a bit*/

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

ORDER BY visits.visit_time
