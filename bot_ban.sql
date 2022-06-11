#legacySQL

SELECT CURRENT_TIMESTAMP() AS ban_ts,
	bans.emd5 AS emd5,
	update_timestamp,
	n_emails_sent,
	user_lifespan,
	ROUND(open_rate, 5) AS open_rate,
	ROUND(recent_open_rate, 5) AS recent_open_rate,
	CASE
		WHEN (
				open_rate >= 0.5
				AND recent_open_rate >= 0.5
				)
			THEN 'open rate >= 50%'
		WHEN (
				open_rate >= 0.4
				AND recent_open_rate >= 0.4
				)
			THEN 'open rate >= 40%'
		WHEN (
				open_rate >= 0.3
				AND recent_open_rate >= 0.3
				)
			THEN 'open rate >= 30%'
		WHEN (
				open_rate >= 0.2
				AND recent_open_rate >= 0.2
				)
			THEN 'open rate >= 20%'
		WHEN (
				open_rate >= 0.1
				AND recent_open_rate >= 0.1
				)
			THEN 'open rate >= 10%'
		END AS discrete_open_rate
FROM (
	SELECT emd5,
		MAX(update_timestamp) AS update_timestamp,
		MIN(creation_timestamp) AS creation_timestamp,
		FLOOR(MAX(update_timestamp) - MIN(creation_timestamp)) / (1000000 * 60 * 60 * 24) AS user_lifespan,
		MAX(n_emails_sent) AS n_emails_sent,
		MAX(n_open) AS n_open,
		SUM(last_updates.n_emails_sent) AS n_emails_sent_recently,
		(MAX(update_timestamp) - MAX(last_click_ts)) / (1000000 * 60 * 60 * 24) AS days_since_last_click,
		(MAX(update_timestamp) - MAX(last_emc_click_ts)) / (1000000 * 60 * 60 * 24) AS days_since_last_emc_click,
		(MAX(update_timestamp) - MAX(last_page_view_ts)) / (1000000 * 60 * 60 * 24) AS days_since_last_pageview,
		MAX(n_open) / MAX(n_emails_sent) AS open_rate,
		SUM(last_updates.n_open) / SUM(last_updates.n_emails_sent) AS recent_open_rate
	FROM [rm-data:User.UserProfile]
	WHERE _PARTITIONTIME >= DATE_ADD(CURRENT_TIMESTAMP(), - 60, 'DAY')
	GROUP BY emd5
	) AS bans
LEFT JOIN (
	SELECT emd5
	FROM [rm-data:User.BotBanS1]
	WHERE _PARTITIONTIME >= DATE_ADD(CURRENT_TIMESTAMP(), - 60, 'DAY')
	GROUP BY emd5
	) AS already_banned ON bans.emd5 = already_banned.emd5
WHERE already_banned.emd5 IS NULL
	AND user_lifespan > 60
	AND n_emails_sent > 100
	AND open_rate >= 0.3
	AND recent_open_rate >= 0.3
	AND days_since_last_click IS NULL
	AND days_since_last_emc_click IS NULL
	AND days_since_last_pageview IS NULL
	AND n_emails_sent_recently > 5;
