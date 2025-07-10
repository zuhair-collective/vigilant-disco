{% macro capture_model_metadata() %}
  {% if var('enable_model_metadata', true) %}
    {% set start_time = modules.datetime.datetime.now() %}
    
    -- Capture pre-execution state
    {% set pre_execution_query %}
      select 
        count(*) as row_count,
        {% if target.type == 'bigquery' %}
        sum(cast(length(to_json_string(*)) as int64)) as bytes_processed
        {% else %}
        null as bytes_processed
        {% endif %}
      from {{ this }}
    {% endset %}
    
    {% set pre_execution_result = run_query(pre_execution_query) %}
    {% set pre_row_count = pre_execution_result.columns[0].values()[0] if pre_execution_result.rows else 0 %}
    {% set pre_bytes = pre_execution_result.columns[1].values()[0] if pre_execution_result.rows else 0 %}
    
    -- Execute the model
    {{ super() }}
    
    -- Capture post-execution state
    {% set end_time = modules.datetime.datetime.now() %}
    {% set execution_duration = (end_time - start_time).total_seconds() %}
    
    {% set post_execution_query %}
      select 
        count(*) as row_count,
        {% if target.type == 'bigquery' %}
        sum(cast(length(to_json_string(*)) as int64)) as bytes_processed
        {% else %}
        null as bytes_processed
        {% endif %}
      from {{ this }}
    {% endset %}
    
    {% set post_execution_result = run_query(post_execution_query) %}
    {% set post_row_count = post_execution_result.columns[0].values()[0] if post_execution_result.rows else 0 %}
    {% set post_bytes = post_execution_result.columns[1].values()[0] if post_execution_result.rows else 0 %}
    
    -- Insert metadata
    {% set metadata_insert %}
      insert into {{ target.database }}.metadata.model_executions (
        customer_api_token,
        execution_timestamp,
        invocation_id,
        run_started_at,
        model_name,
        model_schema,
        model_database,
        resource_type,
        model_path,
        materialization_type,
        target_name,
        target_type,
        target_threads,
        execution_duration_seconds,
        rows_affected,
        bytes_processed,
        execution_status,
        error_message,
        dbt_version,
        project_name
      ) values (
        '{{ var("api_token") }}',
        current_timestamp(),
        '{{ invocation_id }}',
        '{{ run_started_at }}',
        '{{ this.name }}',
        '{{ this.schema }}',
        '{{ this.database }}',
        '{{ this.resource_type }}',
        '{{ this.path }}',
        '{{ this.config.materialized }}',
        '{{ target.name }}',
        '{{ target.type }}',
        {{ target.threads }},
        {{ execution_duration }},
        {{ post_row_count - pre_row_count }},
        {{ post_bytes - pre_bytes }},
        'success',
        null,
        '{{ dbt_version }}',
        '{{ project_name }}'
      )
    {% endset %}
    
    {% do run_query(metadata_insert) %}
  {% else %}
    {{ super() }}
  {% endif %}
{% endmacro %} 