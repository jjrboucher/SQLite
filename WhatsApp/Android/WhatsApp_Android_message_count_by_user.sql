/* 
	This query makes use of the built in view "messages" in WhatsApp Android msgstore.db file
	It returns a summary of messages exchanged with a given ID.
*/

SELECT 
	messages.key_remote_jid, 
	COUNT(messages.key_remote_jid) AS "Total Messages"

FROM messages 
GROUP BY messages.key_remote_jid
ORDER BY "Total Messages" DESC