{{/*
Validate supported data source types.
*/}}
{{- define "coordimap.datasource.validate" -}}
{{- $validTypes := list "aws" "gcp" "postgres" "mysql" "mariadb" "kubernetes" "aws_flow_logs" "flows" "mongodb" "gcp_flow_logs" -}}
{{- $metricRuleTypes := list "kubernetes" "gcp" -}}
{{- range $source := .Values.dataSources -}}
{{- if not (has $source.type $validTypes) -}}
{{- fail (printf "Invalid data source type: %s. Allowed types are: %s" $source.type (join ", " $validTypes)) -}}
{{- end -}}
{{- $hasCamelMetricRules := hasKey $source "metricRules" -}}
{{- $hasSnakeMetricRules := hasKey $source "metric_rules" -}}
{{- if and $hasCamelMetricRules $hasSnakeMetricRules -}}
{{- fail (printf "Data source %s uses both metricRules and metric_rules. Set only one." $source.id) -}}
{{- end -}}
{{- if and (or $hasCamelMetricRules $hasSnakeMetricRules) (not (has $source.type $metricRuleTypes)) -}}
{{- fail (printf "Data source %s has metric rules but type %s does not support metric rules. Supported types are: %s" $source.id $source.type (join ", " $metricRuleTypes)) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Common labels applied to all chart resources.
*/}}
{{- define "coordimap.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{/*
Resolve the service account name from either the legacy string value or
the structured serviceAccount object.
*/}}
{{- define "coordimap.serviceAccountName" -}}
{{- if kindIs "string" .Values.serviceAccount -}}
{{- default (printf "%s-agent" .Release.Name) .Values.serviceAccount -}}
{{- else -}}
{{- default (printf "%s-agent" .Release.Name) .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
Whether the chart should create the service account.
Legacy string values imply using an existing account unless empty.
*/}}
{{- define "coordimap.serviceAccountCreate" -}}
{{- if kindIs "string" .Values.serviceAccount -}}
{{- if .Values.serviceAccount }}false{{ else }}true{{ end -}}
{{- else -}}
{{- if hasKey .Values.serviceAccount "create" -}}
{{- .Values.serviceAccount.create -}}
{{- else -}}
true
{{- end -}}
{{- end -}}
{{- end -}}
