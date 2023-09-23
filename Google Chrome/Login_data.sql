/*
Last updated 2019-01-17
Author: Jacques Boucher - jjrboucher@gmail.com
Tested with:  Chrome 71
*/

/* 
Google Chrome Query
Runs against the Login Data SQLite file
*/

SELECT signon_realm,
	origin_url,
	username_value, 
	
	preferred,
	CASE preferred
		WHEN 1 THEN 'TRUE' /*will always be 1 if it's the only password saved for that site*/
		WHEN 0 THEN 'FALSE'
		ELSE 'unknown value'
	END AS 'Last one used for this site?',

	date_created,
	datetime(date_created/1000000-11644473600,'unixepoch', 'local time') AS 'Decoded date_created (local time)',
	date_synced, 

	CASE date_synced
		WHEN 0 THEN 'local'
		ELSE datetime(date_synced/1000000-11644473600,'unixepoch', 'localtime')
	END AS 'Decoded date_synced (local time)', 

	times_used,
	form_data,
	display_name,

	blacklisted_by_user,
	CASE blacklisted_by_user
		WHEN 1 THEN 'TRUE'
		WHEN 0 THEN 'FALSE'
		ELSE 'unknown value'
	END AS 'Blacklisted by user',

/* You can optionally exclude the scheme if not relevant.  If doing so, remove the comma after the above as that become the last field in the query. */
	scheme,
	CASE scheme
		WHEN 0 THEN 'HTML (Default)'
		WHEN 1 THEN 'BASIC'
		WHEN 2 THEN 'DIGEST'
		WHEN 3 THEN 'OTHER'
		WHEN 4 THEN 'USERNAME ONLY'
		ELSE 'unknown value'
	END AS 'Type of input form'

FROM logins

ORDER by times_used DESC