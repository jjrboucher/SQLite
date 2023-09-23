/*
Last modified: 2019-01-17 (added comments, cleaned up formatting of query)
Author:  Jacques Boucher - jjrboucher@gmail.com
Tested with:  Chrome 71 and 78
*/

/* 
Google Chrome Query
Runs against the Webdata SQLite file
Extracts autofill information from several tables and aggregates the data based on guid values.
*/

SELECT use_count,
	origin,
	date_modified,
	datetime(date_modified,'unixepoch') AS 'Decoded date_modified (UTC)',
	use_date,  datetime(use_date,'unixepoch') AS 'Decoded use_date (UTC)',
	autofill_profiles.guid,
	full_name,
	first_name,
	middle_name,
	last_name,
	street_address,
	city, state,
	zipcode,
	country_code,
	number, email

FROM autofill_profile_names
	JOIN autofill_profiles ON autofill_profiles.guid == autofill_profile_names.guid 
	JOIN autofill_profile_phones ON autofill_profiles.guid == autofill_profile_phones.guid 
	JOIN autofill_profile_emails ON autofill_profiles.guid == autofill_profile_emails.guid