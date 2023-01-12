WITH enriched_sessions as (
    select session.users       as users,
           schedule.channel as channel,
           session.beginning       as session_beginning,
           schedule.start as schedule_beginning,
           session.finish           as session_end,
           schedule.stop      as schedule_end,
           schedule.program           as program,
           schedule.genre         as genre,
           session.channel         as common_channel
    FROM {{ ref('session') }} as session
             INNER JOIN {{ source('training', 'schedule') }} as schedule
    ON session.channel = schedule.channel
        AND session.beginning < schedule.stop
        AND session.finish > schedule.start
)

SELECT users,
       common_channel,
       greatest(session_beginning, schedule_beginning) beginning,
       least(session_end, schedule_end)                finish,
       DATEDIFF(minute, beginning, finish)           time_watched_minutes,
       program,
       genre
FROM enriched_sessions