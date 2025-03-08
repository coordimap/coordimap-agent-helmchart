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

*   Kubernetes cluster (v1.20+)
*   Helm v3.x installed
*   `kubectl` configured to connect to your cluster
*   Coordimap API key

## Adding the Helm Repository

To add the Helm repository, use the following command:

```bash
helm repo add coordimap https://charts.coordimap.com
helm install my-coordimap coordimap/coordimap -f values.yaml
```

## Installing the Chart

1. Create a values-my-release.yaml file: Copy the values.yaml file to values-my-release.yaml and update the necessary values.

2. Configure the Chart:

You'll need to customize the chart by creating an override values file. Here are the most important parameters to configure:

 * apiKey (Required): Your Coordimap API key. This is essential for the agent to authenticate with the Coordimap API.
 * endpoint (Required): The Coordimap API endpoint URL. The default is https://api.coordimap.com/collector/crawlers/infra.
 * dataSources (Required): This is where you define the sources from which the agent should collect data. You can configure:
    * postgres
    *  mariadb
    *  mysql
    *  kubernetes
    *  aws
    *  mongodb
    *  gcp
 * serviceAccount (Optional): The service account used to deploy the agent. Default is default.
 * containerName (Optional): The container name. Default is coordimap-agent.
 * image.repository: The Docker image repository for the agent. Default is coordimap/coordimap-agent.
 * image.tag: The Docker image tag for the agent. Default is latest. Warning: This should be set to a specific version, not latest, for production deployments.
 * image.pullPolicy: The image pull policy. Default is Always.
 * resources.requests: Resource requests (CPU, memory) for the agent container.
 * resources.limits: Resource limits (CPU, memory) for the agent container.
 * debug: Whether to enable debug mode for the agent. Default is true.

### An example of `values-my-release.yaml`

```yaml
apiKey: "YOUR_ACTUAL_API_KEY"
endpoint: "https://api.coordimap.com/collector/crawlers/infra"
debug: true
containerName: coordimap-agent
serviceAccount: my-service-account
dataSources:
  gcp:
    - id: my-gcp-project
      crawlInterval: 30s
      inCloud: true
      projectId: "gcp-project"
      gcpFlows: true
      externalMappings: europe-west3-pe-gke-cluster@kubeID123
      includeRegions: europe-west3
```

3. Install the Chart: 
Once you've created your values-my-release.yaml file, install the chart using the following command:

`helm install my-coordimap-agent coordimap/coordimap-agent -f values-my-release.yaml -n my-namespace --create-namespace`

* Replace `my-coordimap-agent` with the desired release name.
* Replace `coordimap/coordimap-agent` with the chart name.
* Replace `values-my-release.yaml` with the name of your values file.
* Replace `my-namespace` with the namespace you want to use or remove --create-namespace if the namespace already exits.


## Upgrading the Chart

To upgrade an existing release to a new version of the chart, use the following command:

```bash
helm upgrade my-coordimap-agent coordimap/coordimap-agent -f values-my-release.yaml -n my-namespace
```

* Replace my-coordimap-agent with the desired release name.
* Replace coordimap/coordimap-agent with the chart name.
* Replace values-my-release.yaml with the name of your values file.
* Replace my-namespace with the namespace you used for the installation.

## Uninstalling the Chart

To uninstall/delete the my-coordimap-agent release:

```bash
helm uninstall my-coordimap-agent -n my-namespace
```

* Replace my-coordimap-agent with the desired release name.
* Replace my-namespace with the namespace you used for the installation.

## Configuration

The following tables describe the configurable parameters of the coordimap-agent chart.

### Global Configuration Values

| Parameter  | Description                          | Required | Default                                              |
| ---------- | ------------------------------------ | -------- | ---------------------------------------------------- |
| `apiKey`   | Coordimap API key for authentication | Yes      | -                                                    |
| `endpoint` | Coordimap API endpoint               | Yes      | `https://api.coordimap.com/collector/crawlers/infra` |
| `debug`    | Enable debug logging                 | No       | `false`                                              |
| `containerName`    | The container name | No       | `coordimap-agent`                                              |
| `serviceAccount`    | The service account to use for the deployment | No       | `default`                                              |

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

Copyright (c) 2025 Coordimap
