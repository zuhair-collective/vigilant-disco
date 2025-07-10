FROM python:3.9-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /dbt

# Install dbt and BigQuery adapter
RUN pip install --no-cache-dir \
    dbt-core>=1.5.0 \
    dbt-bigquery>=1.5.0

# Copy the dbtpackv2 package
COPY . /dbt/dbtpackv2/

# Set environment variable for the API token
ENV DBTPACKV2_API_TOKEN=test_token

# Default command
CMD ["bash"] 