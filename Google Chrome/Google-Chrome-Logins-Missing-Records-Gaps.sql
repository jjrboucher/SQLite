/*
Written by Jacques Boucher
email: jjrboucher@gmail.com
Revision Date: 21 March 2023

Inspired by the article published by James McGee at https://belkasoft.com/lagging-for-win
The SQLite code in the middle UNION statement is Mr. McGee's statement adapted for Chromium visits (whereas his article was for iMessage sms.db file).


About this script
-----------------
You can run this script against Google Chrome's (or other Chromium based browsers) history file.
It will look for gaps in numbering, and return the gaps along with their timestamps, and the # of records in that gap.

For example, if the visits table contains records 25, 26, 27, 30, 31, 33, 39, this script will return:
27 | 30 | 2 | <timestamp of record #27> | <timestamp of record #30>
31 | 33 | 1 | <timestamp of record #31> | <timestamp of record #33>
33 | 39 | 5 | <timestamp of record #33> | <timestamp of record #39>

The script also checks the table sqlite_sequence. Here you will find a record with the field 'name' with a value of "visits", and the field 'seq' with the last record # allocated to the visits table.
If in the above example the value of sqlite_sequence.seq is 44, the script will also return the following to denote records missing at the end:

33 | Blank ROWID as there are deleted records past the last allocated one. | 4 | <timestamp of record #39> | blank timestamp as we don't have this record>

Note that the script does not look if any records are missing from the beginning.
You can draw your own conclusion on that based on the first record number.

*/

SELECT 
	0 AS "Previous Record Number", /* Had to assign a numerical value to ensure proper sorting with other records. */
	logins.id AS "Record Number", 
	ROWID-1 AS "Number of Missing Visits", /* Because numbering starts at 1, missing records is the first allocated record -1 */
	"" AS "Beginning Date Created Timestamp", /* We don't have a beginning timestamp as we don't have that record */
	DATETIME(logins.date_created/1000000-11644473600,'unixepoch') AS "Ending Date Created Timestamp"  /* Timestamp of the last record */

	FROM logins WHERE logins.id = (SELECT MIN(logins.id) FROM logins) AND logins.id >1 /* The first record # in the visits table is greater than 1.*/

UNION
	
	/* Credit to James McGee and his article at https://belkasoft.com/lagging-for-win for the SQLite statement for this section. */
	SELECT * FROM
	(
		SELECT LAG (ROWID,1) OVER (ORDER BY ROWID) AS "Previous Record Number", /*  Gets the previous record to the current one */
		rowid AS ROWID, /* Current record */
		(ROWID - (LAG (ROWID,1) OVER (ORDER BY ROWID))-1) AS "Number of Missing Visits", /* Calculates the difference between the previous and current record # */
		LAG(DATETIME(logins.date_created/1000000-11644473600,'unixepoch'),1) OVER (ORDER BY ROWID) as "Beginning Date Created Timestamp", /* Gets the timestamp from the previous record */
		DATETIME(logins.date_created/1000000-11644473600,'unixepoch') AS "Ending Date Created Timestamp" /* Gets the timestamp of the current record */
		FROM logins
	)
	WHERE ROWID - "Previous Record Number" >1 /* Only gets the above if the difference between the current record # and previous record # is greater than 1 - in other words, there is a gap in the numbering */
	
	
UNION /* Does a union between the above query and the below one. The below one is to check if there is a gap at the end. Without the below, you won't know if there are records missing at the end. */

SELECT 
	ROWID AS "Previous Record Number", /* Because we are selecting the last allocated record, assigning that to the previous record # */
	"" AS ROWID, /* The last record is missing, thus it's blank */
	(SELECT sqlite_sequence.seq from sqlite_sequence WHERE sqlite_sequence.name LIKE "logins")-ROWID AS "Number of Missing Records", /* Finds the last record # used, and substracts last allocated record # */
	DATETIME(logins.date_created/1000000-11644473600,'unixepoch') AS "Beginning Date Created Timestamp",
	"" AS "Ending Date Created Timestamp"
	FROM logins
	WHERE logins.id = (SELECT MAX(logins.id) FROM logins) /* Only getting the last allocated record. */ AND logins.id < 
		(SELECT sqlite_sequence.seq AS "Maximum Record" 
							   FROM sqlite_sequence 
							   WHERE sqlite_sequence.name LIKE "logins") /* Checking if the last allocated record is smaller than the largest recorded record number. */
							   
