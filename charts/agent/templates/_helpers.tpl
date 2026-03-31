{{/*
Validate supported data source types.
*/}}
{{- define "coordimap.datasource.validate" -}}
{{- $validTypes := list "aws" "gcp" "postgres" "mysql" "mariadb" "kubernetes" "aws_flow_logs" "flows" "mongodb" "gcp_flow_logs" -}}
{{- range $source := .Values.dataSources -}}
{{- if not (has $source.type $validTypes) -}}
{{- fail (printf "Invalid data source type: %s. Allowed types are: %s" $source.type (join ", " $validTypes)) -}}
{{- end -}}
{{- end -}}
{{- end -}}
