select 
    first.last_day_of_the_week as date, 
    first.first_sum, second.second_sum, buster.buster_sum, 
    first.first_percent, second.second_percent, buster.buster_percent
from {{ ref('first_dose')}} as first
full join {{ ref('second_dose')}} as second 
    on first.last_day_of_the_week=second.last_day_of_the_week
full join {{ ref('buster_dose')}} as buster 
    on first.last_day_of_the_week=buster.last_day_of_the_week
