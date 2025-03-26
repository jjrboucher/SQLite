/* 
	Adapted from https://github.com/abdulrahmankhayal/WhatsApp-Messages-DB-Analysis-Using-SQL/blob/main/WhatsApp%20Messages%20DB%20Analysis%20Using%20SQL.ipynb
	
	Reactions
*/
SELECT 
	chat_number,
    COUNT(reaction) AS Total,
	
    SUM (
		CASE
			WHEN reaction = '❤️' THEN 1
            ELSE 0
        END) AS ❤️,
		
    SUM (
		CASE
			WHEN reaction = '😂' THEN 1
            ELSE 0
        END) AS 😂,
		
	SUM (
		CASE
			WHEN reaction = '😢' THEN 1
            ELSE 0
        END) AS 😢,
		
    SUM (
		CASE
			WHEN reaction = '😮' THEN 1
            ELSE 0
        END) AS 😮,
		
    SUM (
		CASE
			WHEN reaction = '👍' THEN 1
            ELSE 0
        END) AS 👍,
		
    SUM (
		CASE
			WHEN reaction NOT IN ( '❤️', '😂', '👍', '😢', '😮' ) THEN 1
            ELSE 0
        END) AS OTHER
	
	FROM
		(SELECT 
			mssg._id,
			mssg.from_me,
		
			CASE mssg.message_type
				WHEN 0 THEN 'text'
				WHEN 1 THEN 'image'
				WHEN 2 THEN 'audio'
				WHEN 3 THEN 'video'
				WHEN 4 THEN 'contact'
				WHEN 5 THEN 'location'
				WHEN 9 THEN 'document'
				WHEN 13 THEN 'gif'
				WHEN 20 THEN 'sticker'
				ELSE 'unknown'
			END AS message_type,
		
			Strftime('%Y-%m-%d %H:%M:%S', mssg.timestamp / 1000.0, 'unixepoch') AS timestamp,
        
			mssg.text_data,
			mssg.starred,
			jid.user,
			jid.user AS chat_number,
			jid1.user AS sender,
			moar.reaction,
			mssg_fd.forward_score,
			mssg_lnk.link_index,
			mssg_md.file_path,
			mssg_md.mime_type,
			media_duration,
			page_count,
			mssg_mnt.message_row_id AS mention_msg_id,
			subject
		
	FROM message AS mssg
	LEFT JOIN chat ON mssg.chat_row_id = chat._id
        LEFT JOIN jid ON chat.jid_row_id = jid._id
        LEFT JOIN jid AS jid1 ON mssg.sender_jid_row_id = jid1._id
        LEFT JOIN message_add_on AS mao ON mssg._id = mao.parent_message_row_id
        LEFT JOIN message_add_on_reaction AS moar ON mao._id = moar.message_add_on_row_id
        LEFT JOIN message_add_on_receipt_device AS moad ON mao._id = moad.message_add_on_row_id
        LEFT JOIN message_forwarded AS mssg_fd ON mssg._id = mssg_fd.message_row_id
        LEFT JOIN message_link AS mssg_lnk ON mssg._id = mssg_lnk.message_row_id
        LEFT JOIN message_media AS mssg_md ON mssg._id = mssg_md.message_row_id
        LEFT JOIN message_mentions AS mssg_mnt ON mssg._id = mssg_mnt.message_row_id
   WHERE  jid.USER <> 'status') AS message_data
			  
WHERE  subject IS NULL
GROUP  BY chat_number
ORDER  BY total DESC