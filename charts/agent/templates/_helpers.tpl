{{/*
Validate data source type and return configuration
*/}}
{{- define "coordimap.datasource.config" -}}
{{- $validTypes := (list "postgres" "mariadb" "mysql" "kubernetes" "aws" "mongodb") -}}
{{- range $type, $sources := .Values.dataSources -}}
{{- if not (has $type $validTypes) -}}
{{- fail (printf "Invalid data source type: %s. Allowed types are: %s" $type (join ", " $validTypes)) -}}
{{- end -}}
{{- end -}}
{{- end -}}
