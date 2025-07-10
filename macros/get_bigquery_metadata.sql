{% macro get_bigquery_metadata(table_ref) %}
  {% if target.type == 'bigquery' %}
    {% set metadata_query %}
      select 
        total_bytes_processed,
        total_slot_ms,
        creation_time,
        last_modified_time,
        row_count,
        size_bytes
      from `{{ target.project }}.{{ table_ref.database }}.__TABLES__`
      where table_id = '{{ table_ref.identifier }}'
    {% endset %}
    
    {% set result = run_query(metadata_query) %}
    {% if result.rows %}
      {% set metadata = result.rows[0] %}
      {% do return({
        'total_bytes_processed': metadata[0],
        'total_slot_ms': metadata[1],
        'creation_time': metadata[2],
        'last_modified_time': metadata[3],
        'row_count': metadata[4],
        'size_bytes': metadata[5]
      }) %}
    {% else %}
      {% do return({}) %}
    {% endif %}
  {% else %}
    {% do return({}) %}
  {% endif %}
{% endmacro %} 