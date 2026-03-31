# Coordimap Agent Helm Chart

The Coordimap Agent Helm chart deploys the Coordimap Agent on Kubernetes and renders an upstream-native `config.yaml` for the agent.

## Chart location

This chart is stored in `charts/agent`.

## Supported data sources

- PostgreSQL
- MariaDB
- MySQL
- Kubernetes
- AWS
- AWS Flow Logs
- GCP
- GCP Flow Logs
- MongoDB
- Flows

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
  - type: kubernetes
    name: k8s-cluster-1
    desc: Main Kubernetes Cluster
    config:
      - name: scope_id
        value: your_k8s_cluster_uid
      - name: in_cluster
        value: "true"
      - name: cluster_name
        value: main-cluster
      - name: crawl_interval
        value: 30s

  - type: postgres
    name: postgres-primary
    desc: Primary PostgreSQL Database
    config:
      - name: scope_id
        value: your-postgres-system-identifier
      - name: db_name
        value: mydatabase
      - name: db_host
        value: postgres.default.svc
      - name: db_user
        value: postgres
      - name: db_pass
        value: ${POSTGRES_PASSWORD}
      - name: ssl_mode
        value: require
      - name: crawl_interval
        value: 30s
```

## Important configuration

| Key | Purpose |
| --- | --- |
| `apiKey` | Injected as `COORDIMAP_API_KEY` for the agent config |
| `endpoint` | Sets the collector API endpoint |
| `debug` | Enables verbose logging |
| `serviceAccount` | Selects the Kubernetes service account used by the pod |
| `dataSources` | Upstream-native `coordimap.data_sources` entries |

## Notes

- `apiKey` is required and template rendering fails if it is missing.
- `crawl_interval` entries are validated in the templates and must end with `s`, `m`, or `h`.
- The generated agent config is assembled in `charts/agent/templates/configmap.yaml`.
- The deployment mounts the config at `/config.yaml` and injects the API key through the `COORDIMAP_API_KEY` environment variable.
