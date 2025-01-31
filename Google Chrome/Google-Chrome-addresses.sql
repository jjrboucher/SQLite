/*
Written by Jacques Boucher
Date: 30 Jan 2025

Queries two tables to pull out main artifacts from stored address information.
                
*/
SELECT 	addresses.guid, 
        atk_first_name.value AS "First Name", 
        atk_last_name.value AS "Last Name",
        atk_full_name.value AS "Last Name",
        atk_email.value AS "Email",
        atk_phone.value AS "Phone",
        atk_office.value AS "Office",
		atk_street.value AS "Street",
        atk_city.value AS "City",
        atk_state.value AS "State/Province",
        atk_zip.value AS "Zip/Postal Code",
        atk_country.value AS "Country",
        addresses.use_count, 
        addresses.use_date,
        DATETIME(use_date,'unixepoch') AS "Decoded use_date (UTC)",
        addresses.date_modified,
        DATETIME(date_modified,'unixepoch') AS "Decoded date_modified (UTC)"
FROM addresses
LEFT JOIN (SELECT * FROM address_type_tokens WHERE type == 3 ) AS atk_first_name ON addresses.guid == atk_first_name.guid
LEFT JOIN (SELECT * FROM address_type_tokens WHERE type == 5 ) AS atk_last_name ON addresses.guid == atk_last_name.guid
LEFT JOIN (SELECT * FROM address_type_tokens WHERE type == 7 ) AS atk_full_name ON addresses.guid == atk_full_name.guid
LEFT JOIN (SELECT * FROM address_type_tokens WHERE type == 9 ) AS atk_email ON addresses.guid == atk_email.guid
LEFT JOIN (SELECT * FROM address_type_tokens WHERE type == 14 ) AS atk_phone ON addresses.guid == atk_phone.guid
LEFT JOIN (SELECT * FROM address_type_tokens WHERE type == 77 ) AS atk_street ON addresses.guid == atk_street.guid
LEFT JOIN (SELECT * FROM address_type_tokens WHERE type == 33 ) AS atk_city ON addresses.guid == atk_city.guid
LEFT JOIN (SELECT * FROM address_type_tokens WHERE type == 34 ) AS atk_state ON addresses.guid == atk_state.guid
LEFT JOIN (SELECT * FROM address_type_tokens WHERE type == 35 ) AS atk_zip ON addresses.guid == atk_zip.guid
LEFT JOIN (SELECT * FROM address_type_tokens WHERE type == 36 ) AS atk_country ON addresses.guid == atk_country.guid
LEFT JOIN (SELECT * FROM address_type_tokens WHERE type == 60 ) AS atk_office ON addresses.guid == atk_office.guid