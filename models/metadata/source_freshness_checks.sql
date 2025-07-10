{{
  config(
    materialized='table',
    schema='metadata'
  )
}}

-- This model captures source freshness check metadata
-- For now, it creates a placeholder structure that can be populated
-- when source freshness checks are actually run

with source_freshness_checks as (
  select
    -- Multi-tenant identification
    '{{ var("api_token") }}' as customer_api_token,
    
    -- Check metadata
    current_timestamp() as check_timestamp,
    '{{ invocation_id }}' as invocation_id,
    
    -- Source information (to be populated during actual freshness checks)
    'placeholder_source' as source_name,
    'placeholder_table' as source_table,
    'placeholder_schema' as source_schema,
    'placeholder_database' as source_database,
    
    -- Freshness configuration
    null as warn_after,
    null as error_after,
    null as filter,
    
    -- Freshness results
    null as max_loaded_at,
    null as snapshotted_at,
    null as max_loaded_at_time_ago_in_s,
    
    -- Status calculation
    'pending' as freshness_status,
    
    -- Additional metadata
    '{{ target.name }}' as target_name,
    '{{ dbt_version }}' as dbt_version,
    '{{ project_name }}' as project_name
)

-- Return empty result set for now - will be populated during actual freshness checks
select * from source_freshness_checks limit 0 