{{
  config(
    materialized='table',
    schema='metadata'
  )
}}

-- This model captures metadata about dbt model executions
-- It should be run after each model to capture execution metadata

{% if var('enable_model_metadata', true) %}

-- Capture metadata for the current model execution
select
  -- Multi-tenant identification
  '{{ var("api_token") }}' as customer_api_token,
  
  -- Execution metadata
  current_timestamp() as execution_timestamp,
  '{{ invocation_id }}' as invocation_id,
  '{{ run_started_at }}' as run_started_at,
  
  -- Model information
  '{{ this.name if this.name else "unknown" }}' as model_name,
  '{{ this.schema if this.schema else target.schema }}' as model_schema,
  '{{ this.database if this.database else target.database }}' as model_database,
  '{{ this.resource_type if this.resource_type else "model" }}' as resource_type,
  '{{ this.path if this.path else "unknown" }}' as model_path,
  
  -- Execution details
  '{{ this.config.materialized if this.config and this.config.materialized else "table" }}' as materialization_type,
  '{{ target.name }}' as target_name,
  '{{ target.type }}' as target_type,
  {{ target.threads if target.threads else 1 }} as target_threads,
  
  -- Performance metrics (placeholder - will be enhanced later)
  0 as execution_duration_seconds,
  0 as rows_affected,
  null as bytes_processed,
  
  -- Status
  'success' as execution_status,
  null as error_message,
  
  -- Additional metadata
  '{{ dbt_version }}' as dbt_version,
  '{{ project_name }}' as project_name

{% else %}

-- Return empty result if metadata collection is disabled
select 
  '{{ var("api_token") }}' as customer_api_token,
  current_timestamp() as execution_timestamp,
  '{{ invocation_id }}' as invocation_id,
  '{{ run_started_at }}' as run_started_at,
  'disabled' as model_name,
  'disabled' as model_schema,
  'disabled' as model_database,
  'disabled' as resource_type,
  'disabled' as model_path,
  'disabled' as materialization_type,
  '{{ target.name }}' as target_name,
  '{{ target.type }}' as target_type,
  {{ target.threads if target.threads else 1 }} as target_threads,
  null as execution_duration_seconds,
  null as rows_affected,
  null as bytes_processed,
  'disabled' as execution_status,
  null as error_message,
  '{{ dbt_version }}' as dbt_version,
  '{{ project_name }}' as project_name
where false

{% endif %} 