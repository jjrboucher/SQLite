/*
Written by Jacques Boucher
email: jjrboucher@gmail.com
Revision Date: 22 March 2023

Inspired by the article published by James McGee at https://belkasoft.com/lagging-for-win
The SQLite code in the middle UNION statement is Mr. McGee's statement adapted for Chromium visits (whereas his article was for iMessage sms.db file).


About this script
-----------------
You can run this script against Google Chrome's (or other Chromium based browsers) Web Data file.
It will look for gaps in numbering for autofill_profiles, and return the gaps along with their timestamps (for start time of download), and the # of records in that gap.

For example, if the visits table contains records 25, 26, 27, 30, 31, 33, 39, this script will return:
27 | 30 | 2 | <timestamp of record #27> | <timestamp of record #30>
31 | 33 | 1 | <timestamp of record #31> | <timestamp of record #33>
33 | 39 | 5 | <timestamp of record #33> | <timestamp of record #39>

The script can't check for gaps at the end, because the last used record number is not stored in sqlite_sequence.seq.

Note that the script does not look if any records are missing from the beginning.
You can draw your own conclusion on that based on the first record number.

*/

SELECT 
	0 AS "Previous Record Number", /* Had to assign a numerical value to ensure proper sorting with other records. */
	ROWID AS "Record Number", 
	ROWID-1 AS "Number of Missing Visits", /* Because numbering starts at 1, missing records is the first allocated record -1 */
	"" AS "Beginning Timestamp", /* We don't have a beginning timestamp as we don't have that record */
	DATETIME(autofill_profiles.use_date,'unixepoch') AS "Ending Timestamp"  /* Timestamp of the last record */

	FROM autofill_profiles WHERE ROWID = (SELECT MIN(ROWID) FROM autofill_profiles) AND ROWID >1 /* The first record # in the visits table is greater than 1.*/

UNION
	
	/* Credit to James McGee and his article at https://belkasoft.com/lagging-for-win for the SQLite statement for this section. */
	SELECT * FROM
	(
		SELECT LAG (ROWID,1) OVER (ORDER BY ROWID) AS "Previous Record Number", /*  Gets the previous record to the current one */
		rowid AS ROWID, /* Current record */
		(ROWID - (LAG (ROWID,1) OVER (ORDER BY ROWID))-1) AS "Number of Missing Visits", /* Calculates the difference between the previous and current record # */
		LAG(DATETIME(autofill_profiles.use_date,'unixepoch'),1) OVER (ORDER BY ROWID) as "Beginning Timestamp", /* Gets the timestamp from the previous record */
		DATETIME(autofill_profiles.use_date,'unixepoch') AS "Ending Timestamp" /* Gets the timestamp of the current record */
		FROM autofill_profiles
	)
	WHERE ROWID - "Previous Record Number" >1 /* Only gets the above if the difference between the current record # and previous record # is greater than 1 - in other words, there is a gap in the numbering */
