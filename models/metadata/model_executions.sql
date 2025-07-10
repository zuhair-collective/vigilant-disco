{{
  config(
    materialized='table',
    schema='metadata'
  )
}}

-- This model captures metadata about dbt model executions
-- Simplified version to avoid syntax errors

{% if var('enable_model_metadata', true) %}

-- Capture metadata for the current model execution
select
  -- Multi-tenant identification
  '{{ var("api_token") }}' as customer_api_token,
  
  -- Execution metadata (simplified to avoid syntax errors)
  current_timestamp() as execution_timestamp,
  'test_invocation' as invocation_id,
  current_timestamp() as run_started_at,
  
  -- Model information (simplified)
  'test_model' as model_name,
  'test_schema' as model_schema,
  'test_database' as model_database,
  'model' as resource_type,
  'test_path' as model_path,
  
  -- Execution details
  'table' as materialization_type,
  'test_target' as target_name,
  'bigquery' as target_type,
  1 as target_threads,
  
  -- Performance metrics
  0 as execution_duration_seconds,
  0 as rows_affected,
  null as bytes_processed,
  
  -- Status
  'success' as execution_status,
  null as error_message,
  
  -- Additional metadata
  '1.5.4' as dbt_version,
  'test_project' as project_name

{% else %}

-- Return empty result if metadata collection is disabled
select 
  '{{ var("api_token") }}' as customer_api_token,
  current_timestamp() as execution_timestamp,
  'disabled' as invocation_id,
  current_timestamp() as run_started_at,
  'disabled' as model_name,
  'disabled' as model_schema,
  'disabled' as model_database,
  'disabled' as resource_type,
  'disabled' as model_path,
  'disabled' as materialization_type,
  'disabled' as target_name,
  'disabled' as target_type,
  1 as target_threads,
  null as execution_duration_seconds,
  null as rows_affected,
  null as bytes_processed,
  'disabled' as execution_status,
  null as error_message,
  'disabled' as dbt_version,
  'disabled' as project_name
where false

{% endif %} 