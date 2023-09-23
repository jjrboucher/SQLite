/*
Last updated 2023-01-13
Author: Jacques Boucher - jjrboucher@gmail.com
Tested on Chrome v.108 and Edge v.101
*/

/* 
Google Chrome Query
Runs against the Login Data SQLite file
*/

SELECT signon_realm,
	origin_url,
	username_value, 
	date_created,
	datetime(date_created/1000000-11644473600,'unixepoch') AS 'Decoded date_created (UTC)',
	date_last_used,
	CASE date_last_used
		WHEN 0 THEN 'Synched. Not used on this device.'
		ELSE datetime(date_last_used/1000000-11644473600,'unixepoch') 
	END AS 'Decoded date_last_used (UTC)',
		date_last_used,
	CASE date_password_modified
		WHEN 0 THEN 'Never'
		ELSE datetime(date_password_modified/1000000-11644473600,'unixepoch') 
	END AS 'Decoded date_password_modified (UTC)',
	times_used AS "# of times saved password used",
	display_name,

	blacklisted_by_user,
	CASE blacklisted_by_user
		WHEN 1 THEN 'TRUE'
		WHEN 0 THEN 'FALSE'
		ELSE 'unknown value'
	END AS 'Decoded blacklisted_by_user (TRUE means do not save the password for this site)',

	password_type,
	
	/* 
	password_type reference:
	https://source.chromium.org/chromium/chromium/src/+/main:components/password_manager/core/browser/password_manager_metrics_util.h;l=345?q=PRIMARY_ACCOUNT_PASSWORD&ss=chromium%2Fchromium%2Fsrc 
	" // Passwords saved by password manager.
	  SAVED_PASSWORD = 0,
	  // Passwords used for Chrome sign-in and is closest ("blessed") to be set to
	  // sync when signed into multiple profiles if user wants to set up sync.
	  // The primary account is equivalent to the "sync account" if this profile has
	  // enabled sync.
	  PRIMARY_ACCOUNT_PASSWORD = 1,
	  // Other Gaia passwords used in Chrome other than the sync password.
	  OTHER_GAIA_PASSWORD = 2,
	  // Passwords captured from enterprise login page.
	  ENTERPRISE_PASSWORD = 3,
	  // Unknown password type. Used by downstream code to indicate there was not a
	  // password reuse.
	  PASSWORD_TYPE_UNKNOWN = 4"
	*/
	CASE password_type
		WHEN 0 THEN 'Saved by password manager.'
		WHEN 1 THEN 'Will sync if sync is enabled.'
		WHEN 2 THEN 'Passwords other than Synced ones.'
		WHEN 3 THEN 'Captured from enterprise login page.'
		WHEN 4 THEN 'Unknown type.'
		ELSE 'Unknown value. Check Chromium source code!'
	END AS 'Decoded password_type',
	
/* You can optionally exclude the scheme if not relevant.  If doing so, remove the comma after the above as that become the last field in the query. */
	scheme,
	CASE scheme
		WHEN 0 THEN 'HTML (Default)'
		WHEN 1 THEN 'BASIC'
		WHEN 2 THEN 'DIGEST'
		WHEN 3 THEN 'OTHER'
		WHEN 4 THEN 'USERNAME ONLY'
		ELSE 'unknown value'
	END AS 'Decoded type of input form'

FROM logins

ORDER by times_used DESC