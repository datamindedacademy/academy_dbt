SELECT
*
FROM
{% if var('cumulative') == 'true' %}
     {{ source('covid', 'cases_muni_cum') }}  cases
{% else %}
     {{ source('covid', 'cases_muni') }}  cases
{% endif %}