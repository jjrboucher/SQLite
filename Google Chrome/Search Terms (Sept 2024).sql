        /*
        Requires that you first open Web Data, and then Attach History, giving it the name 'history'.
        See the sub-section titled Search Terms in chapter 4 of the Chrome guide for instructions how to
        do that if unsure.
        
        Last modified: 2024-09-15
        Author:  Jacques Boucher - jjrboucher@gmail.com
        Tested with:  Chrome 128
        */
        
        SELECT	keywords.keyword AS "Search Engine",
            history.urls.url,
            history.keyword_search_terms.term,
            history.urls.visit_count,
            history.urls.last_visit_time,
            datetime(history.urls.last_visit_time/1000000-11644473600,'unixepoch') AS "Decoded history.last_visit_time (UTC)",
			keywords.date_created AS "keywords.date_created",
			CASE keywords.date_created
				WHEN 0 THEN 0
	S		ELSE
				datetime(keywords.date_created/1000000-11644473600,'unixepoch') 
			END AS "Decoded keywords.date_created (UTC)",
			keywords.last_modified AS "keywords.last_modified",
			CASE keywords.last_modified
				WHEN 0 THEN 0
			ELSE
				datetime(keywords.last_modified/1000000-11644473600,'unixepoch') 
			END AS "Decoded keywords.last_modified (UTC)"
             
        FROM history.keyword_search_terms
            LEFT JOIN history.urls ON history.urls.id=history.keyword_search_terms.url_id
            LEFT JOIN keywords ON history.keyword_search_terms.keyword_id=keywords.id
