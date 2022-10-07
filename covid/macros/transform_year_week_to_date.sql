
{% macro transform_to_date(year_week_column) %}
 DATEADD( week, substring({{year_week_column}}, 4, 2) - 1 , LAST_DAY(TO_DATE(CONCAT('20', substring({{year_week_column}}, 1, 2) ), 'YYYY'), week)  )
 {% endmacro %}