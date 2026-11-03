# unified-helm-charts

Universal Helm charts: a service is deployed by a values file against a generic chart,
never by a chart of its own: `common-deployment` and `common-statefulset`. App-specific
charts do not belong here.

## Rules

- **Generic only.** Nothing service-specific goes into `common-*`. A need a service has
  becomes a values knob, off by default, so every existing values file renders exactly as
  before.
- **Shared templates live once.** Templates both `common-*` charts render are in
  `shared-templates/` and are symlinked into each chart's `templates/`. Edit the shared file;
  a new shared template needs a symlink in both charts.
- **Follow existing conventions.** Ingress keys keep the chart's own shape
  (`ingress`, `ingress_secondary`). Gateway API keys match the community charts (grafana,
  kube-prometheus-stack, loki): `route.<name>`, where `main` is the release name and any
  other key adds a `-<key>` suffix.
- **Every feature is rendered in CI.** Add or extend a `ci/*.yaml` values file in each chart
  it touches; `scripts/kubeconform.sh` renders the defaults plus every `ci/*.yaml`, and CRD
  kinds validate against the datreeio CRDs catalog. Check locally with `helm lint` and
  `bash ../../scripts/kubeconform.sh` from the chart directory.

## Releases

- semantic-release runs per chart on every push to `main` and releases a chart only when a
  commit touches its directory. A change only under `shared-templates/` releases nothing:
  touch each affected chart too (its `values.yaml` or `ci/` file).
- Commit types decide the bump: `feat` minor, `fix` patch, `!`/`BREAKING CHANGE` major,
  anything else none. Never edit `Chart.yaml` versions or `CHANGELOG.md` by hand; the release
  commit does.
- CI pins moon and proto to `.prototools` (moon 1.x): moon 2 rejects this workspace config.
- Packages go to `oci://ghcr.io/tenequm/unified-helm-charts/<chart>` and must stay public.
