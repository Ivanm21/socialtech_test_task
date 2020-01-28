-- Количество регистраций новых пользователей по дням по группам стран; 
SELECT
    DATE(U.date_reg) AS 'Date',
    C.group AS 'Country group',
    COUNT(U.id) AS 'Registrations'
FROM
    `users` U
JOIN `countries` C ON
    C.id = U.id_country
GROUP BY
    C.group,
    DATE(U.date_reg)
ORDER BY
    C.group,
    DATE(U.date_reg)



-- CTR разных типов писем по дням; 
SELECT
    DATE(S.date_sent) AS 'Date',
    S.id_type AS 'Email type',
    ROUND( COUNT(CL.id) / COUNT(S.id_type) * 100, 2) AS 'CTR'
FROM
    `emails_sent` S
LEFT JOIN `emails_clicks` CL ON
    S.id = CL.id_email
GROUP BY
    DATE(S.date_sent),
    S.id_type
ORDER BY
    DATE(S.date_sent),
    S.id_type
    
    
    
    
-- % писем, кликнутых в течение 10 минут после отправки, по типам писем суммарно за последние 7 суток; 
SET @min_after_send := 10;
SET @days := 7;


SELECT
    ES.id_type AS 'Email type',
    ROUND( SUM(CL2.clicked_in_time) / COUNT(CL2.id_click) * 100, 2) AS 'Mails %'
FROM
    `emails_sent` ES
JOIN(
    SELECT
        S.id AS 'id_mail',
    	CL.id AS 'id_click',
        (
            CASE WHEN TIME_TO_SEC(
                TIMEDIFF(CL.date_click, S.date_sent)
            ) / 60 <= @min_after_send THEN 1 ELSE 0
        	END
		) AS 'clicked_in_time'
		FROM `emails_sent` S
		LEFT JOIN `emails_clicks` CL ON S.id = CL.id_email
	) CL2
ON
    CL2.id_mail = ES.id
WHERE
    DATEDIFF(CURDATE(), DATE(ES.date_sent)) <= @days AND DATEDIFF(CURDATE(), DATE(ES.date_sent)) > 0
GROUP BY
    ES.id_type