with cases_with_year_week as (
select
    *,
    CONCAT( SUBSTRING(to_varchar(date_part(year, date_of_case)), 3, 2),
            'W',
            to_varchar(date_part(week, date_of_case))) as year_week
from public.cases_muni
),
new_cases_next_two_weeks as (
select
    nis5,
    TX_DESCR_NL,
    TX_DESCR_FR,
    TX_ADM_DSTR_DESCR_NL,
    TX_ADM_DSTR_DESCR_FR,
    PROVINCE,
    REGION,
    sum(cases) as new_cases,
    dateadd(week, 0, '2021-08-10') as from_date,
    dateadd(week, 8, '2021-08-10') as to_date
from cases_with_year_week
where date_of_case > from_date and date_of_case < to_date
group by nis5, TX_DESCR_NL, TX_DESCR_FR, TX_ADM_DSTR_DESCR_NL, TX_ADM_DSTR_DESCR_FR, PROVINCE, REGION
)
select * from new_cases_next_two_weeks
