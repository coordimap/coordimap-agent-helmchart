# Coordimap Helm Chart

A Helm chart for deploying Coordimap agents to collect infrastructure metrics and metadata from various data sources.

## Features

- Multi-source data collection support:

  - PostgreSQL databases
  - MariaDB instances
  - MySQL databases
  - Kubernetes clusters
  - AWS resources
  - GCP resources
  - MongoDB instances

- Configurable crawl intervals for each data source
- Resource limits and requests management
- RBAC configuration for Kubernetes access

## Prerequisites

- Kubernetes 1.16+
- Helm 3.0+
- Valid Coordimap API key

## Installation

```bash
helm repo add coordimap https://charts.coordimap.com
helm install my-coordimap coordimap/coordimap -f values.yaml
```

## Configuration

### Required Values

```yaml
apiKey: "your-api-key"
endpoint: "https://api.coordimap.com/collector/crawlers/infra"
```

### Optional Values

```yaml
image:
  repository: coordimap/coordimap-agent
  tag: latest
  pullPolicy: Always

resources:
  requests:
    memory: "150M"
    cpu: "500m"
  limits:
    memory: "150M"
    cpu: "500m"

debug: true
```

### Data Sources Configuration

Each data source type supports specific configuration options:

#### Database Sources (PostgreSQL, MariaDB, MySQL)

```yaml
dataSources:
  postgres:
    - id: "db-001" # Required: Unique identifier
      dbName: "database" # Required: Database name
      dbHost: "db.example.com" # Required: Database host
      dbUser: "user" # Required: Database user
      dbPass: "password" # Required: Database password
      crawlInterval: "60s" # Required: Crawl frequency
      mappingDataSourceId: "source-001" # Optional: Must be provided with mappingInternalId
      mappingInternalId: "internal-001" # Optional: Must be provided with mappingDataSourceId
```

#### Kubernetes Source

```yaml
dataSources:
  kubernetes:
    - id: "cluster-001"
      inCluster: true
      crawlInterval: "30s"
```

#### Cloud Provider Sources (AWS, GCP)

```yaml
dataSources:
  aws:
    - id: "aws-001"
      region: "us-west-2"
      accessKey: "AKIAXXXXXXX"
      secretKey: "XXXXXXXXX"
      crawlInterval: "120s"

  gcp:
    - id: "gcp-001"
      projectId: "my-project"
      inCloud: true # or use credentialsFile
      crawlInterval: "120s"
```

## License

Copyright (c) 2024 Coordimap
