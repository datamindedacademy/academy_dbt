{% macro is_in_reporting_interval(date_column) %}
  {{ date_column }} between date '{{ var("report_interval_start") }}' and date '{{ var("report_interval_end") }}'
{% endmacro %}
