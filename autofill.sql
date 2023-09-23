/*
Last modified: 2023-03-14
Author:  Jacques Boucher - jjrboucher@gmail.com
Tested with:  MS Edge v.100.0.1185.44, 110.0.1587.63
	      Chrome v.83.0.4103.116-64, v.111.0.5563.64-64
*/

/* 
Chromium Browser query
Runs against the Webdata SQLite file
Extracts autofill from the autofill table
*/

SELECT name AS "Variable Name",
	value AS "User Input",
	count AS "# of times used",
	date_created,
	datetime(date_created,'unixepoch') AS 'Decoded date_created (UTC)',
	date_last_used,
	datetime(date_last_used,'unixepoch') AS 'Decoded date_last_used (UTC)'

FROM autofill
	
	