{% macro capture_source_freshness() %}
  {% if var('enable_source_freshness_metadata', true) %}
    {% set start_time = modules.datetime.datetime.now() %}
    
    -- Run source freshness check
    {{ super() }}
    
    -- Capture post-execution metadata
    {% set end_time = modules.datetime.datetime.now() %}
    {% set execution_duration = (end_time - start_time).total_seconds() %}
    
    -- Insert metadata for each source checked
    {% for source in graph.sources.values() %}
      {% set source_freshness_query %}
        select 
          '{{ source.name }}' as source_name,
          '{{ source.table_name }}' as source_table,
          '{{ source.schema }}' as source_schema,
          '{{ source.database }}' as source_database,
          {% if source.freshness %}
            {{ source.freshness.warn_after }} as warn_after,
            {{ source.freshness.error_after }} as error_after,
            '{{ source.freshness.filter }}' as filter
          {% else %}
            null as warn_after,
            null as error_after,
            null as filter
          {% endif %}
      {% endset %}
      
      {% set source_result = run_query(source_freshness_query) %}
      
      {% if source_result.rows %}
        {% set source_data = source_result.rows[0] %}
        {% set metadata_insert %}
          insert into {{ target.database }}.metadata.source_freshness_checks (
            customer_api_token,
            check_timestamp,
            invocation_id,
            source_name,
            source_table,
            source_schema,
            source_database,
            warn_after,
            error_after,
            filter,
            max_loaded_at,
            snapshotted_at,
            max_loaded_at_time_ago_in_s,
            freshness_status,
            target_name,
            dbt_version,
            project_name
          ) values (
            '{{ var("api_token") }}',
            current_timestamp(),
            '{{ invocation_id }}',
            '{{ source_data[0] }}',
            '{{ source_data[1] }}',
            '{{ source_data[2] }}',
            '{{ source_data[3] }}',
            {{ source_data[4] }},
            {{ source_data[5] }},
            '{{ source_data[6] }}',
            null, -- max_loaded_at will be populated by dbt
            null, -- snapshotted_at will be populated by dbt
            null, -- max_loaded_at_time_ago_in_s will be populated by dbt
            'pending', -- status will be updated after freshness check
            '{{ target.name }}',
            '{{ dbt_version }}',
            '{{ project_name }}'
          )
        {% endset %}
        
        {% do run_query(metadata_insert) %}
      {% endif %}
    {% endfor %}
  {% else %}
    {{ super() }}
  {% endif %}
{% endmacro %} 