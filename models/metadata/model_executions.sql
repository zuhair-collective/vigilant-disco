{{
  config(
    materialized='table',
    schema='metadata'
  )
}}

-- This model captures metadata about dbt model executions
-- It's designed to be populated by the capture_model_metadata macro

with model_executions as (
  select
    -- Multi-tenant identification
    '{{ var("api_token") }}' as customer_api_token,
    
    -- Execution metadata
    current_timestamp() as execution_timestamp,
    '{{ invocation_id }}' as invocation_id,
    '{{ run_started_at }}' as run_started_at,
    
    -- Model information (simplified for now)
    'unknown' as model_name,
    'unknown' as model_schema,
    'unknown' as model_database,
    'model' as resource_type,
    'unknown' as model_path,
    
    -- Execution details (simplified)
    'table' as materialization_type,
    '{{ target.name }}' as target_name,
    '{{ target.type }}' as target_type,
    1 as target_threads,
    
    -- Performance metrics (to be populated by macros)
    null as execution_duration_seconds,
    null as rows_affected,
    null as bytes_processed,
    
    -- Status
    'pending' as execution_status,
    null as error_message,
    
    -- Additional metadata
    '{{ dbt_version }}' as dbt_version,
    '{{ project_name }}' as project_name
)

-- Return empty result set for now - will be populated by macros during actual execution
select * from model_executions limit 0 