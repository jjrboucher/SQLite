/*
Written by Jacques Boucher
email: jjrboucher@gmail.com
Revision Date: 21 October 2022

Inspired by the research published by Shafiq Punja and Ian Whiffin at https://dfir.pubpub.org/pub/33vkc2ul/release/1

About this script
-----------------
You can run this script against Google Chrome's history file to get a snapshot of how many records are contained within it,
and based on incremental record numbering, how many records appear to be missing.
Note that the script does not look if any records are missing from the beginning.
You can draw your own conclusion on that based on the first record number.

*/
SELECT "First Record", "Last Record", "Maximum Record", "Total Records", ("Maximum Record"-"First Record")+1-"Total Records" AS "Missing Records"
FROM (SELECT MIN(visits.id) AS "First Record" from visits), /* Gets the minimum id # */
	 (SELECT MAX(visits.id) AS "Last Record" from visits), /* Gets the maximum id #. */
	 (SELECT sqlite_sequence.seq AS "Maximum Record" from sqlite_sequence WHERE sqlite_sequence.name LIKE "visits"), /* Gets the last record number in sqlite_sequence to detect if any are missing after the last allocated record */
	 (SELECT COUNT(visits.id) AS "Total Records" from visits) /* Counts the number of existing records in the table */