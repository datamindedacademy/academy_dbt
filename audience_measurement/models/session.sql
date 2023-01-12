WITH timestamp_events AS (
    SELECT
        users as users,
        channel as channel,
        time as timestamp
    FROM {{ source('training', 'timestamps') }}
),
     sessions AS(
         SELECT
             users,
             channel,
             timestamp as beginning,
             LEAD(timestamp) OVER (
                 PARTITION BY users
                 ORDER BY timestamp
                 ) as finish
         FROM
             timestamp_events
     )

SELECT
    users,
    channel,
    beginning,
    COALESCE(finish, DATEADD(hour,3, beginning)) as finish
FROM
    sessions