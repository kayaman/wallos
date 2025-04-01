{{/*
Expand the name of the chart.
*/}}
{{- define "wallos.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wallos.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "wallos.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "wallos.labels" -}}
helm.sh/chart: {{ include "wallos.chart" . }}
{{ include "wallos.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.podLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "wallos.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wallos.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "wallos.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "wallos.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for ingress
*/}}
{{- define "wallos.ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">=1.19-0" .Capabilities.KubeVersion.GitVersion) -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if ingress is stable.
*/}}
{{- define "wallos.ingress.isStable" -}}
  {{- eq (include "wallos.ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "wallos.ingress.supportsPathType" -}}
  {{- or (eq (include "wallos.ingress.isStable" .) "true") (and (eq (include "wallos.ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">=1.18-0" .Capabilities.KubeVersion.GitVersion)) -}}
{{- end -}}

{{/*
Return the name for the DB PVC
*/}}
{{- define "wallos.db.pvc.name" -}}
{{- if .Values.persistence.db.existingClaim }}
{{- .Values.persistence.db.existingClaim }}
{{- else }}
{{- printf "%s-db" (include "wallos.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return the name for the Logos PVC
*/}}
{{- define "wallos.logos.pvc.name" -}}
{{- if .Values.persistence.logos.existingClaim }}
{{- .Values.persistence.logos.existingClaim }}
{{- else }}
{{- printf "%s-logos" (include "wallos.fullname" .) }}
{{- end }}
{{- end }}