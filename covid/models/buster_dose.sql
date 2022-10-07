with date_transform as (
select year_week,
       LAST_DAY(TO_DATE(CONCAT('20', substring(year_week, 1, 2) ), 'YYYY'), week) AS last_day_of_first_week,
       DATEADD( week, substring(year_week, 4, 2) - 1 , last_day_of_first_week ) AS last_day_of_the_week,
       cumul
from {{ source('covid','vacc_muni_cum') }}
where dose='E'
),
BE_population as(
select population from {{source('covid','population')}}
where refnis=1000
),
per_dose as(
select last_day_of_the_week, sum(cumul) as buster_sum
from date_transform
group by last_day_of_the_week
) 

select last_day_of_the_week, buster_sum, CAST(buster_sum AS DECIMAL) / (select * from BE_population) as buster_percent
from per_dose


