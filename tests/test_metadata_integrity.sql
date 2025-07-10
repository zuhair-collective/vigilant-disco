-- Test to verify metadata table integrity
-- This test ensures that the metadata tables are properly structured and populated

with model_executions_check as (
  select 
    count(*) as row_count,
    count(distinct customer_api_token) as unique_customers,
    count(distinct invocation_id) as unique_invocations,
    min(execution_timestamp) as earliest_execution,
    max(execution_timestamp) as latest_execution
  from {{ ref('model_executions') }}
),

source_freshness_check as (
  select 
    count(*) as row_count,
    count(distinct customer_api_token) as unique_customers,
    count(distinct source_name) as unique_sources,
    min(check_timestamp) as earliest_check,
    max(check_timestamp) as latest_check
  from {{ ref('source_freshness_checks') }}
),

test_results_check as (
  select 
    count(*) as row_count,
    count(distinct customer_api_token) as unique_customers,
    count(distinct test_name) as unique_tests,
    min(test_execution_timestamp) as earliest_test,
    max(test_execution_timestamp) as latest_test
  from {{ ref('test_results') }}
)

select 
  'model_executions' as table_name,
  row_count,
  unique_customers,
  unique_invocations,
  earliest_execution,
  latest_execution
from model_executions_check

union all

select 
  'source_freshness_checks' as table_name,
  row_count,
  unique_customers,
  unique_sources as unique_invocations,
  earliest_check as earliest_execution,
  latest_check as latest_execution
from source_freshness_check

union all

select 
  'test_results' as table_name,
  row_count,
  unique_customers,
  unique_tests as unique_invocations,
  earliest_test as earliest_execution,
  latest_test as latest_execution
from test_results_check 