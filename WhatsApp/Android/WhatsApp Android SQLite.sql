/* 
  SQLite query for WhatsApp on Android
  Script from https://thebinaryhick.blog/2022/06/09/new-msgstore-who-dis-a-look-at-an-updated-whatsapp-on-android/
*/

SELECT
	message.timestamp, 
	datetime(message.timestamp/1000,'unixepoch') AS "Message Time",

	message.received_timestamp,
	CASE
		WHEN datetime(message.received_timestamp/1000,'unixepoch')="1970-01-01 00:00:00" THEN "N/A"
		ELSE datetime(message.received_timestamp/1000,'unixepoch')
	END AS "Decoded Time Message Received",

	/*wa_contacts.wa_name AS "Other Participant WA User Name",*/

	message.from_me,
	CASE
		WHEN message.from_me=0 THEN "Incoming"
		WHEN message.from_me=1 THEN "Outgoing"
		ELSE 'Unknown value!: '||message.from_me
	END AS "Decoded Message Direction",

	message.message_type,
	CASE
		WHEN message.message_type=0 THEN "Text"
		WHEN message.message_type=1 THEN "Picture"
		WHEN message.message_type=2 THEN "Audio"
		WHEN message.message_type=3 THEN "Video"
		WHEN message.message_type=5 THEN "Static Location"
		WHEN message.message_type=7 THEN "System Message"
		WHEN message.message_type=9 THEN "Document"
		WHEN message.message_type=16 THEN "Live Location"
		ELSE 'Unknown value!: '||message.message_type
	END AS "Decoded Message Type",

	message.text_data AS "Message",
	message_media.file_path AS "Local Path to Media",
	message_media.file_size AS "Media File Size",
	message_location.latitude AS "Shared Latitude/Starting Latitude (Live Location)",
	message_location.longitude AS "Shared Longitude/Starting Longitude (Live Location)",
	message_location.live_location_share_duration AS "Duration Live Location Shared (Seconds)",
	message_location.live_location_final_latitude AS "Final Live Latitude",
	message_location.live_location_final_longitude AS "Final Live Longitude",

	message_location.live_location_final_timestamp,
	datetime(message_location.live_location_final_timestamp/1000,'unixepoch') AS "Decoded Final Location Timestamp"

FROM message

JOIN chat ON chat._id=message.chat_row_id
JOIN jid ON jid._id=chat.jid_row_id
LEFT JOIN message_media ON message_media.message_row_id=message._id
LEFT JOIN message_location ON message_location.message_row_id=message._id
WHERE message.recipient_count=0
ORDER BY "Message Time" ASC