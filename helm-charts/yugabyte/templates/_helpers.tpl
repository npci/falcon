{{/* vim: set filetype=mustache: */}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
The components in this chart create additional resources that expand the longest created name strings.
The longest name that gets created of 20 characters, so truncation should be 63-20=43.
*/}}
{{- define "yugabyte.fullname" -}}
  {{- if .Values.fullnameOverride -}}
    {{- .Values.fullnameOverride | trunc 43 | trimSuffix "-" -}}
  {{- else -}}
    {{- $name := default .Chart.Name .Values.nameOverride -}}
    {{- if contains $name .Release.Name -}}
      {{- .Release.Name | trunc 43 | trimSuffix "-" -}}
    {{- else -}}
      {{- printf "%s-%s" .Release.Name $name | trunc 43 | trimSuffix "-" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Generate common labels.
Excludes chart-managed labels from commonLabels to prevent overriding them.
Chart-managed labels include: heritage, release (used in selectors), chart, component, app, app.kubernetes.io/name
*/}}
{{- define "yugabyte.labels" }}
heritage: {{ .Values.helm2Legacy | ternary "Tiller" (.Release.Service | quote) }}
release: {{ .Release.Name | quote }}
chart: {{ .Chart.Name | quote }}
component: {{ .Values.Component | quote }}
{{- if .Values.commonLabels}}
{{- $filteredLabels := .Values.commonLabels }}
{{- if .Values.oldNamingStyle }}
{{- $filteredLabels = omit $filteredLabels "heritage" "release" "chart" "component" "app" }}
{{- else }}
{{- $filteredLabels = omit $filteredLabels "heritage" "release" "chart" "component" "app" "app.kubernetes.io/name" }}
{{- end }}
{{ toYaml $filteredLabels }}
{{- end }}
{{- end }}

{{/*
Generate app label.
*/}}
{{- define "yugabyte.applabel" }}
{{- if .root.Values.oldNamingStyle }}
app: "{{ .label }}"
{{- else }}
app.kubernetes.io/name: "{{ .label }}"
{{- end }}
{{- end }}

{{/*
Generate app selector.
*/}}
{{- define "yugabyte.appselector" }}
{{- if .root.Values.oldNamingStyle }}
app: "{{ .label }}"
{{- else }}
app.kubernetes.io/name: "{{ .label }}"
{{- end }}
release: {{ .root.Release.Name | quote }}
{{- end }}

{{/*
Generate service name.
*/}}
{{- define "yugabyte.servicename" }}
  {{- if eq .scope "Namespaced" }}
    {{- $prefix := (get (.root.Values.commonLabels | default dict) "app.kubernetes.io/part-of" | default "namespaced") | trunc 43 | trimSuffix "-" }}
      {{- if $prefix }}
        {{- printf "%s-%s" $prefix .endpoint.name }}
      {{- else }}
        {{- .endpoint.name }}
      {{- end }}
  {{- else }}
    {{- .root.Values.oldNamingStyle | ternary .endpoint.name (printf "%s-%s" (include "yugabyte.fullname" $.root) .endpoint.name) }}
  {{- end }}
{{- end }}

{{/*
Get service scope
*/}}
{{- define "yugabyte.servicescope" }}
  {{- if .endpoint.scope }}
    {{- .endpoint.scope }}
  {{- else }}
    {{- .defaultScope }}
  {{- end }}
{{- end }}

{{/*
Generate namespaced service selector.
*/}}
{{- define "yugabyte.namespacedserviceselector" }}
app.kubernetes.io/name: "{{ .label }}"
{{- $partof := (get (.root.Values.commonLabels | default dict) "app.kubernetes.io/part-of" | default "")}}
{{- if $partof }}
app.kubernetes.io/part-of: "{{ $partof }}"
{{- end }}
{{- end }}

{{/*
Checks if a service is required to be installed/upgraded
*/}}
{{- define "yugabyte.should_render_service" -}}
  {{- if eq .scope "AZ" }}
    {{- "true" }}
  {{- else }}
    {{- $namespacedService := (lookup "v1" "Service" .root.Release.Namespace .serviceName) }}
    {{- if not $namespacedService }}
      {{- "true" }}
    {{- else }}
      {{- $ownerRelease := (get $namespacedService.metadata.annotations "meta.helm.sh/release-name") | default "" }}
        {{- if eq $ownerRelease .root.Release.Name }}
          {{- "true" }}
        {{- else }}
          {{- "false" }}
        {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

{{/*
Create secrets in DBNamespace from other namespaces by iterating over envSecrets.
*/}}
{{- define "yugabyte.envsecrets" -}}
{{- range $v := .secretenv }}
{{- if $v.valueFrom.secretKeyRef.namespace }}
{{- $secretObj := (lookup
"v1"
"Secret"
$v.valueFrom.secretKeyRef.namespace
$v.valueFrom.secretKeyRef.name)
| default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $secretValue := (get $secretData $v.valueFrom.secretKeyRef.key) | default "" }}
{{- if (and (not $secretValue) (not $v.valueFrom.secretKeyRef.optional)) }}
{{- required (printf "Secret or key missing for %s/%s in namespace: %s"
$v.valueFrom.secretKeyRef.name
$v.valueFrom.secretKeyRef.key
$v.valueFrom.secretKeyRef.namespace)
nil }}
{{- end }}
{{- if $secretValue }}
apiVersion: v1
kind: Secret
metadata:
  {{- $secretfullname := printf "%s-%s-%s-%s"
  $.root.Release.Name
  $v.valueFrom.secretKeyRef.namespace
  $v.valueFrom.secretKeyRef.name
  $v.valueFrom.secretKeyRef.key
  }}
  name: {{ printf "%s-%s-%s-%s-%s-%s"
  $.root.Release.Name
  ($v.valueFrom.secretKeyRef.namespace | substr 0 5)
  ($v.valueFrom.secretKeyRef.name | substr 0 5)
  ( $v.valueFrom.secretKeyRef.key | substr 0 5)
  (sha256sum $secretfullname | substr 0 4)
  ($.suffix)
  | lower | replace "." "" | replace "_" ""
  }}
  namespace: "{{ $.root.Release.Namespace }}"
  labels:
    {{- include "yugabyte.labels" $.root | indent 4 }}
type: Opaque # should it be an Opaque secret?
data:
  {{ $v.valueFrom.secretKeyRef.key }}: {{ $secretValue | quote }}
{{- end }}
{{- end }}
---
{{- end }}
{{- end }}

{{/*
Add env secrets to DB statefulset.
*/}}
{{- define "yugabyte.addenvsecrets" -}}
{{- range $v := .secretenv }}
- name: {{ $v.name }}
  valueFrom:
    secretKeyRef:
      {{- if $v.valueFrom.secretKeyRef.namespace }}
      {{- $secretfullname := printf "%s-%s-%s-%s"
      $.root.Release.Name
      $v.valueFrom.secretKeyRef.namespace
      $v.valueFrom.secretKeyRef.name
      $v.valueFrom.secretKeyRef.key
      }}
      name: {{ printf "%s-%s-%s-%s-%s-%s"
      $.root.Release.Name
      ($v.valueFrom.secretKeyRef.namespace | substr 0 5)
      ($v.valueFrom.secretKeyRef.name | substr 0 5)
      ($v.valueFrom.secretKeyRef.key | substr 0 5)
      (sha256sum $secretfullname | substr 0 4)
      ($.suffix)
      | lower | replace "." "" | replace "_" ""
      }}
      {{- else }}
      name: {{ $v.valueFrom.secretKeyRef.name }}
      {{- end }}
      key: {{ $v.valueFrom.secretKeyRef.key }}
      optional: {{ $v.valueFrom.secretKeyRef.optional | default "false" }}
{{- end }}
{{- end }}
{{/*
Create Volume name.
*/}}
{{- define "yugabyte.volume_name" -}}
  {{- printf "%s-datadir" (include "yugabyte.fullname" .) -}}
{{- end -}}

{{/*
Derive the memory hard limit in bytes for Master and Tserver components based on
a given memory size and a limit percentage.

The function expects two parameters:
1. 'size': Specifies memory in 'G' or 'Gi' format (e.g., "2Gi").
2. 'limitPercent': An integer representing the percentage of the memory limit (e.g., 85 for 85%).

It uses a base multiplier of 1000 for 'G' units and 1024 for 'Gi' units.
*/}}
{{- define "yugabyte.memory_hard_limit" -}}
  {{- $baseMultiplier := 1000 -}}
  {{- if .size | toString | hasSuffix "Gi"  -}}
    {{- $baseMultiplier = 1024 -}}
  {{- end -}}
  {{- $limit_percent := .limitPercent -}}
  {{- $multiplier := int (div (mul $limit_percent $baseMultiplier) 100) -}}
  {{- printf "%d" .size | regexFind "\\d+" | mul $baseMultiplier | mul $baseMultiplier | mul $multiplier -}}
{{- end -}}

{{/*
Resolve TLS root CA data from either inline values or an existing Secret.
*/}}
{{- define "yugabyte.tlsRootCA" -}}
{{- $root := .root -}}
{{- $secretName := $root.Values.tls.rootCA.existingSecret | default "" -}}
{{- $cert := $root.Values.tls.rootCA.cert | default "" -}}
{{- $key := $root.Values.tls.rootCA.key | default "" -}}
{{- if $secretName -}}
{{- $secret := lookup "v1" "Secret" $root.Release.Namespace $secretName | default dict -}}
{{- $secretData := get $secret "data" | default dict -}}
{{- $certData := get $secretData ($root.Values.tls.rootCA.certKey | default "ca.crt") | default "" -}}
{{- $keyData := get $secretData ($root.Values.tls.rootCA.keyKey | default "ca.key") | default "" -}}
{{- if not (empty $certData) -}}
{{- $cert = $certData -}}
{{- end -}}
{{- if not (empty $keyData) -}}
{{- $key = $keyData -}}
{{- end -}}
{{- end -}}
{{- dict "cert" $cert "key" $key | toYaml -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "yugabyte.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate a preflight check script invocation.
*/}}
{{- define "yugabyte.preflight_check" -}}
{{- if not .Values.preflight.skipAll -}}
{{- $port := .Preflight.Port -}}
{{- range $addr := split "," .Preflight.Addr -}}
if [ -f /home/yugabyte/tools/k8s_preflight.py ]; then
  PYTHONUNBUFFERED="true" /home/yugabyte/tools/k8s_preflight.py \
    dnscheck \
    --addr="{{ $addr }}" \
{{- if not $.Values.preflight.skipBind }}
    --port="{{ $port }}"
{{- else }}
    --skip_bind
{{- end }}
fi && \
{{ end }}
{{- end }}
{{- end }}

{{/*
Get YugaByte fs data directories.
*/}}
{{- define "yugabyte.fs_data_dirs" -}}
  {{- range $index := until (int (.count)) -}}
    {{- if ne $index 0 }},{{ end }}/mnt/disk{{ $index -}}
  {{- end -}}
{{- end -}}

{{/*
Get files from fs data directories for readiness / liveness probes.
*/}}
{{- define "yugabyte.fs_data_dirs_probe_files" -}}
  {{- range $index := until (int (.count)) -}}
    {{- if ne $index 0 }} {{ end }}"/mnt/disk{{ $index -}}/disk.check"
  {{- end -}}
{{- end -}}


{{/*
Command to do a disk write and sync for liveness probes.
*/}}
{{- define "yugabyte.fs_data_dirs_probe" -}}
echo "disk check at: $(date)" \
  | tee {{ template "yugabyte.fs_data_dirs_probe_files" . }} \
  && sync {{ template "yugabyte.fs_data_dirs_probe_files" . }}
{{- end -}}


{{/*
Generate server FQDN.
*/}}
{{- define "yugabyte.server_fqdn" -}}
  {{- if .Values.multicluster.createServicePerPod -}}
    {{- printf "${HOSTNAME}.${NAMESPACE}.svc.%s" .Values.domainName -}}
  {{- else if (and .Values.oldNamingStyle .Values.multicluster.createServiceExports) -}}
    {{ $membershipName := required "A valid membership name is required! Please set multicluster.kubernetesClusterId" .Values.multicluster.kubernetesClusterId }}
    {{- printf "${HOSTNAME}.%s.%s.${NAMESPACE}.svc.clusterset.local" $membershipName .Service.name -}}
  {{- else if .Values.oldNamingStyle -}}
    {{- printf "${HOSTNAME}.%s.${NAMESPACE}.svc.%s" .Service.name .Values.domainName -}}
  {{- else -}}
    {{- if .Values.multicluster.createServiceExports -}}
      {{ $membershipName := required "A valid membership name is required! Please set multicluster.kubernetesClusterId" .Values.multicluster.kubernetesClusterId }}
      {{- printf "${HOSTNAME}.%s.%s-%s.${NAMESPACE}.svc.clusterset.local" $membershipName (include "yugabyte.fullname" .) .Service.name -}}
    {{- else -}}
      {{- printf "${HOSTNAME}.%s-%s.${NAMESPACE}.svc.%s" (include "yugabyte.fullname" .) .Service.name .Values.domainName -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Generate server broadcast address.
*/}}
{{- define "yugabyte.server_broadcast_address" -}}
  {{- include "yugabyte.server_fqdn" . }}:{{ index .Service.ports "tcp-rpc-port" -}}
{{- end -}}

{{/*
Generate server RPC bind address.

In case of multi-cluster services (MCS), we set it to ${POD_IP} to
ensure YCQL uses a resolvable address.
See https://github.com/yugabyte/yugabyte-db/issues/16155

We use a workaround for above in case of Istio by setting it to
${POD_IP} and localhost. Master doesn't support that combination, so
we stick to 0.0.0.0, which works for master.
*/}}
{{- define "yugabyte.rpc_bind_address" -}}
  {{- $port := index .Service.ports "tcp-rpc-port" -}}
  {{- if .Values.istioCompatibility.enabled -}}
    {{- if (eq .Service.name "yb-masters") -}}
      0.0.0.0:{{ $port }}
    {{- else -}}
      ${POD_IP}:{{ $port }},127.0.0.1:{{ $port }}
    {{- end -}}
  {{- else if (or .Values.multicluster.createServiceExports .Values.multicluster.createServicePerPod) -}}
    ${POD_IP}:{{ $port }}
  {{- else -}}
    {{- include "yugabyte.server_fqdn" . -}}
  {{- end -}}
{{- end -}}

{{/*
Generate server web interface.
*/}}
{{- define "yugabyte.webserver_interface" -}}
  {{- eq .Values.ip_version_support "v6_only" | ternary "[::]" "0.0.0.0" -}}
{{- end -}}

{{/*
Generate server CQL proxy bind address.
*/}}
{{- define "yugabyte.cql_proxy_bind_address" -}}
  {{- eq .Values.ip_version_support "v6_only" | ternary "[::]" "0.0.0.0" -}}:{{ index .Service.ports "tcp-yql-port" -}}
{{- end -}}

{{/*
Generate server PGSQL proxy bind address.
*/}}
{{- define "yugabyte.pgsql_proxy_bind_address" -}}
  {{- eq .Values.ip_version_support "v6_only" | ternary "[::]" "0.0.0.0" -}}:{{ index .Service.ports "tcp-ysql-port" -}}
{{- end -}}

{{/*
Get YugaByte master addresses.
Usage: {{ include "yugabyte.master_addresses" (dict "root" $root "vars" $masterStsVars) }}
  - root: the chart root context (.)
  - vars: the result of "yugabyte.stsIndexVars" for the "yb-masters" service
*/}}
{{- define "yugabyte.master_addresses" -}}
  {{- $root := .root -}}
  {{- $vars := .vars -}}
  {{- $domain_name := $root.Values.domainName -}}
  {{- $newNamingStylePrefix := printf "%s-" (include "yugabyte.fullname" $root) -}}
  {{- $prefix := ternary "" $newNamingStylePrefix $root.Values.oldNamingStyle -}}
  {{- $addrs := list -}}
  {{- range $stsIdx := until (int $vars.stsCount) -}}
    {{- $loopVars := include "yugabyte.stsIndexLoopVars" (dict "stsIdx" $stsIdx "stsStart" $vars.stsStart "stsEnd" $vars.stsEnd "replicas" $vars.replicas "moveOpReplicas" $vars.moveOpReplicas) | fromYaml -}}
    {{- $stsIndexSuffix := $loopVars.stsIndexSuffix -}}
    {{- $currentReplicas := $loopVars.currentReplicas | int -}}
    {{- range $index := until $currentReplicas -}}
      {{- $addr := "" -}}
      {{- if eq $root.Values.multicluster.kubernetesClusterId "" -}}
        {{- $addr = printf "%syb-master%s-%d.%syb-masters.${NAMESPACE}.svc.%s:7100" $prefix $stsIndexSuffix $index $prefix $domain_name -}}
      {{- else -}}
        {{- $addr = printf "%syb-master%s-%d.%s.%syb-masters.${NAMESPACE}.svc.%s:7100" $prefix $stsIndexSuffix $index $root.Values.multicluster.kubernetesClusterId $prefix $domain_name -}}
      {{- end -}}
      {{- $addrs = append $addrs $addr -}}
    {{- end -}}
  {{- end -}}
  {{- join "," $addrs -}}
{{- end -}}

{{/*
Compute the maximum number of unavailable pods based on the number of master replicas
*/}}
{{- define "yugabyte.max_unavailable_for_quorum" -}}
  {{- $master_replicas_100x := .Values.replicas.master | int | mul 100 -}}
  {{- $max_unavailable_master_replicas := 100 | div (100 | sub (2 | div ($master_replicas_100x | add 100))) -}}
  {{- printf "%d" $max_unavailable_master_replicas -}}
{{- end -}}

{{/*
Set consistent issuer name.
*/}}
{{- define "yugabyte.tls_cm_issuer" -}}
  {{- if .Values.tls.certManager.bootstrapSelfsigned -}}
    {{ .Values.oldNamingStyle | ternary "yugabyte-selfsigned" (printf "%s-selfsigned" (include "yugabyte.fullname" .)) }}
  {{- else -}}
    {{- if .Values.tls.certManager.useCustomIssuer -}}
      {{ .Values.tls.certManager.customIssuer.name }}
    {{- else -}}
      {{ .Values.tls.certManager.useClusterIssuer | ternary .Values.tls.certManager.clusterIssuer .Values.tls.certManager.issuer }}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Set issuer kind.
*/}}
{{- define "yugabyte.tls_issuer_kind" -}}
  {{- if .Values.tls.certManager.useCustomIssuer -}}
    {{ .Values.tls.certManager.customIssuer.kind }}
  {{- else -}}
    {{ .Values.tls.certManager.useClusterIssuer | ternary "ClusterIssuer" "Issuer" }}
  {{- end -}}
{{- end -}}

{{/*
Set issuer group.
*/}}
{{- define "yugabyte.tls_issuer_group" -}}
  {{- if .Values.tls.certManager.useCustomIssuer -}}
    {{ .Values.tls.certManager.customIssuer.group | default "cert-manager.io"  }}
  {{- else -}}
    {{ "" }}
  {{- end -}}
{{- end -}}

{{/*
  Verify the extraVolumes and extraVolumeMounts mappings.
  Every extraVolumes should have extraVolumeMounts
*/}}
{{- define "yugabyte.isExtraVolumesMappingExists" -}}
  {{- $lenExtraVolumes := len .extraVolumes -}}
  {{- $lenExtraVolumeMounts := len .extraVolumeMounts -}}

  {{- if and (eq $lenExtraVolumeMounts 0) (gt $lenExtraVolumes 0) -}}
    {{- fail "You have not provided the extraVolumeMounts for extraVolumes." -}}
  {{- else if and (eq $lenExtraVolumes 0) (gt $lenExtraVolumeMounts 0) -}}
    {{- fail "You have not provided the extraVolumes for extraVolumeMounts." -}}
  {{- else if and (gt $lenExtraVolumes 0) (gt $lenExtraVolumeMounts 0) -}}
      {{- $volumeMountsList := list -}}
      {{- range .extraVolumeMounts -}}
        {{- $volumeMountsList = append $volumeMountsList .name -}}
      {{- end -}}

      {{- $volumesList := list -}}
      {{- range .extraVolumes -}}
        {{- $volumesList = append $volumesList .name -}}
      {{- end -}}

      {{- range $volumesList -}}
        {{- if not (has . $volumeMountsList) -}}
          {{- fail (printf "You have not provided the extraVolumeMounts for extraVolume %s" .) -}}
        {{- end -}}
      {{- end -}}

      {{- range $volumeMountsList -}}
        {{- if not (has . $volumesList) -}}
          {{- fail (printf "You have not provided the extraVolumes for extraVolumeMounts %s" .) -}}
        {{- end -}}
      {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  Default nodeAffinity for multi-az deployments
*/}}
{{- define "yugabyte.multiAZNodeAffinity" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
  - matchExpressions:
    - key: failure-domain.beta.kubernetes.io/zone
      operator: In
      values:
      - {{ quote .Values.AZ }}
  - matchExpressions:
    - key: topology.kubernetes.io/zone
      operator: In
      values:
      - {{ quote .Values.AZ }}
{{- end -}}

{{/*
  Default podAntiAffinity for master and tserver

  This requires "appLabelArgs" to be passed in - defined in service.yaml
  we have a .root and a .label in appLabelArgs
*/}}
{{- define "yugabyte.podAntiAffinity" -}}
preferredDuringSchedulingIgnoredDuringExecution:
- weight: 100
  podAffinityTerm:
    labelSelector:
      matchExpressions:
      {{- if .root.Values.oldNamingStyle }}
      - key: app
        operator: In
        values:
        - "{{ .label }}"
      {{- else }}
      - key: app.kubernetes.io/name
        operator: In
        values:
        - "{{ .label }}"
      - key: release
        operator: In
        values:
        - {{ .root.Release.Name | quote }}
      {{- end }}
    topologyKey: kubernetes.io/hostname
{{- end -}}

{{/*
  YB Master ports
*/}}
{{- define "yugabyte.yb_masters.ports" -}}
{{- $masterPorts := dict -}}
{{- range .Values.Services -}}
  {{- if eq .name "yb-masters" -}}
    {{- range $key, $value := .ports -}}
      {{- $masterPorts = set $masterPorts $key $value -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- toYaml $masterPorts -}}
{{- end -}}

{{/*
  Readiness Probe for Master
*/}}
{{- define "yugabyte.master.readinessProbe" -}}
{{- if .Values.master.customReadinessProbe -}}
{{- toYaml .Values.master.customReadinessProbe }}
{{- else if .Values.master.readinessProbe.enabled -}}
{{- toYaml (omit .Values.master.readinessProbe "enabled") }}
httpGet:
  path: /
  port: {{ index (include "yugabyte.yb_masters.ports" .| fromYaml) "http-ui" }}
{{- end -}}
{{- end -}}

{{/*
  YB Tservers ports
*/}}
{{- define "yugabyte.yb_tservers.ports" -}}
{{- $tserverPorts := dict -}}
{{- range .Values.Services }}
  {{- if eq .name "yb-tservers" }}
    {{- range $key, $value := .ports }}
      {{- $tserverPorts = set $tserverPorts $key $value }}
    {{- end }}
  {{- end }}
{{- end }}
{{- toYaml $tserverPorts -}}
{{- end -}}

{{/*
  Readiness Probe for Tserver
  Use ".Values.authCredentials.ysql.password" while setting ysql credentials through YB DB values.yaml
  Use ".Values.gflags.tserver.ysql_enable_auth" while setting ysql credentials through YBA
*/}}
{{- define "yugabyte.tserver.readinessProbe" -}}
{{- if .Values.tserver.customReadinessProbe -}}
{{- toYaml .Values.tserver.customReadinessProbe }}
{{- else if .Values.tserver.readinessProbe.enabled -}}
{{- toYaml (omit .Values.tserver.readinessProbe "enabled") }}
exec:
  command:
  - bash
  - -v
  - -c
  - |
    {{- if not .Values.disableYsql }}
    {{- if (or .Values.authCredentials.ysql.password (eq .Values.gflags.tserver.ysql_enable_auth "true") .Values.authCredentials.ysql.passwordSecretName) }}
    unix_socket=$(find /tmp -name ".yb.*");
    ysqlsh_output=$(ysqlsh -U yugabyte -h "${unix_socket}" -d system_platform -c "\\conninfo");
    exit_code="$?";
    {{- else }}
    ysqlsh_output=$(ysqlsh -U yugabyte -h 127.0.0.1 -p {{ index (include "yugabyte.yb_tservers.ports" . | fromYaml) "tcp-ysql-port" }} -d system_platform -c "\\conninfo");
    exit_code="$?";
    {{- end }}

    if [[ $exit_code -ne 0 ]]; then
      echo "Error while executing ysqlsh command. Exit code: ${exit_code}";
      echo "Error: ${ysqlsh_output}";
      exit "${exit_code}"
    fi
    {{- end }}

    {{- if not (eq .Values.gflags.tserver.start_cql_proxy "false") }}
    {{- if (and .Values.tls.enabled .Values.tls.clientToServer) }}
    ycqlsh_output=$(ycqlsh --debug --ssl -e "SHOW HOST" "$HOSTNAME" {{ index (include "yugabyte.yb_tservers.ports" . | fromYaml) "tcp-yql-port" }} 2>&1);
    {{- else }}
    ycqlsh_output=$(ycqlsh --debug -e "SHOW HOST" "$HOSTNAME" {{ index (include "yugabyte.yb_tservers.ports" . | fromYaml) "tcp-yql-port" }} 2>&1);
    {{- end }}
    exit_code="$?";

    if [[ $exit_code -ne 0 && "${ycqlsh_output}" != *"Remote end requires authentication"* ]]; then
      echo "Error while executing ycqlsh command. Exit code: ${exit_code}";
      echo "Error: ${ycqlsh_output}";
      exit "${exit_code}"
    fi
    {{- end }}

    exit 0
{{- end -}}
{{- end -}}

{{/*
  Startup Probe for Master
*/}}
{{- define "yugabyte.master.startupProbe" -}}
{{- if .Values.master.customStartupProbe -}}
{{- toYaml .Values.master.customStartupProbe }}
{{- else if .Values.master.startupProbe.enabled -}}
{{- toYaml (omit .Values.master.startupProbe "enabled") }}
tcpSocket:
  port: {{ index (include "yugabyte.yb_masters.ports" .| fromYaml) "tcp-rpc-port" }}
{{- end -}}
{{- end -}}

{{/*
  Startup Probe for Tserver
*/}}
{{- define "yugabyte.tserver.startupProbe" -}}
{{- if .Values.tserver.customStartupProbe -}}
{{- toYaml .Values.tserver.customStartupProbe }}
{{- else if .Values.tserver.startupProbe.enabled -}}
{{- toYaml (omit .Values.tserver.startupProbe "enabled") }}
tcpSocket:
  port: {{ index (include "yugabyte.yb_tservers.ports" .| fromYaml) "tcp-rpc-port" }}
{{- end -}}
{{- end -}}

{{/*
  Get Security Context.
*/}}
{{- define "getSecurityContext" }}
securityContext:
  runAsUser: {{ required "runAsUser cannot be empty" .Values.containerSecurityContext.runAsUser }}
  {{- if ne .Values.containerSecurityContext.runAsGroup nil }}
  runAsGroup: {{ .Values.containerSecurityContext.runAsGroup }}
  {{- else }}
  runAsGroup: {{ .Values.containerSecurityContext.runAsUser }}
  {{- end }}
  runAsNonRoot: {{ .Values.containerSecurityContext.runAsNonRoot }}
  {{- if .Values.containerSecurityContext.additionalSettings }}
{{ toYaml .Values.containerSecurityContext.additionalSettings | indent 2}}
  {{- end }}
{{- end -}}

{{/*
Get ipFamily and ipFamilyPolicy settings.
*/}}
{{- define "yugabyte.ipFamilyConfig" }}
{{- if .Values.ipFamilies }}
ipFamilies:
  {{- range .Values.ipFamilies }}
  - {{ . }}
  {{- end }}
{{- end }}
{{- if .Values.ipFamilyPolicy }}
ipFamilyPolicy: {{ .Values.ipFamilyPolicy }}
{{- end }}
{{- end -}}

{{/*
  Append commonNameSuffix to commonName while ensuring total length doesn't exceed 63 characters.
*/}}
{{- define "yugabyte.commonNameWithSuffix" -}}
  {{- $commonName := .commonName -}}
  {{- $suffix := .root.Values.tls.certManager.certificates.commonNameSuffix | default "" -}}
  {{- if $suffix -}}
    {{- $combined := printf "%s-%s" $commonName $suffix -}}
    {{- if gt (len $combined) 63 -}}
      {{- $maxCommonNameLength := sub 63 (add 1 (len $suffix)) -}}
      {{- printf "%s-%s" ($commonName | trunc $maxCommonNameLength | trimSuffix "-") $suffix -}}
    {{- else -}}
      {{- $combined -}}
    {{- end -}}
  {{- else -}}
    {{- $commonName -}}
  {{- end -}}
{{- end -}}

{{/*
  Validate stsIndex start and end values for master and tserver.
  Rules:
  1. end must be >= start (except for the wrap-around case: start=9, end=0)
  2. If start != end (move operation in progress), end - start must be exactly 1, except for the wrap-around case
  3. start == end is valid (no move operation)
  
  Usage:
    {{- include "yugabyte.validateStsIndex" (dict "start" ($root.Values.stsIndex.master.start | int) "end" ($root.Values.stsIndex.master.end | int) "component" "master") -}}
    {{- include "yugabyte.validateStsIndex" (dict "start" ($root.Values.stsIndex.tserver.start | int) "end" ($root.Values.stsIndex.tserver.end | int) "component" "tserver") -}}
*/}}
{{- define "yugabyte.validateStsIndex" -}}
  {{- $start := .start | int -}}
  {{- $end := .end | int -}}
  {{- $component := .component -}}
  
  {{- $isWrapAround := and (eq $start 9) (eq $end 0) -}}
  {{- $diff := sub $end $start -}}
  {{- $isMoveOp := ne $start $end -}}
  
  {{- /* Check: end >= start (except wrap-around case) */ -}}
  {{- if and (not $isWrapAround) (lt $end $start) -}}
    {{- fail (printf "stsIndex.%s: end (%d) must be >= start (%d), except for the wrap-around case (start=9, end=0)" $component $end $start) -}}
  {{- end -}}
  
  {{- /* Check: if move operation (start != end), end - start must be exactly 1 (except wrap-around case) */ -}}
  {{- if and $isMoveOp (not $isWrapAround) (ne $diff 1) -}}
    {{- fail (printf "stsIndex.%s: end (%d) and start (%d) must differ by exactly one when start != end, except for the wrap-around case (start=9, end=0)" $component $end $start) -}}
  {{- end -}}
{{- end -}}

{{/*
Get storage info based on service type and move operation state.
Returns the storage dict object as YAML.
Usage:
  {{- $storageInfo := include "yugabyte.storageInfo" (dict "serviceName" $service.name "useMoveOp" $useMoveOp "root" $root) | fromYaml -}}
*/}}
{{- define "yugabyte.storageInfo" -}}
  {{- $serviceName := .serviceName -}}
  {{- $useMoveOp := .useMoveOp -}}
  {{- $root := .root -}}
  {{- if eq $serviceName "yb-masters" -}}
    {{- if $useMoveOp -}}
      {{- $root.Values.moveOp.storage.master | toYaml -}}
    {{- else -}}
      {{- $root.Values.storage.master | toYaml -}}
    {{- end -}}
  {{- else -}}
    {{- if $useMoveOp -}}
      {{- $root.Values.moveOp.storage.tserver | toYaml -}}
    {{- else -}}
      {{- $root.Values.storage.tserver | toYaml -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Get stsIndex variables for a service (master or tserver).
Returns a YAML dict with: stsStart, stsEnd, stsCount, replicas, moveOpReplicas, hasMoveOp
Usage: {{- $vars := include "yugabyte.stsIndexVars" (dict "serviceName" "yb-masters" "root" $root) | fromYaml -}}
*/}}
{{- define "yugabyte.stsIndexVars" -}}
  {{- $serviceName := .serviceName -}}
  {{- $root := .root -}}
  {{- $isMaster := eq $serviceName "yb-masters" -}}
  {{- $stsStart := ($isMaster | ternary $root.Values.stsIndex.master.start $root.Values.stsIndex.tserver.start) | int -}}
  {{- $stsEnd := ($isMaster | ternary $root.Values.stsIndex.master.end $root.Values.stsIndex.tserver.end) | int -}}
  {{- $stsCount := (add (mod (add (sub $stsEnd $stsStart) 10) 10) 1 | int) -}}
  {{- $replicas := ($isMaster | ternary $root.Values.replicas.master $root.Values.replicas.tserver) | int -}}
  {{- $moveOpReplicas := ($isMaster | ternary $root.Values.moveOp.replicas.master $root.Values.moveOp.replicas.tserver) | int -}}
  {{- $hasMoveOp := ne $stsStart $stsEnd -}}
stsStart: {{ $stsStart }}
stsEnd: {{ $stsEnd }}
stsCount: {{ $stsCount }}
replicas: {{ $replicas }}
moveOpReplicas: {{ $moveOpReplicas }}
hasMoveOp: {{ $hasMoveOp }}
{{- end -}}

{{/*
Get stsIndex loop variables for a specific iteration.
Returns a YAML dict with: currentStsIndex, useMoveOp, stsIndexSuffix, currentReplicas
Usage: {{- $loopVars := include "yugabyte.stsIndexLoopVars" (dict "stsIdx" $stsIdx "stsStart" $vars.stsStart "stsEnd" $vars.stsEnd "replicas" $vars.replicas "moveOpReplicas" $vars.moveOpReplicas) | fromYaml -}}
Note: The helper function casts all input values to int internally, so no casting is needed when passing values.
*/}}
{{- define "yugabyte.stsIndexLoopVars" -}}
  {{- $stsIdx := .stsIdx | int -}}
  {{- $stsStart := .stsStart | int -}}
  {{- $stsEnd := .stsEnd | int -}}
  {{- $replicas := .replicas | int -}}
  {{- $moveOpReplicas := .moveOpReplicas | int -}}
  {{- $currentStsIndex := mod (add $stsStart $stsIdx) 10 | int -}}
  {{- $useMoveOp := and (ne $stsStart $stsEnd) (eq $currentStsIndex $stsEnd) -}}
  {{- $stsIndexSuffix := eq $currentStsIndex 0 | ternary "" (printf "-%d" $currentStsIndex) -}}
  {{- $currentReplicas := $useMoveOp | ternary $moveOpReplicas $replicas | int -}}
currentStsIndex: {{ $currentStsIndex }}
useMoveOp: {{ $useMoveOp }}
stsIndexSuffix: {{ $stsIndexSuffix | quote }}
currentReplicas: {{ $currentReplicas }}
{{- end -}}
