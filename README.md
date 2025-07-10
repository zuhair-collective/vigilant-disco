# dbtpackv2

A dbt package for capturing comprehensive metadata about your dbt models, source freshness, and tests. This package provides multi-tenant metadata collection capabilities with support for BigQuery and other cloud data warehouses.

## Features

- **Model Execution Metadata**: Track execution times, row counts, and execution status
- **Source Freshness Monitoring**: Capture source freshness check results and timing
- **Test Results Tracking**: Monitor test execution and results
- **Multi-tenant Support**: Separate metadata by customer using API tokens
- **BigQuery Compatible**: Optimized for BigQuery with support for other warehouses

## Installation

1. Add this package to your `packages.yml` file:

```yaml
packages:
  - git: "https://github.com/your-org/dbtpackv2.git"
    revision: v1.0.0  # Use version tags for production stability
```

2. Run `dbt deps` to install the package

3. Add the following to your `dbt_project.yml`:

```yaml
vars:
  # Set your API token for multi-tenant identification
  api_token: "{{ env_var('DBTPACKV2_API_TOKEN', 'your_token_here') }}"
  
  # Enable metadata collection features
  enable_model_metadata: true
  enable_source_freshness_metadata: true
  enable_test_metadata: true

models:
  dbtpackv2:
    +materialized: table
    +schema: metadata
```

## Configuration

### Environment Variables

- `DBTPACKV2_API_TOKEN`: Your API token for multi-tenant identification

### Variables

- `api_token`: API token for customer identification (defaults to env var)
- `enable_model_metadata`: Enable model execution tracking (default: true)
- `enable_source_freshness_metadata`: Enable source freshness tracking (default: true)
- `enable_test_metadata`: Enable test result tracking (default: true)

## Usage

After installation, the package will automatically create metadata tables in your target database under the `metadata` schema:

- `metadata.model_executions`: Model execution history
- `metadata.source_freshness_checks`: Source freshness check results
- `metadata.test_results`: Test execution results

## Models

### Core Metadata Tables

#### model_executions
Tracks each model execution with:
- Execution timestamp
- Model name and path
- Execution duration
- Row count changes
- Status (success/failure)
- Customer API token

#### source_freshness_checks
Monitors source freshness with:
- Check timestamp
- Source name and table
- Freshness status (pass/fail)
- Warning and error thresholds
- Customer API token

#### test_results
Captures test execution data:
- Test execution timestamp
- Test name and type
- Test status (pass/fail)
- Affected models
- Customer API token

## Development

This package is designed to be easily extensible. The metadata models use a modular approach that allows for easy addition of new metadata types.

## License

[Your License Here] 