# Coordimap Agent Helm Chart

The Coordimap Agent Helm chart deploys the Coordimap Agent on Kubernetes so developers, DevOps engineers, platform teams, and SREs can collect infrastructure metadata and metrics from supported systems and send them to the Coordimap platform.

Coordimap is described on [coordimap.com](https://coordimap.com) as incident dependency mapping for Kubernetes-first SRE teams, with live dependency context, blast-radius analysis, and change correlation to improve incident response. This chart provides the Kubernetes deployment package for that data collection layer.

## Chart location

This chart is stored in `charts/agent`.

## Supported data sources

- PostgreSQL
- MariaDB
- MySQL
- Kubernetes
- AWS
- MongoDB
- GCP

## Prerequisites

- Kubernetes cluster
- Helm 3
- `kubectl` configured for the target cluster
- a valid Coordimap API key
- network access to `https://api.coordimap.com/collector/crawlers/infra`

## Quick start

```bash
helm install coordimap-agent ./charts/agent \
  --namespace coordimap \
  --create-namespace \
  --set apiKey="YOUR_API_KEY"
```

For production deployments, prefer a values file and a pinned image tag.

## OCI install

This chart can be published and installed as an OCI Helm chart from GitHub Container Registry:

```bash
helm registry login ghcr.io
helm install coordimap-agent oci://ghcr.io/coordimap/charts/coordimap-agent \
  --version 0.1.0 \
  --namespace coordimap \
  --create-namespace \
  -f values.yaml
```

For Artifact Hub, the repository URL to register is:

```text
oci://ghcr.io/coordimap/charts/coordimap-agent
```

## Example values

```yaml
apiKey: "YOUR_API_KEY"
endpoint: "https://api.coordimap.com/collector/crawlers/infra"
debug: false

image:
  repository: coordimap/coordimap-agent
  tag: "latest"
  pullPolicy: Always

serviceAccount: default

resources:
  requests:
    memory: "150M"
    cpu: "500m"
    ephemeral-storage: "15Mi"
  limits:
    memory: "150M"
    cpu: "500m"
    ephemeral-storage: "15Mi"

dataSources:
  kubernetes:
    - id: prod-cluster-001
      inCluster: true
      crawlInterval: 30s

  postgres:
    - id: users-db-001
      dbName: users
      dbHost: users-db.example.com
      dbUser: users_admin
      dbPass: users_password
      crawlInterval: 60s
```

Install with a values file:

```bash
helm install coordimap-agent ./charts/agent \
  --namespace coordimap \
  --create-namespace \
  -f values.yaml
```

## Important configuration

| Key | Purpose |
| --- | --- |
| `apiKey` | Authenticates the agent with Coordimap |
| `endpoint` | Sets the collector API endpoint |
| `debug` | Enables verbose logging |
| `image.repository` | Chooses the container image |
| `image.tag` | Pins the deployed agent version |
| `serviceAccount` | Selects the Kubernetes service account |
| `resources.requests` | Reserves CPU, memory, and ephemeral storage |
| `resources.limits` | Caps CPU, memory, and ephemeral storage |
| `dataSources.*` | Defines database, cloud, and cluster collection targets |

See `charts/agent/values.yaml` for the full examples and defaults.

## Kubernetes resources created

This chart creates:

- a `Deployment` for the Coordimap Agent
- a `ConfigMap` for rendered agent configuration
- a `ClusterRole` and `ClusterRoleBinding` for Kubernetes discovery access

The RBAC template grants read access to common cluster resources such as nodes, namespaces, pods, services, configmaps, secrets, deployments, statefulsets, daemonsets, jobs, cronjobs, storage classes, and ingresses. Review these permissions before deploying in restricted environments.

## Validation and operations

```bash
helm lint ./charts/agent
helm template coordimap-agent ./charts/agent -f values.yaml
helm upgrade --install coordimap-agent ./charts/agent -n coordimap -f values.yaml
```

Useful checks after deployment:

```bash
kubectl get pods -n coordimap
kubectl describe deployment coordimap-agent-agent -n coordimap
kubectl logs deployment/coordimap-agent-agent -n coordimap
```

## Developer notes

- `apiKey` is required and template rendering fails if it is missing.
- Crawl intervals are validated in the templates and must end with `s`, `m`, or `h`.
- The generated agent config is assembled in `charts/agent/templates/configmap.yaml`.
- The deployment mounts the config at `/config.yaml` and passes the API key through the `API_KEY` environment variable.
- The default image tag is `latest`; pin a tested version for production.

## Learn more

- product website: [coordimap.com](https://coordimap.com)
- root repository guide: [`README.md`](../../README.md)
- chart metadata: [`charts/agent/Chart.yaml`](Chart.yaml)
- chart defaults: [`charts/agent/values.yaml`](values.yaml)
