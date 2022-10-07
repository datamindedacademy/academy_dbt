with added_date as(
select year_week,
       {{ transform_to_date('year_week') }} as week_date,
       cumul
from {{ source('covid','vacc_muni_cum') }}
)
select week_date, sum(cumul) as total_cases
from added_date
group by week_date