# Helm Chart Evaluation Checklist

Use this checklist when evaluating a Helm chart from Artifact Hub or any third-party source before deploying it to your cluster.

## Maintenance and Trust

- [ ] **Last updated** — Chart updated within the last 6 months
- [ ] **Active maintainers** — More than 1 maintainer listed; responsive to issues
- [ ] **Version history** — Regular release cadence (not abandoned)
- [ ] **Source repository** — Links to a public repo with CI/CD
- [ ] **Stars / downloads** — Reasonable community adoption (context-dependent)
- [ ] **Organization backing** — Maintained by the upstream project or a reputable org

## Security

- [ ] **Container images** — Uses pinned image tags (not `latest`)
- [ ] **Image sources** — Images from trusted registries (official Docker Hub, ghcr.io, ECR public)
- [ ] **RBAC** — Creates only necessary ClusterRoles/Roles (least privilege)
- [ ] **Security contexts** — Containers run as non-root by default
- [ ] **Network policies** — Includes or documents NetworkPolicy support
- [ ] **Secrets handling** — Secrets not hardcoded in templates; supports external secrets
- [ ] **Pod security** — Supports `securityContext`, `readOnlyRootFilesystem`, drops capabilities

## Configurability

- [ ] **values.yaml documented** — Every value has a comment explaining its purpose
- [ ] **Resource requests/limits** — Configurable and has sensible defaults
- [ ] **Replica count** — Configurable for HA deployments
- [ ] **Storage** — PVC sizes and storage classes configurable
- [ ] **Ingress** — Optional ingress with configurable annotations
- [ ] **Environment variables** — Clean mechanism for injecting custom env vars
- [ ] **Tolerations/affinity** — Supports node scheduling customization

## Quality and Documentation

- [ ] **README** — Clear installation and upgrade instructions
- [ ] **NOTES.txt** — Post-install instructions rendered after `helm install`
- [ ] **Changelog** — Documents breaking changes between versions
- [ ] **Schema validation** — Includes `values.schema.json` for input validation
- [ ] **Tests** — Chart includes `helm test` hooks or CI test suite
- [ ] **Examples** — Provides example value files for common scenarios

## Operational Readiness

- [ ] **Health checks** — Templates include readiness and liveness probes
- [ ] **Monitoring** — Supports Prometheus annotations or ServiceMonitor CRDs
- [ ] **Logging** — Configurable log levels and output formats
- [ ] **Upgrade path** — Documented upgrade procedure; no manual steps between versions
- [ ] **Hooks** — Pre/post install/upgrade hooks are idempotent
- [ ] **CRDs** — CRD lifecycle managed correctly (install vs. upgrade)

## Red Flags (any of these = investigate further)

- Uses `latest` image tags
- Requires `cluster-admin` ClusterRoleBinding
- No RBAC — everything runs in the default service account
- Templates contain hardcoded namespaces
- No resource limits set by default
- Chart has open CVE-related issues with no response
- Mounts the Docker socket or host paths without justification
