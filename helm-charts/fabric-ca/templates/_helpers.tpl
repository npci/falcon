{{/*
Copyright National Payments Corporation of India. All Rights Reserved.
SPDX-License-Identifier:  GPL-3.0
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "fabric-ca.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fabric-ca.fullname" -}}
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
{{- define "fabric-ca.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fabric-ca.labels" -}}
helm.sh/chart: {{ include "fabric-ca.chart" . }}
{{ include "fabric-ca.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fabric-ca.selectorLabels" -}}
project: {{ .Values.project }}
app.kubernetes.io/name: {{ include "fabric-ca.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Values.additionalLabels }}
{{ toYaml .Values.additionalLabels }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "fabric-ca.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fabric-ca.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Common env variables
*/}}
{{- define "fabric-ca.fabricEnv" -}}
- name: CA_ADMIN_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.ca_server.admin_secret }}
      key: user
- name: CA_ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.ca_server.admin_secret }}
      key: password
- name: FABRIC_CA_SERVER_HOME
  value: {{ .Values.storage.path }}
- name: FABRIC_CA_SERVER_TLS_ENABLED
  value: {{ .Values.ca_server.tls_enabled | quote }}
{{- if not .Values.ica.enabled }}
- name: FABRIC_CA_SERVER_CSR_CN
  value: {{ include "fabric-ca.fullname" . | quote }}
{{- end }}
- name: FABRIC_CA_SERVER_PORT
  value: {{ .Values.ca_server.container_port | quote }}
- name: FABRIC_CA_SERVER_CSR_HOSTS
  value: "{{ include "fabric-ca.fullname" . }},{{ include "fabric-ca.fullname" . }}.{{ .Values.tls_domain }} {{- if .Values.ca_server.additional_sans }},{{ join "," .Values.ca_server.additional_sans }} {{- end }}"
- name: FABRIC_CA_SERVER_DEBUG
  value: {{ .Values.ca_server.debug | quote }}
- name: FABRIC_CA_SERVER_CA_NAME
  value: {{ include "fabric-ca.fullname" . | quote }}
  {{- if .Values.ica.enabled }}
- name: FABRIC_CA_SERVER_INTERMEDIATE_TLS_CERTFILES
  value: "{{ .Values.ica.intermediate_tls_cert_dir }}/{{ .Values.ica.intermediate_tls_cert_file }}"
  {{- end }}
{{- end }}