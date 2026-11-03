# unified-helm-charts

Universal Helm charts: one generic chart per workload kind, configured entirely by a values
file, so a service never needs a chart of its own. A fork of
[gasp-xyz/helm-charts](https://github.com/gasp-xyz/helm-charts), which follows
[DevOps-Nirvana's universal charts](https://github.com/DevOps-Nirvana/Universal-Kubernetes-Helm-Charts).

| Chart | What it deploys |
| --- | --- |
| `common-deployment` | Any stateless service: Deployment, Service, Ingress and/or Gateway API routes, HPA, PDB, ServiceMonitor, RBAC |
| `common-statefulset` | The same for a StatefulSet |
| `node` | A Mangata (Gasp) blockchain node; inherited from upstream |
| `relaychain-testnet` | A two-validator Polkadot relaychain test network; inherited from upstream |

## Install

Charts are published as OCI artifacts on GHCR:

```bash
helm install my-svc oci://ghcr.io/tenequm/unified-helm-charts/common-deployment \
  --version 1.2.0 -f values.yaml
```

## Exposing a service

`ingress` and `ingress_secondary` render Ingresses. `route.<name>` renders Gateway API routes
(`HTTPRoute` or `GRPCRoute`), with the same keys as the grafana, kube-prometheus-stack and loki
charts. Both can be on at once, which is how you migrate from one to the other.

```yaml
service:
  enabled: true
  port: 8080
route:
  main:
    enabled: true
    parentRefs:
      - name: public
        namespace: gateway
        sectionName: https-example-com
    hostnames: [example.com]
    timeouts: {request: 0s}
```

The main rule targets this release's Service unless `backendRefs` points elsewhere;
`additionalRules` adds rules for other paths or Services. See the `route:` block in each
chart's `values.yaml`.

## Releasing

Conventional commits on `main` release each chart whose directory changed (semantic-release,
one version line per chart) and push it to GHCR. CI runs `moon ci :lint :kubeconform`.
