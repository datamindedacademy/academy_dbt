{{ config(materialized='table') }}

SELECT
    users,
    '{{ var("date") }}' as date,
    CONCAT(users, '{{ var("date") }}') as unique_id,
    SUM (time_watched_minutes) total_time_minutes,
    COUNT ( DISTINCT program ) different_programs_watched,
    CAST(total_time_minutes AS DECIMAL) / different_programs_watched average_time_per_program
FROM {{ ref('enriched_session') }}
GROUP BY users