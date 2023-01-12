{{ config(materialized='table') }}

SELECT
    program,
    '{{ var("date") }}' as date,
    CONCAT(program, '{{ var("date") }}') as unique_id,
    SUM (time_watched_minutes) total_time_minutes,
    COUNT ( DISTINCT users ) unique_users_watched,
    CAST(total_time_minutes AS DECIMAL) / unique_users_watched average_time_per_digibox
FROM {{ ref('enriched_session') }}

GROUP BY program