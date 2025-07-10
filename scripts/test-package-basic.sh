#!/bin/bash

# Basic test script for dbtpackv2 package
# This script validates the package structure without requiring BigQuery

set -e

echo "🐳 Starting basic dbtpackv2 package validation..."

# Create cache directory if it doesn't exist
mkdir -p dbt-cache

# Build the Docker image
echo "📦 Building Docker image..."
docker-compose build

# Start the container and run basic validation
echo "🚀 Starting container and running basic validation..."
docker-compose run --rm dbtpackv2-test bash -c "
    echo '🔍 Checking dbt version...'
    dbt --version
    
    echo '📋 Validating project structure...'
    ls -la
    
    echo '🔧 Testing dbt project configuration (without connection)...'
    dbt debug --config-dir
    
    echo '📦 Testing package compilation...'
    dbt compile --select dbtpackv2
    
    echo '📚 Testing documentation generation...'
    dbt docs generate --select dbtpackv2
    
    echo '✅ Basic validation completed successfully!'
"

echo "🎉 Package validation completed!" 