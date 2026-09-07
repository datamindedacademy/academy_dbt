{% macro check_sources() %}
  {% for table in ['customer', 'orders', 'nation', 'region', 'lineitem', 'part', 'partsupp', 'supplier'] %}
    {% set result = run_query('SELECT * FROM ' ~ source('tpch', table) ~ ' LIMIT 1') %}
    {% if result | length == 0 %}
      {{ exceptions.raise_compiler_error('Empty source: ' ~ table) }}
    {% endif %}
    {{ log('Source OK: ' ~ table, info=True) }}
  {% endfor %}
{% endmacro %}

{% macro cleanup_check() %}
  {% if not target.schema.startswith('academy_check_') %}
    {{ exceptions.raise_compiler_error('Cleanup requires an academy_check_ schema.') }}
  {% endif %}
  {% set relation = ref('customer_stats') %}
  {% do adapter.drop_schema(api.Relation.create(database=relation.database, schema=target.schema)) %}
{% endmacro %}
