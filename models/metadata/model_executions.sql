{{
  config(
    materialized='table',
    schema='metadata'
  )
}}

with model_executions as (
  select
    -- Multi-tenant identification
    '{{ var("api_token") }}' as customer_api_token,
    
    -- Execution metadata
    current_timestamp() as execution_timestamp,
    '{{ invocation_id }}' as invocation_id,
    '{{ run_started_at }}' as run_started_at,
    
    -- Model information
    '{{ this.name }}' as model_name,
    '{{ this.schema }}' as model_schema,
    '{{ this.database }}' as model_database,
    '{{ this.resource_type }}' as resource_type,
    '{{ this.path }}' as model_path,
    
    -- Execution details
    '{{ this.config.materialized }}' as materialization_type,
    '{{ target.name }}' as target_name,
    '{{ target.type }}' as target_type,
    '{{ target.threads }}' as target_threads,
    
    -- Performance metrics (to be populated by macros)
    null as execution_duration_seconds,
    null as rows_affected,
    null as bytes_processed,
    
    -- Status
    'running' as execution_status,
    null as error_message,
    
    -- Additional metadata
    '{{ dbt_version }}' as dbt_version,
    '{{ project_name }}' as project_name
)

select * from model_executions 