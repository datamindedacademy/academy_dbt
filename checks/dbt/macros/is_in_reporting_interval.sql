{% macro is_in_reporting_interval(date_column) %}
    {{ date_column }} BETWEEN DATE '{{ var("report_interval_start") }}'
    AND DATE '{{ var("report_interval_end") }}'
{% endmacro %}
