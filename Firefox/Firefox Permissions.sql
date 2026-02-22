/*
	SQLite written by Claude.ai
	Partially validated by Jacques Boucher
	email: jjrboucher@gmail.com
	Date: February 22, 2026
*/
SELECT
    id,
    origin,
    type AS permission_type,
    CASE type
        WHEN 'cookie'               THEN 'Cookie'
        WHEN 'popup'                THEN 'Popup'
        WHEN 'install'              THEN 'Install Add-ons'
        WHEN 'geo'                  THEN 'Geolocation'
        WHEN 'desktop-notification' THEN 'Desktop Notification'
        WHEN 'camera'               THEN 'Camera'
        WHEN 'microphone'           THEN 'Microphone'
        WHEN 'screen'               THEN 'Screen Sharing'
        WHEN 'speaker'              THEN 'Speaker Selection'
    END AS category,
    permission AS permission_raw,
    CASE
        -- Cookie-specific values (from nsICookiePermission.idl)
        WHEN type = 'cookie' THEN
            CASE permission
                WHEN 1  THEN 'Allow'
                WHEN 2  THEN 'Deny'
                WHEN 8  THEN 'Allow for Session'
                WHEN 9  THEN 'Allow First-Party Only'
                WHEN 10 THEN 'Limit Third-Party'
                ELSE 'NEW VALUE DETECTED! (' || permission || ') Check source code.'
            END
        -- All other types use nsIPermissionManager values
        ELSE
            CASE permission
                WHEN 1 THEN 'Allow'
                WHEN 2 THEN 'Deny'
                WHEN 3 THEN 'Prompt'
                ELSE 'Unknown (' || permission || ')'
            END
    END AS permission_decoded,
	modificationTime,
    datetime(modificationTime/1000, 'unixepoch') AS "Decoded modified_time (UTC)",
    datetime(expireTime/1000, 'unixepoch')       AS "Decoded expire_time (UTC)"

FROM moz_perms
WHERE type IN (
    'cookie',
    'popup',
    'install',
    'geo',
    'desktop-notification',
    'camera',
    'microphone',
    'screen',
    'speaker'
)
ORDER BY type, origin;