#!/bin/bash

# Test script for dbtpackv2 package
# This script runs the package tests in Docker

set -e

echo "🐳 Starting dbtpackv2 package test..."

# Create cache directory if it doesn't exist
mkdir -p dbt-cache

# Build the Docker image
echo "📦 Building Docker image..."
docker-compose build

# Start the container and run tests
echo "🚀 Starting container and running tests..."
docker-compose run --rm dbtpackv2-test bash -c "
    echo '🔍 Checking dbt version...'
    dbt --version
    
    echo '📋 Listing project files...'
    ls -la
    
    echo '🔧 Testing dbt project configuration...'
    dbt debug
    
    echo '📦 Installing dependencies...'
    dbt deps
    
    echo '🏗️  Running models...'
    dbt run --select dbtpackv2
    
    echo '🧪 Running tests...'
    dbt test --select dbtpackv2
    
    echo '✅ All tests completed successfully!'
"

echo "🎉 Package test completed!" 