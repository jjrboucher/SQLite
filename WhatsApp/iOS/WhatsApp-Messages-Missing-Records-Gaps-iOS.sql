/*
Written by Jacques Boucher
email: jjrboucher@gmail.com
Revision Date: 17 April 2023

Inspired by the article published by James McGee at https://belkasoft.com/lagging-for-win
The SQLite code in the middle UNION statement is Mr. McGee's statement adapted for WhatsApp's ZWAMESSAGE table in ChatStorage.sqlite (whereas his article was for iMessage sms.db file).


About this script
-----------------
You run this script against WhatsApp's ChatStorage.sqlite file on an iOS device.
It will look for gaps in numbering, and return the gaps along with their timestamps, and the # of records in that gap.

For example, if the ZWAMESSAGE table contains records 25, 26, 27, 30, 31, 33, 39, this script will return:
27 | 30 | 2 | <timestamp of record #27> | <timestamp of record #30>
31 | 33 | 1 | <timestamp of record #31> | <timestamp of record #33>
33 | 39 | 5 | <timestamp of record #33> | <timestamp of record #39>

The script also checks the table Z_PRIMARYKEY. Here you will find a record with the field 'WAMessage' with a value of "Z_MAX",  the last record # allocated to the ZWAMESSAGE table.
If in the above example the value of Z_PRIMARYKEY.Z_MAX for record with Z_NAME="WAMessage" is 44, the script will also return the following to denote records missing at the end:

33 | Blank ROWID as there are deleted records past the last allocated one. | 4 | <timestamp of record #39> | blank timestamp as we don't have this record>

*/

SELECT 
	0 AS "Previous Record Number", /* Had to assign a numerical value to ensure proper sorting with other records. */
	ZWAMESSAGE.Z_PK AS "Record Number", 
	ROWID-1 AS "Number of Missing Messages",/* Because numbering starts at 1, missing records is the first allocated record -1 */
	"" AS "Beginning Message Timestamp", /* We don't have a beginning timestamp as we don't have that record */
	"" AS "Beginning Sent Timestamp", /* We don't have a beginning timestamp as we don't have that record */
	DATETIME(ZWAMESSAGE.ZMESSAGEDATE+978307200,'unixepoch') AS "Ending Message Timestamp",  /* Timestamp of the last record */
	DATETIME(ZWAMESSAGE.ZSENTDATE+978307200,'unixepoch') AS "Ending Sent Timestamp" /* Timestampe of the last record */

	FROM ZWAMESSAGE WHERE ZWAMESSAGE.Z_PK = (SELECT MIN(ZWAMESSAGE.Z_PK) FROM ZWAMESSAGE) AND ZWAMESSAGE.Z_PK >1 /* The first record # in the ZWAMESSAGE table is greater than 1.*/

UNION
	
	/* Credit to James McGee and his article at https://belkasoft.com/lagging-for-win for the SQLite statement for this section. */
	SELECT * FROM
	(
		SELECT LAG (ROWID,1) OVER (ORDER BY ROWID) AS "Previous Record Number", /*  Gets the previous record to the current one */
		rowid AS ROWID, /* Current record */
		(ROWID - (LAG (ROWID,1) OVER (ORDER BY ROWID))-1) AS "Number of Missing Visits", /* Calculates the difference between the previous and current record # */
		LAG(DATETIME(ZWAMESSAGE.ZMESSAGEDATE+978307200,'unixepoch'),1) OVER (ORDER BY ROWID) as "Beginning Message Timestamp", /* Gets the timestamp from the previous record */
		LAG(DATETIME(ZWAMESSAGE.ZSENTDATE+978307200,'unixepoch'),1) OVER (ORDER BY ROWID) as "Beginning Sent Timestamp", /* Gets the timestamp from the previous record */
		DATETIME(ZWAMESSAGE.ZMESSAGEDATE+978307200,'unixepoch') AS "Ending Message Timestamp", /* Gets the timestamp of the current record */
		DATETIME(ZWAMESSAGE.ZSENTDATE+978307200,'unixepoch') AS "Ending Sent Timestamp" /* Gets the timestamp of the current record */
		FROM ZWAMESSAGE
	)
	WHERE ROWID - "Previous Record Number" >1 /* Only gets the above if the difference between the current record # and previous record # is greater than 1 - in other words, there is a gap in the numbering */
	
	
UNION /* Does a union between the above query and the below one. The below one is to check if there is a gap at the end. Without the below, you won't know if there are records missing at the end. */

SELECT 
	ROWID AS "Previous Record Number", /* Because we are selecting the last allocated record, assigning that to the previous record # */
	"" AS ROWID, /* The last record is missing, thus it's blank */
	(SELECT ZWAMESSAGE.Z_PK from Z_PRIMARYKEY WHERE Z_PRIMARYKEY.Z_NAME LIKE "WAMessage")-ROWID AS "Number of Missing Records", /* Finds the last record # used, and substracts last allocated record # */
	DATETIME(ZWAMESSAGE.ZMESSAGEDATE+978307200,'unixepoch') AS "Beginning Message Timestamp",
	DATETIME(ZWAMESSAGE.ZSENTDATE+978307200,'unixepoch') AS "Beginning Sent Timestamp",
	"" AS "Ending Message Timestamp",
	"" AS "Ending Sent Timestamp"
	
	FROM ZWAMESSAGE
	WHERE ZWAMESSAGE.Z_PK = (SELECT MAX(ZWAMESSAGE.Z_PK) FROM ZWAMESSAGE) /* Only getting the last allocated record. */ AND ZWAMESSAGE.Z_PK < 
		(SELECT ZWAMESSAGE.Z_PK AS "Maximum Record" 
							   FROM Z_PRIMARYKEY 
							   WHERE Z_PRIMARYKEY.Z_NAME LIKE "WAMessage") /* Checking if the last allocated record is smaller than the largest recorded record number. */
							   
