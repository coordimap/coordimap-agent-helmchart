# Coordimap Agent Helm Chart

Coordimap Agent Helm Chart helps developers, DevOps engineers, platform teams, and SREs deploy the Coordimap Agent on Kubernetes with Helm. The agent collects infrastructure metadata and metrics from supported data sources such as PostgreSQL, MariaDB, MySQL, Kubernetes, AWS, MongoDB, and GCP, then sends that data to the Coordimap platform for analysis, inventory, and visualization.

Coordimap is positioned on [coordimap.com](https://coordimap.com) as incident dependency mapping for Kubernetes-first SRE teams, with a focus on live dependency context, blast-radius analysis, and change correlation during incident response. This chart is the Kubernetes deployment entry point for teams that want to connect infrastructure discovery and metadata collection to that operational context.

If you are searching for a Kubernetes Helm chart for infrastructure discovery, cloud inventory collection, database metadata collection, or DevOps observability automation, this repository is the source for the Coordimap Agent chart.

## Why this chart exists

The chart provides a repeatable way to run the Coordimap Agent in Kubernetes environments where platform and operations teams need to:

- collect infrastructure metadata from multiple systems
- centralize inventory data from databases, clusters, and cloud providers
- standardize agent deployment across environments
- manage configuration with Helm values and GitOps workflows
- control resources, service accounts, and RBAC from one chart
- feed Coordimap with the infrastructure context used for faster incident triage and dependency-aware operations

## About Coordimap

According to the messaging on [coordimap.com](https://coordimap.com), Coordimap is built for Kubernetes-first SRE and platform teams that need:

- incident dependency mapping across services and infrastructure
- dependency-aware incident response workflows
- blast-radius analysis during outages and risky changes
- recent change visibility and change correlation during triage
- live infrastructure context that helps teams move from alert to action faster

This Helm chart supports that workflow by deploying the data collection layer used to supply infrastructure context from Kubernetes, cloud accounts, and databases.

## Who should use it

- DevOps engineers managing Kubernetes-based infrastructure
- platform engineers building internal observability or asset inventory workflows
- SRE teams that need repeatable Helm-based deployments
- developers who want to connect application infrastructure data to Coordimap
- cloud operations teams working across AWS, GCP, databases, and clusters

## Repository layout

```text
.
├── README.md
└── charts/
    └── agent/
        ├── Chart.yaml
        ├── values.yaml
        ├── values.schema.json
        └── templates/
```

The deployable Helm chart lives in `charts/agent`.

## Supported data sources

The current chart templates support these Coordimap Agent data source types:

- PostgreSQL
- MariaDB
- MySQL
- Kubernetes
- AWS
- AWS Flow Logs
- MongoDB
- GCP
- GCP Flow Logs
- Flows

Each source is configured with the upstream-native `type`, `id`, and `config` entries so the chart can track the agent config format without per-type Helm rewrites. The `id` must be copied from the Coordimap UI after creating the data source there.

## Prerequisites

- Kubernetes cluster
- Helm 3
- `kubectl` configured for the target cluster
- a valid Coordimap API key
- access to a Coordimap workspace or account at [coordimap.com](https://coordimap.com)
- network access from the cluster to `https://api.coordimap.com/collector/crawlers/infra`

## Quick start

Install the chart directly from this repository:

```bash
helm install coordimap-agent ./charts/agent \
  --namespace coordimap \
  --create-namespace \
  --set apiKey="YOUR_API_KEY"
```

For production-style deployments, use a values file instead of inline secrets.

## OCI distribution

This repository is prepared to publish the chart as an OCI artifact to GitHub Container Registry. The recommended OCI reference for Artifact Hub registration is:

```text
oci://ghcr.io/coordimap/charts/coordimap-agent
```

Once a chart version is published, install it with Helm OCI support:

```bash
helm registry login ghcr.io
helm install coordimap-agent oci://ghcr.io/coordimap/charts/coordimap-agent \
  --version 0.1.0 \
  --namespace coordimap \
  --create-namespace \
  -f values.yaml
```

## Example values file

```yaml
apiKey: "YOUR_API_KEY"
endpoint: "https://api.coordimap.com/collector/crawlers/infra"
debug: false

image:
  repository: coordimap/coordimap-agent
  tag: "latest"
  pullPolicy: Always

serviceAccount:
  create: true
  name: ""
  annotations: {}

commonLabels:
  environment: production
  team: platform

skipFields:
  - db_pass
  - access_key_id
  - secret_access_key

extraEnv:
  - name: LOG_LEVEL
    value: info
  - name: POSTGRES_PASSWORD
    valueFrom:
      secretKeyRef:
        name: postgres-secret
        key: password
  - name: AWS_ACCESS_KEY_ID
    valueFrom:
      secretKeyRef:
        name: aws-credentials
        key: access-key-id
  - name: AWS_SECRET_ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: aws-credentials
        key: secret-access-key

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
    id: ds_k8s_cluster_1
    config:
      - name: scope_id
        value: your_k8s_cluster_uid
      - name: in_cluster
        value: "true"
      - name: cluster_name
        value: main-cluster
      - name: crawl_interval
        value: 30s
    metric_rules:
      - id: k8s-high-5xx
        name: Kubernetes Service High 5xx
        provider: prometheus
        mode: predefined
        predefined:
          name: kubernetes_service_high_5xx
          params:
            window: 5m
            threshold: 1

  - type: postgres
    id: ds_postgres_primary
    config:
      - name: scope_id
        value: your-postgres-system-identifier
      - name: db_name
        value: users
      - name: db_host
        value: users-db.example.com
      - name: db_user
        value: users_admin
      - name: db_pass
        value: ${POSTGRES_PASSWORD}
      - name: crawl_interval
        value: 60s

  - type: aws
    id: ds_aws_production
    config:
      - name: scope_id
        value: your-aws-account-id
      - name: policy_config
        value: "true"
      - name: access_key_id
        value: ${AWS_ACCESS_KEY_ID}
      - name: secret_access_key
        value: ${AWS_SECRET_ACCESS_KEY}
      - name: crawl_interval
        value: 120s
```

Install with that file:

```bash
helm install coordimap-agent ./charts/agent \
  --namespace coordimap \
  --create-namespace \
  -f values.yaml
```

## Environment variables

Use `extraEnv` to add environment variables to the agent pod.

Set a literal value:

```yaml
extraEnv:
  - name: LOG_LEVEL
    value: info
```

Reference a Kubernetes Secret:

```yaml
extraEnv:
  - name: POSTGRES_PASSWORD
    valueFrom:
      secretKeyRef:
        name: postgres-secret
        key: password
```

This is useful when a data source config expects an environment variable placeholder such as `${POSTGRES_PASSWORD}` or `${AWS_SECRET_ACCESS_KEY}`.

## Skip fields

Use `skipFields` to omit data source config keys from the payload sent to Coordimap. The chart renders this value as upstream `coordimap.skip_fields` in the generated agent config.

Example:

```yaml
skipFields:
  - db_pass
  - access_key_id
  - secret_access_key
```

This does not remove fields from the agent's local runtime configuration. The agent can still use credentials and connection settings while crawling, then strips matching config keys from `data_source_config.value_pairs` before sending data to the collector.

Use lowercase names that match `dataSources[].config[].name`. The agent lowercases data source config keys before comparing them to `skip_fields`.

## Service accounts

Use `serviceAccount` to control whether the chart creates a Kubernetes service account or binds to an existing one.

Create and manage the service account from the chart:

```yaml
serviceAccount:
  create: true
  name: ""
  annotations: {}
```

Use an existing service account:

```yaml
serviceAccount:
  create: false
  name: coordimap-agent
```

Example for GKE Workload Identity:

```yaml
serviceAccount:
  create: true
  name: coordimap-agent
  annotations:
    iam.gke.io/gcp-service-account: coordimap-agent@test.iam.gserviceaccount.com
```

When `serviceAccount.name` is empty, the chart defaults to `<release-name>-agent`.

Example with `dataSources`:

```yaml
extraEnv:
  - name: POSTGRES_PASSWORD
    valueFrom:
      secretKeyRef:
        name: postgres-secret
        key: password

dataSources:
  - type: postgres
    id: ds_postgres_primary
    config:
      - name: db_host
        value: users-db.example.com
      - name: db_user
        value: users_admin
      - name: db_pass
        value: ${POSTGRES_PASSWORD}
```

## Configuration highlights

Important values for developers and DevOps engineers:

| Key                          | Purpose                                                             |
| ---------------------------- | ------------------------------------------------------------------- |
| `apiKey`                     | Authenticates the agent with Coordimap                              |
| `endpoint`                   | Sets the collector API endpoint                                     |
| `debug`                      | Enables verbose agent logging                                       |
| `skipFields`                 | Omits matching data source config keys from outbound payloads       |
| `image.repository`           | Chooses the container image                                         |
| `image.tag`                  | Pins the deployed agent version                                     |
| `serviceAccount.create`      | Controls whether the chart creates the Kubernetes service account   |
| `serviceAccount.name`        | Sets the Kubernetes service account name                            |
| `serviceAccount.annotations` | Adds annotations to a chart-managed service account                 |
| `commonLabels`               | Adds custom labels to all rendered resources and pods               |
| `extraEnv`                   | Adds extra pod environment variables from literal values or Secrets |
| `resources.requests`         | Reserves CPU, memory, and ephemeral storage                         |
| `resources.limits`           | Caps CPU, memory, and ephemeral storage                             |
| `dataSources`                | Defines upstream-native agent data source entries                   |
| `dataSources[].metric_rules` | Defines optional metric trigger rules for kubernetes and gcp        |

See `charts/agent/values.yaml` for the full set of examples and defaults.

## Data source IDs

Each entry in `dataSources` must include an `id` string from the Coordimap UI.

The chart does not support `name` or `desc` for agent data sources. Create or inspect the data source in the Coordimap UI, copy its ID, and place it in your values file.

Example:

```yaml
dataSources:
  - type: postgres
    id: ds_postgres_primary
    config:
      - name: db_host
        value: users-db.example.com
      - name: db_user
        value: users_admin
```

## Metric trigger rules

Metric trigger rules can be set per data source and are rendered into `coordimap.data_sources[*].metric_rules`.

- supported source types: `kubernetes`, `gcp`
- supported providers: `prometheus`, `gcp_monitoring`
- required fields per rule: `id`, `name`, `provider`, `mode`
- `mode: custom` requires `custom`
- `mode: predefined` requires `predefined`
- use either `metric_rules` (snake_case) or `metricRules` (camelCase) in Helm values, but not both in the same data source

Example:

```yaml
dataSources:
  - type: gcp
    id: ds_gcp_prod
    config:
      - name: scope_id
        value: "123456789012"
      - name: project_id
        value: my-gcp-project
      - name: crawl_interval
        value: 30s
    metric_rules:
      - id: cloudsql-high-cpu
        name: CloudSQL High CPU
        provider: gcp_monitoring
        mode: predefined
        predefined:
          name: cloudsql_high_cpu
          params:
            lookback: 5m
            threshold: 0.8
```

## Kubernetes and security behavior

This chart deploys:

- a `Deployment` for the Coordimap Agent
- a `ConfigMap` that renders the agent configuration
- a `ClusterRole` and `ClusterRoleBinding` for cluster discovery access

The RBAC template grants read access to common Kubernetes resources including nodes, namespaces, pods, services, deployments, statefulsets, daemonsets, jobs, cronjobs, storage classes, ingresses, configmaps, and secrets. Review these permissions before using the chart in restricted or multi-tenant clusters.

## Operations workflow

Validate, render, and upgrade the chart with standard Helm commands:

```bash
helm lint ./charts/agent
helm template coordimap-agent ./charts/agent -f values.yaml
helm upgrade --install coordimap-agent ./charts/agent -n coordimap -f values.yaml
```

Useful post-deployment checks:

```bash
kubectl get pods -n coordimap
kubectl describe deployment coordimap-agent-agent -n coordimap
kubectl logs deployment/coordimap-agent-agent -n coordimap
```

## Publishing to Artifact Hub with OCI

Artifact Hub does not host charts directly. It indexes the OCI repository where the chart is published. For this repository, the intended flow is:

- publish `coordimap-agent` to GitHub Container Registry as an OCI Helm chart
- push `artifacthub-repo.yml` to the same OCI repository using the special `artifacthub.io` tag
- register `oci://ghcr.io/coordimap/charts/coordimap-agent` as a Helm repository in Artifact Hub

This repository includes a GitHub Actions workflow in `.github/workflows/publish-helm-oci.yml` that:

- lints the chart
- packages the chart
- pushes the chart to `ghcr.io`
- pushes Artifact Hub repository metadata with ORAS

The workflow runs on tags that match `chart-v*` and can also be started manually.

## Developer notes

- The chart currently uses `latest` as the default image tag; pin a fixed tag in production for safer rollouts.
- `apiKey` is required and chart rendering fails if it is missing.
- `extraEnv` supports either `value` or `valueFrom.secretKeyRef` for each variable.
- `skipFields` renders to `coordimap.skip_fields` and strips matching data source config keys from outbound payloads.
- Crawl intervals are validated in the templates and must end with `s`, `m`, or `h`.
- The generated agent configuration is assembled from Helm values in `charts/agent/templates/configmap.yaml`.
- The deployment mounts the generated config at `/config.yaml`, injects the API key through `COORDIMAP_API_KEY`, and appends any entries from `extraEnv` to the pod environment.
- Metric rules are supported for `kubernetes` and `gcp` data sources and rendered to `metric_rules` in the generated config.
- The chart accepts both `metric_rules` and `metricRules` in values; setting both keys on one source fails validation.

## Use cases and search topics

This repository is relevant for teams looking for:

- Kubernetes Helm chart for infrastructure inventory
- Helm-based deployment for observability agents
- DevOps automation for cloud and database discovery
- platform engineering tooling for infrastructure metadata collection
- Kubernetes agent deployment for AWS, GCP, PostgreSQL, MariaDB, MySQL, and MongoDB
- Coordimap Agent installation, configuration, and upgrade guidance
- incident dependency mapping setup for Kubernetes-first SRE teams
- blast-radius analysis and change-correlation data collection for incident response

## FAQ

### What does the Coordimap Agent collect?

The agent is designed to collect infrastructure metadata and related metrics from configured data sources and forward them to the Coordimap platform. That infrastructure context supports product use cases described on [coordimap.com](https://coordimap.com), including dependency-aware incident response, blast-radius analysis, and change visibility for SRE and platform teams.

### Where can I learn more about the Coordimap product?

Visit [coordimap.com](https://coordimap.com) for the main product overview, positioning, and pricing information.

### Where is the Helm chart in this repository?

The chart is stored in `charts/agent`.

### Can I use this chart in GitOps workflows?

Yes. The chart is a standard Helm chart and can be rendered, linted, versioned, and promoted through GitOps pipelines such as Argo CD or Flux.

### Should I use `latest` in production?

No. For production Kubernetes environments, pin `image.tag` to a tested version so rollouts are predictable and auditable.

## Additional reference

- chart metadata: `charts/agent/Chart.yaml`
- default values: `charts/agent/values.yaml`
- deployment template: `charts/agent/templates/deployment.yaml`
- config rendering: `charts/agent/templates/configmap.yaml`
- RBAC rules: `charts/agent/templates/rbac.yaml`
