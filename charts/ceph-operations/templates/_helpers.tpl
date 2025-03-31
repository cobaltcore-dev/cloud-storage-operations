{{/* Generate basic labels */}}
{{- define "cloud-storage-operations.labels" }}
{{- $path := index . 0 -}}
{{- $root := index . 1 -}}
app.cloud-storage.io/version: {{ $root.Chart.Version }}
app.cloud-storage.io/part-of: {{ $root.Release.Name }}
{{- if $root.Values.global.commonLabels}}
{{ toYaml $root.Values.global.commonLabels }}
{{- end }}
{{- end }}

{{- define "cloud-storage-operations.ruleSelectorLabels" }}
{{- $path := index . 0 -}}
{{- $root := index . 1 -}}
{{- if $root.Values.prometheusRules.ruleSelectors }}
{{- range $i, $target := $root.Values.prometheusRules.ruleSelectors }}
{{ $target.name | required (printf "$.Values.prometheusRules.ruleSelector.[%v].name missing" $i) }}: {{ tpl ($target.value | required (printf "$.Values.prometheusRules.ruleSelector.[%v].value missing" $i)) $root }}
{{- end }}
{{- end }}
{{- end }}

{{- define "cloud-storage-operations.additionalRuleLabels" }}
{{- if .Values.prometheusRules.additionalRuleLabels }}
{{- tpl (toYaml .Values.prometheusRules.additionalRuleLabels) . }}
{{- end }}
{{- if .Values.global.commonLabels }}
{{- tpl (toYaml .Values.global.commonLabels) . }}
{{- end }}
{{- end }}

{{- define "cloud-storage-operations.dashboardSelectorLabels" }}
{{- $path := index . 0 -}}
{{- $root := index . 1 -}}
{{- if $root.Values.dashboards.dashboardSelectors }}
{{- range $i, $target := $root.Values.dashboards.dashboardSelectors }}
{{ $target.name | required (printf "$.Values.dashboards.dashboardSelectors.[%v].name missing" $i) }}: {{ tpl ($target.value | required (printf "$.Values.dashboards.dashboardSelectors.[%v].value missing" $i)) $ }}
{{- end }}
{{- end }}
{{- end }}

{{- define "cloud-storage-operations.globalDashboardSelectorLabels" }}
{{- $path := index . 0 -}}
{{- $root := index . 1 -}}
{{- if $root.Values.dashboards.global.dashboardSelectors }}
{{- range $i, $target := $root.Values.dashboards.global.dashboardSelectors }}
{{ $target.name | required (printf "$.Values.dashboards.global.dashboardSelectors.[%v].name missing" $i) }}: {{ tpl ($target.value | required (printf "$.Values.dashboards.global.dashboardSelectors.[%v].value missing" $i)) $ }}
{{- end }}
{{- end }}
{{- end }}

{{- define "cloud-storage-operations.persesDashboardSelectorLabels" }}
{{- $path := index . 0 -}}
{{- $root := index . 1 -}}
{{- if $root.Values.persesDashboards.dashboardSelectors }}
{{- range $i, $target := $root.Values.persesDashboards.dashboardSelectors }}
{{ $target.name | required (printf "$.Values.persesDashboardSelectorLabels.dashboardSelectors.[%v].name missing" $i) }}: {{ tpl ($target.value | required (printf "$.Values.persesDashboardSelectorLabels.dashboardSelectors.[%v].value missing" $i)) $ }}
{{- end }}
{{- end }}
{{- end }}
