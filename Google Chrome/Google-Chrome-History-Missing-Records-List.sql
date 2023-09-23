/*
Written by Jacques Boucher
email: jjrboucher@gmail.com 
Revision Date: 21 October 2022

Inspired by the research published by Shafiq Punja and Ian Whiffin at https://dfir.pubpub.org/pub/33vkc2ul/release/1
WITH RECURSIVE written with the help of reference at https://www.quora.com/Does-SQLite-support-loops-and-functions

About this script
-----------------
You can run this script against Google Chrome's history file. It will return a list of all visits.id numbers that are missing (gaps in numbering).
It will also detect gaps at the end (where last records where deleted) thanks to the sqlite_sequence.seq value that tracks the last id used in the visits table. 

*/

WITH RECURSIVE
	for(i) AS (VALUES((SELECT MIN(visits.id) AS "Minimum Record" 
						   FROM visits)) /* "for" is the name of the table to give it a semblance of a traditional FOR LOOP in other programming languages 
											Starts the counter at the minimum visits.id value. */
			UNION ALL 
			SELECT i+1 
				FROM for 
				WHERE i < (SELECT sqlite_sequence.seq AS "Maximum Record" 
							   FROM sqlite_sequence 
							   WHERE sqlite_sequence.name LIKE "visits")) /* Counter goes up to the last ID number found in sqlite_sequence. */
	SELECT i AS "Missing Records" 
		FROM for 
		WHERE i NOT IN (SELECT visits.id FROM visits)