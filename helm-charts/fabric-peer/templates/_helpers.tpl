{{/*
Copyright National Payments Corporation of India. All Rights Reserved.
SPDX-License-Identifier:  GPL-3.0
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "fabric-peer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fabric-peer.fullname" -}}
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
{{- define "fabric-peer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fabric-peer.labels" -}}
helm.sh/chart: {{ include "fabric-peer.chart" . }}
{{ include "fabric-peer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fabric-peer.selectorLabels" -}}
project: {{ .Values.project }}
app.kubernetes.io/name: {{ include "fabric-peer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "fabric-peer.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fabric-peer.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Peer GlobalEnv variables
*/}}
{{- define "fabric-peer.envVars" -}}
- name: CORE_LEDGER_HISTORY_ENABLEHISTORYDATABASE
  value: "false"
- name: CORE_PEER_GOSSIP_MAXBLOCKCOUNTTOSTORE
  value: "20"
- name: CORE_PEER_GOSSIP_MAXPROPAGATIONBURSTSIZE
  value: "20"
- name: FABRIC_LOGGING_SPEC
  value: INFO
- name: CORE_PEER_CHAINCODELISTENADDRESS
  value: localhost:7052
- name: CORE_PEER_GOSSIP_USELEADERELECTION
  value: "false"
- name: CORE_PEER_GOSSIP_ORGLEADER
  value: "true"
- name: CORE_PEER_PROFILE_ENABLED
  value: "true"
- name: CORE_PEER_TLS_CERT_FILE
  value: {{ $.Values.fabric_base_dir }}/tls/server.crt
- name: CORE_PEER_TLS_ENABLED
  value: "true"
- name: CORE_PEER_TLS_KEY_FILE
  value: {{ $.Values.fabric_base_dir }}/tls/server.key
- name: CORE_PEER_TLS_ROOTCERT_FILE
  value: {{ $.Values.fabric_base_dir }}/tls/ca.crt
- name: CORE_PEER_LOCALMSPID
  value: {{ .Values.nameOverride }}
- name: CORE_VM_ENDPOINT
  value: http://localhost:2375
- name: DOCKER_HOST
  value: tcp://localhost:2375
- name: CORE_OPERATIONS_LISTENADDRESS
  value: 0.0.0.0:9443
{{- end }}
