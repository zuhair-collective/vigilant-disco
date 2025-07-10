# dbtpackv2 Installation Guide

This guide will walk you through installing and configuring the dbtpackv2 package in your existing dbt project.

## Prerequisites

- dbt Core or dbt Cloud
- Access to a supported data warehouse (BigQuery, Snowflake, Redshift)
- Python 3.7 or higher

## Step 1: Add Package to Your Project

### Option A: Install from Git Repository

Add the following to your `packages.yml` file:

```yaml
packages:
  - git: "https://github.com/your-org/dbtpackv2.git"
    revision: v1.0.0  # Use version tags for production stability
```

### Option B: Install Locally (for development)

If you're developing the package locally, add:

```yaml
packages:
  - local:
      path: /path/to/dbtpackv2
```

## Step 2: Install Dependencies

Run the following command to install the package:

```bash
dbt deps
```

## Step 3: Configure Your dbt_project.yml

Add the following configuration to your `dbt_project.yml`:

```yaml
# Package configuration
vars:
  # Set your API token for multi-tenant identification
  api_token: "{{ env_var('DBTPACKV2_API_TOKEN', 'your_default_token') }}"
  
  # Enable/disable metadata collection features
  enable_model_metadata: true
  enable_source_freshness_metadata: true
  enable_test_metadata: true

# Model configuration
models:
  dbtpackv2:
    +materialized: table
    +schema: metadata  # This will create a 'metadata' schema in your target database
```

## Step 4: Set Environment Variables

Set the following environment variable for multi-tenant identification:

```bash
export DBTPACKV2_API_TOKEN="your_unique_customer_token"
```

For dbt Cloud, add this as a custom environment variable in your project settings.

## Step 5: Create Metadata Schema

Run the following command to create the metadata tables:

```bash
dbt run --select dbtpackv2
```

This will create the following tables in your target database:
- `metadata.model_executions`
- `metadata.source_freshness_checks`
- `metadata.test_results`
- `metadata.metadata_summary`

## Step 6: Verify Installation

Run the tests to ensure everything is working correctly:

```bash
dbt test --select dbtpackv2
```

## Configuration Options

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DBTPACKV2_API_TOKEN` | API token for multi-tenant identification | `default_token` |

### Package Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `api_token` | API token for customer identification | Value of `DBTPACKV2_API_TOKEN` env var |
| `enable_model_metadata` | Enable model execution tracking | `true` |
| `enable_source_freshness_metadata` | Enable source freshness tracking | `true` |
| `enable_test_metadata` | Enable test result tracking | `true` |

## Usage Examples

### Basic Usage

After installation, the package will automatically collect metadata when you run:

```bash
# Run models (captures model execution metadata)
dbt run

# Check source freshness (captures freshness metadata)
dbt source freshness

# Run tests (captures test metadata)
dbt test
```

### Querying Metadata

You can query the collected metadata using standard SQL:

```sql
-- Get recent model executions
SELECT 
  model_name,
  execution_duration_seconds,
  rows_affected,
  execution_status
FROM metadata.model_executions
WHERE execution_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
ORDER BY execution_timestamp DESC;

-- Get source freshness summary
SELECT 
  source_name,
  freshness_status,
  max_loaded_at_time_ago_in_s
FROM metadata.source_freshness_checks
WHERE check_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR);

-- Get test results summary
SELECT 
  test_name,
  test_status,
  test_execution_duration_seconds
FROM metadata.test_results
WHERE test_execution_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR);
```

### Multi-tenant Data Separation

The package automatically separates data by customer using the `customer_api_token` field:

```sql
-- Query data for a specific customer
SELECT * FROM metadata.metadata_summary
WHERE customer_api_token = 'your_customer_token';
```

## Troubleshooting

### Common Issues

1. **Schema not found**: Ensure you have permissions to create schemas in your target database
2. **Permission errors**: Verify your database user has the necessary permissions
3. **Missing environment variables**: Check that `DBTPACKV2_API_TOKEN` is set correctly

### Debug Mode

Enable debug logging by running dbt with the `--debug` flag:

```bash
dbt run --select dbtpackv2 --debug
```

### Support

For issues or questions, please:
1. Check the [README.md](README.md) for documentation
2. Review the [tests](tests/) directory for examples
3. Open an issue on the GitHub repository

## Next Steps

After successful installation:

1. **Monitor Performance**: Use the metadata tables to monitor your dbt pipeline performance
2. **Set Up Alerts**: Create alerts based on metadata thresholds
3. **Build Dashboards**: Create dashboards to visualize your metadata
4. **Extend Functionality**: Add custom metadata collection using the provided macros

## Migration from Elementary

If you're migrating from Elementary, the dbtpackv2 package provides similar functionality with:
- Multi-tenant support
- BigQuery optimization
- Simplified installation
- Extensible architecture

The metadata schema is designed to be compatible with existing Elementary queries with minimal modifications. 