/*
Last updated: 2019-01-17
Author:  Jacques Boucher - jjrboucher@gmail.com
Tested with: Chome 71
*/


/* 
Google Chrome Query
Runs against the History SQLite file
Extracts list of downloaded files.
Downloads - Complex SQLite Statement
*/

SELECT downloads.id, chains.chain_index AS "chain_index", current_path, target_path, start_time, datetime(start_time/1000000-11644473600,'unixepoch', 'localtime') AS "Decoded start_time (local time)",

end_time,
CASE
   WHEN end_time>0 THEN datetime(end_time/1000000-11644473600,'unixepoch','localtime')
   ELSE 0
END AS "Decoded end_time (local time)",

last_access_time,
CASE 
   WHEN last_access_time>0 THEN datetime(last_access_time/1000000-11644473600,'unixepoch','localtime')
   ELSE 'Not opened via Chrome'
END AS "Decoded last_access_time (local time)",

last_modified, referrer,
site_url, tab_url, tab_referrer_url,

state,
CASE state 
   WHEN 1 THEN "Complete" 
   WHEN 2 THEN "Interrupted"
   ELSE state
END AS "Decoded state",

interrupt_reason,
CASE interrupt_reason
   WHEN 0 THEN "Not Interrupted"
   WHEN 1 THEN "File Error"
   WHEN 2 THEN "Access Denied"
   WHEN 3 THEN "Disk Full"
   WHEN 5 THEN "Path Too Long"
   WHEN 6 THEN "File Too Large"
   WHEN 7 THEN "Virus"
   WHEN 10 THEN "Temporary Problem"
   WHEN  11 THEN "Blocked"
   WHEN 12 THEN "File Security Check Failed"
   WHEN 13 THEN "On resume, file too short"
   WHEN 14 THEN "Hash Mismatch"
   WHEN 20 THEN "Network Error"
   WHEN 21 THEN "Operation Timed Out"
   WHEN 22 THEN "Connection Lost"
   WHEN 23 THEN "Server Down"
   WHEN 24 THEN "Network Invalid Request"
   WHEN 30 THEN "Server Failed"
   WHEN 31 THEN "Server does not support range requests"
   WHEN 32 THEN "Obsolete (shouldn't see this error"
   WHEN 33 THEN "Unable to get file"
   WHEN 34 THEN "Server didn't authorize access"
   WHEN 35 THEN "Server Certificate Problem"
   When 36 THEN "Server access forbidden"
   WHEN 37 THEN "Server Unreachable"
   WHEN 40 THEN "User canceled the download"
   WHEN 41 THEN "User shut down the browser"
   WHEN 50 THEN "Browser crashed"
   ELSE "New value!: "||interrupt_reason||" Check source code for meaning!"
END AS "Decoded interrupt_reason",

chains.url AS "Download Source"

FROM downloads
	JOIN (SELECT id, chain_index, url from downloads_url_chains) AS chains

WHERE chains.id=downloads.id

ORDER by downloads.id, start_time