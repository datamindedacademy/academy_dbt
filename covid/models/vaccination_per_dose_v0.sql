select
YEAR_WEEK,
sum(case when dose = 'A' then cumul end) as Dose_A,
sum(case when dose = 'B' then cumul end) as Dose_B,
sum(case when dose = 'C' then cumul end) as Dose_C,
sum(cumul) as total_doses
from {{ source('covid', 'vacc_muni_cum') }}
group by 1