with muni_vacc_with_dates as (
select *,
      LAST_DAY(TO_DATE(CONCAT('20', substring(year_week, 1, 2) ), 'YYYY'), week) AS last_day_of_first_week,
      DATEADD( week, substring(year_week, 4, 2) - 1 , last_day_of_first_week ) AS last_day_of_the_week
from public.vacc_muni_cum
),
vaccination as (
select
    nis5,
    sum(cumul) as fully_vaccinated,
    '2021-08-10' by_date,
    last_day_of_the_week
from muni_vacc_with_dates
where (dose='B' or dose='C')
group by nis5, last_day_of_the_week
having last_day_of_the_week >= by_date and last_day_of_the_week < dateadd(week, 1, by_date)
)
select * from vaccination
