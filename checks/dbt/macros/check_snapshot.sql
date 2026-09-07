{% macro check_snapshot(expected_rows, expected_current) %}
  {% set result = run_query('SELECT COUNT(*), SUM(CASE WHEN dbt_valid_to IS NULL THEN 1 ELSE 0 END) FROM ' ~ ref('country_codes_snapshot')) %}
  {% if result.rows[0][0] != expected_rows or result.rows[0][1] != expected_current %}
    {{ exceptions.raise_compiler_error('Unexpected snapshot row counts: ' ~ result.rows[0]) }}
  {% endif %}
  {{ log('Snapshot OK: ' ~ expected_rows ~ ' total, ' ~ expected_current ~ ' current', info=True) }}
{% endmacro %}
