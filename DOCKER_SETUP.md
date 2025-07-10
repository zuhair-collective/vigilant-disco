# Docker Setup for dbtpackv2 Testing

This guide shows you how to test the dbtpackv2 package using Docker without installing dbt locally.

## Prerequisites

- Docker and Docker Compose installed
- BigQuery project and service account (optional, for full testing)

## Quick Start

### 1. Build and Test (No BigQuery Required)

For basic package validation without BigQuery:

```bash
# Run the test script
./scripts/test-package.sh
```

This will:
- Build the Docker image with dbt and BigQuery adapter
- Test the package structure and configuration
- Run basic dbt commands to validate the package

### 2. Interactive Testing

For interactive testing and development:

```bash
# Build the image
docker-compose build

# Start an interactive shell
docker-compose run --rm dbtpackv2-test bash
```

Inside the container, you can run:
```bash
# Check dbt version
dbt --version

# Test project configuration
dbt debug

# Install dependencies
dbt deps

# Run models (if you have BigQuery configured)
dbt run --select dbtpackv2

# Run tests
dbt test --select dbtpackv2
```

## BigQuery Setup (Optional)

To test with actual BigQuery:

### 1. Create Service Account

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable BigQuery API
4. Create a service account with BigQuery permissions
5. Download the JSON key file

### 2. Configure Docker

1. Create a `credentials` directory:
```bash
mkdir credentials
```

2. Place your service account key in `credentials/service-account-key.json`

3. Update `profiles.yml` with your project details:
```yaml
dbtpackv2:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: your-project-id
      dataset: dbtpackv2_dev
      location: US
      threads: 4
      timeout_seconds: 300
      priority: interactive
      retries: 1
      keyfile: /dbt/credentials/service-account-key.json
```

### 3. Run with BigQuery

```bash
# Build and run with BigQuery
docker-compose run --rm dbtpackv2-test bash -c "
    dbt debug
    dbt run --select dbtpackv2
    dbt test --select dbtpackv2
"
```

## Development Workflow

### 1. Make Changes

Edit files in your local directory. Changes are automatically reflected in the container due to volume mounting.

### 2. Test Changes

```bash
# Quick test
./scripts/test-package.sh

# Or interactive testing
docker-compose run --rm dbtpackv2-test bash
```

### 3. Clean Up

```bash
# Remove containers and images
docker-compose down --rmi all

# Clean dbt cache
rm -rf dbt-cache
```

## Troubleshooting

### Common Issues

1. **Permission Denied**: Make sure the test script is executable:
   ```bash
   chmod +x scripts/test-package.sh
   ```

2. **BigQuery Authentication**: Ensure your service account has proper permissions and the key file is correctly placed.

3. **Port Conflicts**: If you get port conflicts, you can modify the `docker-compose.yml` to use different ports.

### Debug Mode

For more verbose output, run dbt with debug flags:
```bash
docker-compose run --rm dbtpackv2-test bash -c "dbt debug --config-dir"
```

## Next Steps

After successful testing:

1. **Create Git Tags**: Tag your releases for production use
2. **Publish Package**: Make the package available for installation
3. **Documentation**: Update README with real usage examples
4. **CI/CD**: Set up automated testing in your CI pipeline

## File Structure

```
dbtpackv2/
├── Dockerfile              # Docker image definition
├── docker-compose.yml      # Docker Compose configuration
├── .dockerignore          # Files to exclude from Docker build
├── scripts/
│   └── test-package.sh    # Automated test script
├── credentials/           # BigQuery credentials (create this)
│   └── service-account-key.json
└── dbt-cache/            # dbt cache directory (auto-created)
``` 