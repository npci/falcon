{{/*
Copyright National Payments Corporation of India. All Rights Reserved.
SPDX-License-Identifier:  GPL-3.0
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "fabric-ops.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fabric-ops.fullname" -}}
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
{{- define "fabric-ops.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fabric-ops.labels" -}}
helm.sh/chart: {{ include "fabric-ops.chart" . }}
{{ include "fabric-ops.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fabric-ops.selectorLabels" -}}
project: {{ .Values.project }}
app.kubernetes.io/name: {{ include "fabric-ops.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "fabric-ops.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fabric-ops.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Common env variables
*/}}
{{- define "fabric-ops.fabricEnv" -}}
- name: CA_ADMIN_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.ca_secret }}
      key: user
- name: CA_ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.ca_secret }}
      key: password
{{- end }}
