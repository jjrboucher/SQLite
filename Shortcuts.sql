/*
Last updated 2019-01-20
Last tested: 2019-11-24
Author:  Jacques Boucher, jjrboucher@gmail.com
Tested with: Chrome 71 and 78
*/

/*
This SQLite statement will query the omni_box_shortcuts table in Google Chrome's Shortcuts SQLite file.

If you want to total up the number of hits for a given domain name, you can add the SUM() function around number_of_hits in the SELECT statement
and drop the text field since you'd only see one of them anyhow using the SUM() function, so no value in displaying it in that context.

i.e. SELECT url, SUM(number_of_hits), last_access_time, ...

and then at the bottom, add the statement

WHERE url LIKE '%domain%'

For example, if you are interested in totalling the number of hits for youtube.com (case insensitive), you'd use the statement

WHERE url LIKE '%youtube.com"%' along with the SUM() function.
*/

SELECT text,
	url,
	number_of_hits,
	last_access_time,
	datetime(last_access_time/1000000-11644473600,'unixepoch', 'localtime') AS "Decoded last_access_time (local time)",
		
	transition,
	CASE (transition)
		WHEN 0 THEN "Clicked on a link"
		WHEN 1 THEN "Typed URL"
		WHEN 2 THEN "Clicked on suggestion in the UI"
		WHEN 3 THEN "Auto subframe navigation"
		WHEN 4 THEN "User manual subframe navigation"
		WHEN 5 THEN "User typed text in URL bar, then selected an entry that did not look like a URL"
		WHEN 6 THEN "Top level navigation"
		WHEN 7 THEN "User submitted form data"
		WHEN 8 THEN "User reloaded page (either hitting ENTER in address bar, or hitting reload button"
		WHEN 9 THEN "URL generated from a replaceable keyword other than default search provider"
		WHEN 10 THEN "Corresponds to a visit generated for a keyword."
        ELSE "New value!: "||transition&0xff||" Check source code for meaning!"
	END AS "Transition Type"

FROM omni_box_shortcuts