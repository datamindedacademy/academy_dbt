select
YEAR_WEEK,
{% for dose in ["A", "B", "C"] %}
sum(case when dose = '{{dose}}' then cumul end) as Dose_{{dose}},
{% endfor %}
sum(cumul) as total_doses
from {{ source('covid', 'vacc_muni_cum') }}
group by 1

