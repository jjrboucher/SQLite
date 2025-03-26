/*
Written by Jacques Boucher
email: jjrboucher@gmail.com
Revision Date: 1 August 2023

Inspired by the article published by James McGee at https://belkasoft.com/lagging-for-win
The SQLite code in the middle UNION statement is Mr. McGee's statement adapted for WhatsApp's ZWAMESSAGE table in ChatStorage.sqlite (whereas his article was for iMessage sms.db file).


About this script
-----------------
You run this script against WhatsApp's msgstore.db file on an Android device.
It will look for gaps in numbering, and return the gaps along with their timestamps, and the # of records in that gap.

For example, if the MESSAGE table contains records 25, 26, 27, 30, 31, 33, 39, this script will return:
27 | 30 | 2 | <timestamp of record #27> | <timestamp of record #30>
31 | 33 | 1 | <timestamp of record #31> | <timestamp of record #33>
33 | 39 | 5 | <timestamp of record #33> | <timestamp of record #39>

The script also checks the table sqlite_sequence. Here you will find a record with the field 'message' with a value of "seq",  the last record # allocated to the MESSAGE table.
If in the above example the value of sqlite_sequence.name for record with name="message" is 44, the script will also return the following to denote records missing at the end:

33 | Blank ROWID as there are deleted records past the last allocated one. | 4 | <timestamp of record #39> | blank timestamp as we don't have this record>

*/

SELECT 
	0 AS "Previous Record Number", /* Had to assign a numerical value to ensure proper sorting with other records. */
	MESSAGE._id AS "Record Number", 
	ROWID-1 AS "Number of Missing Messages",/* Because numbering starts at 1, missing records is the first allocated record -1 */
	"" AS "Lower gap Timestamp (UTC)", /* We don't have a beginning timestamp as we don't have that record */
	DATETIME(MESSAGE.timestamp/1000,'unixepoch') AS "Upper gap Timestamp (UTC)" /* Timestamp of the last record */

	FROM MESSAGE WHERE MESSAGE._id = (SELECT MIN(MESSAGE._id) FROM MESSAGE) AND MESSAGE._id >1 /* The first record # in the ZWAMESSAGE table is greater than 1.*/

UNION
	
	/* Credit to James McGee and his article at https://belkasoft.com/lagging-for-win for the SQLite statement for this section. */
	SELECT * FROM
	(
		SELECT LAG (ROWID,1) OVER (ORDER BY ROWID) AS "Previous Record Number", /*  Gets the previous record to the current one */
		rowid AS ROWID, /* Current record */
		(ROWID - (LAG (ROWID,1) OVER (ORDER BY ROWID))-1) AS "Number of Missing Visits", /* Calculates the difference between the previous and current record # */
		LAG(DATETIME(MESSAGE.timestamp/1000,'unixepoch'),1) OVER (ORDER BY ROWID) as "Lower gap Timestamp (UTC)", /* Gets the timestamp from the previous record */
		DATETIME(MESSAGE.timestamp/1000,'unixepoch') AS "Upper gap Timestamp (UTC)" /* Gets the timestamp of the current record */
		FROM MESSAGE
	)
	WHERE ROWID - "Previous Record Number" >1 /* Only gets the above if the difference between the current record # and previous record # is greater than 1 - in other words, there is a gap in the numbering */
	
	
UNION /* Does a union between the above query and the below one. The below one is to check if there is a gap at the end. Without the below, you won't know if there are records missing at the end. */

SELECT 
	ROWID AS "Previous Record Number", /* Because we are selecting the last allocated record, assigning that to the previous record # */
	"" AS ROWID, /* The last record is missing, thus it's blank */
	(SELECT MESSAGE._id from sqlite_sequence WHERE sqlite_sequence.name LIKE "message")-ROWID AS "Number of Missing Records", /* Finds the last record # used, and substracts last allocated record # */
	DATETIME(MESSAGE.timestamp/1000,'unixepoch') AS "Lower gap Timestamp (UTC)",
	"" AS "Upper gap Timestamp (UTC)"
	
	FROM MESSAGE
	WHERE MESSAGE._id = (SELECT MAX(MESSAGE._id) FROM MESSAGE) /* Only getting the last allocated record. */ AND MESSAGE._id < 
		(SELECT MESSAGE._id AS "Maximum Record" 
							   FROM sqlite_sequence 
							   WHERE sqlite_sequence.name LIKE "message") /* Checking if the last allocated record is smaller than the largest recorded record number. */
							   
