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
  - GCP Flow Logs

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

### Global Configuration Values

| Parameter  | Description                          | Required | Default                                              |
| ---------- | ------------------------------------ | -------- | ---------------------------------------------------- |
| `apiKey`   | Coordimap API key for authentication | Yes      | -                                                    |
| `endpoint` | Coordimap API endpoint               | Yes      | `https://api.coordimap.com/collector/crawlers/infra` |
| `debug`    | Enable debug logging                 | No       | `false`                                              |

### Image Configuration

| Parameter          | Description             | Required | Default                     |
| ------------------ | ----------------------- | -------- | --------------------------- |
| `image.repository` | Docker image repository | Yes      | `coordimap/coordimap-agent` |
| `image.tag`        | Docker image tag        | Yes      | `latest`                    |
| `image.pullPolicy` | Image pull policy       | No       | `Always`                    |

### Resource Configuration

| Parameter                   | Description    | Required | Default |
| --------------------------- | -------------- | -------- | ------- |
| `resources.requests.memory` | Memory request | No       | `150M`  |
| `resources.requests.cpu`    | CPU request    | No       | `500m`  |
| `resources.limits.memory`   | Memory limit   | No       | `150M`  |
| `resources.limits.cpu`      | CPU limit      | No       | `500m`  |

### Data Sources Configuration

#### PostgreSQL, MariaDB, and MySQL Configuration

These parameters apply to `dataSources.postgres[]`, `dataSources.mariadb[]`, and `dataSources.mysql[]`

| Parameter             | Description                        | Required | Default |
| --------------------- | ---------------------------------- | -------- | ------- |
| `id`                  | Unique identifier for the database | Yes      | -       |
| `dbName`              | Database name                      | Yes      | -       |
| `dbHost`              | Database host address              | Yes      | -       |
| `dbUser`              | Database username                  | Yes      | -       |
| `dbPass`              | Database password                  | Yes      | -       |
| `crawlInterval`       | Frequency of data collection       | Yes      | -       |
| `mappingDataSourceId` | External source mapping ID         | No\*     | -       |
| `mappingInternalId`   | Internal mapping ID                | No\*     | -       |

\* If one mapping ID is provided, the other must also be provided.

#### Kubernetes Configuration

Parameters for `dataSources.kubernetes[]`

| Parameter       | Description                       | Required | Default |
| --------------- | --------------------------------- | -------- | ------- |
| `id`            | Unique identifier for the cluster | Yes      | -       |
| `inCluster`     | Whether to use in-cluster config  | Yes      | -       |
| `crawlInterval` | Frequency of data collection      | Yes      | -       |

#### AWS Configuration

Parameters for `dataSources.aws[]`

| Parameter       | Description                                 | Required | Default |
| --------------- | ------------------------------------------- | -------- | ------- |
| `id`            | Unique identifier for the AWS configuration | Yes      | -       |
| `region`        | AWS region                                  | Yes      | -       |
| `accessKey`     | AWS access key ID                           | Yes      | -       |
| `secretKey`     | AWS secret access key                       | Yes      | -       |
| `crawlInterval` | Frequency of data collection                | Yes      | -       |

#### GCP Configuration

Parameters for both `dataSources.gcp[]` and `dataSources.gcp_flow_logs[]`

| Parameter         | Description                                 | Required | Default |
| ----------------- | ------------------------------------------- | -------- | ------- |
| `id`              | Unique identifier for the GCP configuration | Yes      | -       |
| `projectId`       | GCP project ID                              | Yes      | -       |
| `inCloud`         | Whether to use in-cluster GCP credentials   | No\*     | -       |
| `credentialsFile` | Path to GCP credentials file                | No\*     | -       |
| `crawlInterval`   | Frequency of data collection                | Yes      | -       |

\* Either `inCloud` or `credentialsFile` must be provided, but not both.

#### MongoDB Configuration

Parameters for `dataSources.mongodb[]`

| Parameter       | Description                                | Required | Default |
| --------------- | ------------------------------------------ | -------- | ------- |
| `id`            | Unique identifier for the MongoDB instance | Yes      | -       |
| `dbName`        | Database name                              | Yes      | -       |
| `dbHost`        | Database host address                      | Yes      | -       |
| `dbUser`        | Database username                          | Yes      | -       |
| `dbPass`        | Database password                          | Yes      | -       |
| `crawlInterval` | Frequency of data collection               | Yes      | -       |

## Example Configurations

### Database Configuration

```yaml
dataSources:
  postgres:
    - id: "users-db-001"
      dbName: "users"
      dbHost: "users-db.example.com"
      dbUser: "users_admin"
      dbPass: "users_pwd"
      crawlInterval: "60s"
      mappingDataSourceId: "source-001" # Optional
      mappingInternalId: "internal-001" # Optional
```

### Cloud Provider Configuration

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
      inCloud: true
      crawlInterval: "120s"

  gcp_flow_logs:
    - id: "gcp-flow-001"
      projectId: "my-project"
      credentialsFile: "/path/to/credentials.json"
      crawlInterval: "120s"
```

## License

Copyright (c) 2024 Coordimap
