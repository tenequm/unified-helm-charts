#!/usr/bin/env bash
# Renders the chart in the current directory with its defaults and with each ci/*.yaml
# values file, and validates the output. CRD kinds (Gateway API routes, ServiceMonitor)
# validate against the datreeio CRDs catalog. A script, not an inline moon task:
# moon substitutes $tokens inside task scripts.
set -euo pipefail
catalog='https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'
validate() { kubeconform -kubernetes-version 1.31.0 -strict -schema-location default -schema-location "$catalog"; }
helm template . | validate
shopt -s nullglob
for values in ci/*.yaml; do
  helm template . -f "$values" | validate
done
