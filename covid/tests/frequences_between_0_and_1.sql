SELECT
    *
FROM
    {{ ref('final_covid_stat_per_muni') }}
WHERE
    average_time_per_program < 0