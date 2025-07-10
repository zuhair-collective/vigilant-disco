{{
  config(
    materialized='table',
    schema='metadata'
  )
}}

-- This model captures test execution metadata
-- For now, it creates a placeholder structure that can be populated
-- when tests are actually run

with test_results as (
  select
    -- Multi-tenant identification
    '{{ var("api_token") }}' as customer_api_token,
    
    -- Test execution metadata
    current_timestamp() as test_execution_timestamp,
    '{{ invocation_id }}' as invocation_id,
    
    -- Test information (to be populated during actual test runs)
    'placeholder_test' as test_name,
    'placeholder_type' as test_type,
    'placeholder_path' as test_path,
    'placeholder_schema' as test_schema,
    'placeholder_database' as test_database,
    
    -- Test configuration
    null as test_config,
    null as test_description,
    
    -- Test results
    'pending' as test_status,
    null as test_result,
    null as test_failures,
    null as test_warnings,
    
    -- Affected models
    'placeholder_model' as model_name,
    'placeholder_schema' as model_schema,
    'placeholder_database' as model_database,
    
    -- Performance metrics
    null as test_execution_duration_seconds,
    null as rows_checked,
    
    -- Additional metadata
    '{{ target.name }}' as target_name,
    '{{ dbt_version }}' as dbt_version,
    '{{ project_name }}' as project_name
)

-- Return empty result set for now - will be populated during actual test runs
select * from test_results limit 0 