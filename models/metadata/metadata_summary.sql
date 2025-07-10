{{
  config(
    materialized='table',
    schema='metadata'
  )
}}

with model_executions_summary as (
  select
    customer_api_token,
    count(*) as total_model_executions,
    count(distinct model_name) as unique_models_executed,
    count(distinct invocation_id) as unique_invocations,
    avg(execution_duration_seconds) as avg_execution_duration,
    sum(rows_affected) as total_rows_affected,
    sum(bytes_processed) as total_bytes_processed,
    min(execution_timestamp) as first_execution,
    max(execution_timestamp) as last_execution,
    count(case when execution_status = 'success' then 1 end) as successful_executions,
    count(case when execution_status = 'failure' then 1 end) as failed_executions
  from {{ ref('model_executions') }}
  group by customer_api_token
),

source_freshness_summary as (
  select
    customer_api_token,
    count(*) as total_freshness_checks,
    count(distinct source_name) as unique_sources_checked,
    count(distinct invocation_id) as unique_invocations,
    count(case when freshness_status = 'pass' then 1 end) as passed_checks,
    count(case when freshness_status = 'warn' then 1 end) as warning_checks,
    count(case when freshness_status = 'error' then 1 end) as error_checks,
    min(check_timestamp) as first_check,
    max(check_timestamp) as last_check
  from {{ ref('source_freshness_checks') }}
  group by customer_api_token
),

test_results_summary as (
  select
    customer_api_token,
    count(*) as total_tests_executed,
    count(distinct test_name) as unique_tests,
    count(distinct invocation_id) as unique_invocations,
    count(case when test_status = 'pass' then 1 end) as passed_tests,
    count(case when test_status = 'fail' then 1 end) as failed_tests,
    avg(test_execution_duration_seconds) as avg_test_duration,
    sum(rows_checked) as total_rows_checked,
    min(test_execution_timestamp) as first_test,
    max(test_execution_timestamp) as last_test
  from {{ ref('test_results') }}
  group by customer_api_token
)

select
  coalesce(m.customer_api_token, s.customer_api_token, t.customer_api_token) as customer_api_token,
  
  -- Model execution metrics
  coalesce(m.total_model_executions, 0) as total_model_executions,
  coalesce(m.unique_models_executed, 0) as unique_models_executed,
  coalesce(m.avg_execution_duration, 0) as avg_model_execution_duration,
  coalesce(m.total_rows_affected, 0) as total_rows_affected,
  coalesce(m.total_bytes_processed, 0) as total_bytes_processed,
  coalesce(m.successful_executions, 0) as successful_model_executions,
  coalesce(m.failed_executions, 0) as failed_model_executions,
  
  -- Source freshness metrics
  coalesce(s.total_freshness_checks, 0) as total_freshness_checks,
  coalesce(s.unique_sources_checked, 0) as unique_sources_checked,
  coalesce(s.passed_checks, 0) as passed_freshness_checks,
  coalesce(s.warning_checks, 0) as warning_freshness_checks,
  coalesce(s.error_checks, 0) as error_freshness_checks,
  
  -- Test execution metrics
  coalesce(t.total_tests_executed, 0) as total_tests_executed,
  coalesce(t.unique_tests, 0) as unique_tests,
  coalesce(t.avg_test_duration, 0) as avg_test_duration,
  coalesce(t.total_rows_checked, 0) as total_rows_checked,
  coalesce(t.passed_tests, 0) as passed_tests,
  coalesce(t.failed_tests, 0) as failed_tests,
  
  -- Overall metrics
  coalesce(m.first_execution, s.first_check, t.first_test) as first_activity,
  coalesce(m.last_execution, s.last_check, t.last_test) as last_activity,
  
  -- Success rates
  case 
    when coalesce(m.total_model_executions, 0) > 0 
    then round(coalesce(m.successful_executions, 0) * 100.0 / m.total_model_executions, 2)
    else 0 
  end as model_success_rate,
  
  case 
    when coalesce(s.total_freshness_checks, 0) > 0 
    then round(coalesce(s.passed_checks, 0) * 100.0 / s.total_freshness_checks, 2)
    else 0 
  end as freshness_success_rate,
  
  case 
    when coalesce(t.total_tests_executed, 0) > 0 
    then round(coalesce(t.passed_tests, 0) * 100.0 / t.total_tests_executed, 2)
    else 0 
  end as test_success_rate

from model_executions_summary m
full outer join source_freshness_summary s on m.customer_api_token = s.customer_api_token
full outer join test_results_summary t on coalesce(m.customer_api_token, s.customer_api_token) = t.customer_api_token 