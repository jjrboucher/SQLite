/*
Date: February 22, 2026
Author: Jacques Boucher
Email: jjrboucher@gmail.com

Simple query to pull out input text that a user typed in the address bar

*/

SELECT	input,
		use_count,
		url, title,
		visit_count,
		last_visit_date,
		datetime(last_visit_date/1000000,'unixepoch') AS "Decoded Last Visit Date (UTC)" 

FROM	moz_inputhistory,
		moz_places
WHERE place_id = moz_places.id