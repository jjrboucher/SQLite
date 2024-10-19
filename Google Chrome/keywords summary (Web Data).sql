/*
This queries the keywords table in the the Web Data SQLite.
It provides you with a summary of the different keywords in the keywords table, including when they 
were created, and when they were last used.

If a user navigates to a site with a search feature on it and does a search, that may result in a new record
added to this table with the date_created field being when they first did a query on that site.

Thus, this query can provide you with some interesting insight about different sites a user accessed and 
conducted searches via a search bar on the site.

One caveat is that at least for Google search engine, the dates don't seem to update to match when a Google
search was last done. It's not clear what triggers that to be updated. But in a test of a site never 
previously navigated that has a search function, upon navigating to that site and conducting a search, it was
correctly added to this table and the timestamps correctly reflected when that took place.

Last modified: 2024-10-19
Author:  Jacques Boucher - jjrboucher@gmail.com
Tested with:  Chrome 129
*/

SELECT	id,
		short_name,
		keyword,
		url,
		date_created,
		CASE date_created
			WHEN 0 THEN ""
			ELSE datetime(date_created/1000000-11644473600,'unixepoch')
		END	AS "Decoded date_created (UTC)",
		keywords.last_modified,
		CASE last_modified
			WHEN 0 THEN ""
			ELSE datetime(last_modified/1000000-11644473600,'unixepoch')
		END AS "Decoded last_modified (UTC)",
		keywords.last_visited,
		CASE last_visited
			WHEN 0 THEN ""
			ELSE datetime(last_visited/1000000-11644473600,'unixepoch')
		END AS "Decoded last_visited (UTC)"
	
FROM keywords