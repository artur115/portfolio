SELECT *
FROM (
	SELECT dts,
		CASE
			WHEN miliseconds1 < 500
				THEN 'Not Humanly Possible'
			WHEN miliseconds1 >= 500
				AND miliseconds1 < 1000
				THEN "Very difficult 0,5 sec to 1 sec"
			ELSE "Looks like human"
			END AS click_speed,
		count(DISTINCT ip) AS unique_clickers,
		COUNT(DISTINCT lead1) AS qantity_of_too_fast_2nd_clicks
	FROM (
		SELECT *,
			Cast(EXTRACT(MILLISECOND FROM TIMESTAMP (lead1) AT TIME ZONE "UTC") - EXTRACT(MILLISECOND FROM ts AT TIME ZONE "UTC") AS NUMERIC) AS miliseconds1,
			EXTRACT(MILLISECOND FROM TIMESTAMP (lead2) AT TIME ZONE "UTC") - EXTRACT(MILLISECOND FROM TIMESTAMP (lead1) AT TIME ZONE "UTC") AS miliseconds2,
			(EXTRACT(MILLISECOND FROM TIMESTAMP (lead1) AT TIME ZONE "UTC") - EXTRACT(MILLISECOND FROM ts AT TIME ZONE "UTC")) / 1000 AS seconds1,
			(EXTRACT(MILLISECOND FROM TIMESTAMP (lead2) AT TIME ZONE "UTC") - EXTRACT(MILLISECOND FROM TIMESTAMP (lead1) AT TIME ZONE "UTC")) / 1000 AS seconds2
		FROM (
			SELECT *,
				LEAD(ts, 1) OVER (
					PARTITION BY dts,
					ip ORDER BY ts
					) lead1,
				LEAD(ts, 2) OVER (
					PARTITION BY dts,
					ip ORDER BY ts
					) lead2,
			FROM (
				SELECT ip,
					ts,
					DATE (ts) AS dts
				FROM `Click`
				WHERE DATE (ts) >= DATE_ADD(CURRENT_DATE (), INTERVAL - 10 DAY)
					AND ignoreBilling IS NULL -- mandatory rule to see wrong clicks
				ORDER BY dts
				) t1
			) leads
		) calleads
	-- where miliseconds1 <1000
	GROUP BY dts,
		CASE
			WHEN miliseconds1 < 500
				THEN "Not Humanly Possible"
			WHEN miliseconds1 >= 500
				AND miliseconds1 < 1000
				THEN "Very difficult 0,5 sec to 1 sec"
			ELSE "Looks like human"
			END
	)
ORDER BY dts DESC,
	unique_clickers DESC
