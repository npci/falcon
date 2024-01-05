{{/*
Copyright National Payments Corporation of India. All Rights Reserved.
SPDX-License-Identifier:  GPL-3.0
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "fabric-orderer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fabric-orderer.fullname" -}}
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
{{- define "fabric-orderer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fabric-orderer.labels" -}}
helm.sh/chart: {{ include "fabric-orderer.chart" . }}
{{ include "fabric-orderer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fabric-orderer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fabric-orderer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
project: {{ .Values.project }}
{{- if .Values.global.additionalLabels }}
{{ toYaml .Values.global.additionalLabels }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "fabric-orderer.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fabric-orderer.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}